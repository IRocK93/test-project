# BabyMon — Migration Notes

**Audience:** Backend devs, DB admins, future readers debugging data after deploys.
**Last Updated:** 2026-07-03 (post-migration 0004)
**Applies to:** `apps/api/prisma/migrations/0001` → `0004_convert_stage_start_type_to_enum/`

This page is the human-readable roll-up of every Prisma migration that has been
applied to the BabyMon database. It exists so that future readers don't have to
reverse-engineer the *intent* of each migration from raw SQL.

---

## Migration Index

| # | Name | Date applied | What it does | Risk class |
|---|------|--------------|--------------|------------|
| 0001 | `initial_baseline` | 2026-06-04 | Full schema creation: custom enums (`AdviceCategory`, `ContentSource`, `MilestoneDomain`, `MilestoneStatus`, `GrowthType`, `SubscriptionTier`, `PromoCodeType`, `ProposalStatus`), all 35 tables, primary indexes. | **High** (one-shot baseline — never re-run on a populated DB) |
| 0002 | `add_locale_to_content` | 2026-06-22 | Adds non-nullable `locale String @default("en")` to `ExpertAdviceCard`, `RoutineTemplate`, `MilestoneExpectation`, `VaccinationSchedule`, `ScreeningReminder`, `StageContent`. Converts unique constraints to composite `(stageKey, locale)` / `(babymonId, stageKey, locale)`. | **Medium** (rewrites seed upsert keys — existing rows get `locale='en'`) |
| 0003 | `add_gender_enum_and_indexes` | 2026-07-01 | Adds `enum Gender { MONIESE MONIOUS MO }`. Converts `BabyMon.gender` from `text` to enum, mapping legacy `'UNKNOWN'` → `'MO'`. Adds 11 missing query indexes (`SleepLog[babymonId,startTime]`, `GrowthRecord[babymonId,measuredAt]`, `Allergy[babymonId,status]`, `Subscription[isActive/tier/stripeCustomerId]`, `Media[babymonId,fileType]`, etc.). | **Medium** (enum coercion is lossy if non-listed values existed) |
| 0004 | `convert_stage_start_type_to_enum` | 2026-07-03 | Adds `enum StageStartType { PLAN INCUBATING BORN }`. Converts `BabyMon.stageStartType` from free-text to enum. See [`PLAN replaces IDEA`](#plan-replaces-idea) below. | **Medium** (info-loss rename; old `'IDEA'` records collapse to `'PLAN'`) |

---

## Migration 0001 — Initial Baseline

**Run once.** This is the foundation. If you find yourself needing to "apply
0001 against a populated database," stop — the migration was already applied.
Use `npx prisma migrate status` to confirm.

Creates every enum that isn't introduced later (`Gender`, `StageStartType`,
and several i18n-related enums added in subsequent migrations). Establishes
the 35-table data model.

> **Canonical reference** for the schema surface: see [`docs/04-FILE-INVENTORY.md`](./04-FILE-INVENTORY.md) for "every table maps to one Prisma model" hand-off.

---

## Migration 0002 — Add Locale To Content

Localizes the user-facing content tables so the same entry can be authored
in `en`, `de`, `es`, `fr`, `he`, `pt`, `ar` independently. The `locale` column
defaults to `'en'`, so existing English-only rows continue to work unchanged.

**Composite uniques added** (these replaced single-column uniques):

- `RoutineTemplate`: `@@unique([stageKey, locale])`
- `StageContent`: `@@unique([babymonId, stageKey, locale])`

**Seed-script impact:** the companion seed files use `where: { stageKey_locale: { stageKey, locale: 'en' } }` upserts. If you add a new locale, the seed for that locale must run separately.

---

## Migration 0003 — Gender Enum + Production Indexes

Two-for-one migration: data integrity (enum) + performance (indexes).

### Gender enum mapping

| Old value | New value | Notes |
|-----------|-----------|-------|
| `'UNKNOWN'` | `'MO'` | All pre-Gender rows had `'UNKNOWN'`; the rename to `MONIESE`/`MONIOUS`/`MO` was a brand-name replacement ("boy/girl/child" in the BabyMon naming scheme). |
| `'MALE'` / `'BOY'` | `'MONIESE'` | Handled by app-layer (not migration — the migration only ran when no legacy `'MALE'` rows existed). |
| `'FEMALE'` / `'GIRL'` | `'MONIOUS'` | Same note as above. |

### Indexes added (performance for production)

Indexed table.column combinations added in 0003 (covering the most common
author-side dashboards + admin reads):

- `SleepLog[babymonId, startTime]` — sleep-dashboard timeline
- `BabyMilestone[expectationId]` — milestone catalogue rollups
- `SavedAdvice[babyMonId]` — per-baby advice library
- `Media[babyMonId, fileType]` — gallery filters
- `GrowthRecord[babyMonId, measuredAt]` — growth chart
- `Allergy[babyMonId, status]` — active-allergy lists
- `Subscription[isActive]`, `[tier]`, `[stripeCustomerId]` — admin/stripe jobs
- `UserRoutine[babyMonId]` — per-baby routine history
- `PromoRedemption[promoCodeId]` — promotion administration

> **Tradeoff:** indexes speed reads but add ~5–15% to writes. We add indexes
> *during* schema migration so Postgres ANALYZE has fresh stats from day one.

---

## Migration 0004 — `PLAN` Replaces `IDEA`

**This is the migration future readers will ask about most.** It is a
data-modelling clarification, not a fix; treat it as documented info-loss.

### What changed

```prisma
// Before
stageStartType String   // any text imaginable

// After
stageStartType StageStartType   // enum: PLAN | INCUBATING | BORN
```

### Why

The old `String` column was implicitly constrained by app code to one of
**`PLAN`, `INCUBATING`, `BORN`**, but the seed script introduced a fourth
value — **`IDEA`** — for the *system* BabyMon row (the placeholder used
for content lookup before any user-owned BabyMon exists). **No
user-created BabyMon has ever had `'IDEA'`** — the only row that ever held
that value was the singular system BabyMon in `apps/api/prisma/seed.ts`
(line 34, since updated to `'PLAN'`). Over time this became confusing:
every code path treated "IDEA" identically to "PLAN"
("pre-conception, no pregnancy dates yet"), so the two values were
duplicates in practice.

The 0004 migration collapses the duplicates:

| Legacy value | Maps to | Why |
|--------------|---------|-----|
| `'plan'` (any case) | `'PLAN'` | Normalised to enum casing. |
| `'incubating'` (any case) | `'INCUBATING'` | Same. |
| `'born'` (any case) | `'BORN'` | Same. |
| `'IDEA'` (uppercase) | `'PLAN'` | **Collapse** — semantically equivalent ("pre-conception placeholder"). |
| `'idea'` (lowercase) | `'PLAN'` | Same collapse. |
| `NULL` | `'PLAN'` | Defensive — `stageStartType` is `NOT NULL` in the schema, but the migration is written re-run-safe. |
| Any typo / unknown value | `'PLAN'` | Defensive — `PLAN` is the safest default (least likely to misrepresent a baby's actual stage because the app cross-checks against `ideaDate` / `conceptionDate` / `birthDate` at call sites). |

### What this means in practice

- **If you query `BabyMon.stageStartType` in app code:** treat `'PLAN'` as
  the universal "pre-conception, no pregnancy dates yet" sentinel.
  `'IDEA'` no longer exists.
- **If you wrote `'IDEA'` in a seed file:** change it to `'PLAN'`.
  Migration 0004 already updated the production seed; if you have a local
  or third-party seed file, run `grep -rn "'IDEA'" apps/api/prisma` and
  replace.
- **If you query historical audit logs:** rows written before migration
  0004 may show `'IDEA'` in JSON exports. That's *historical fidelity* —
  the column itself now only ever holds `PLAN`/`INCUBATING`/`BORN`.
- **No rows were deleted.** Migration 0004 only updates the `stageStartType`
  column on existing `BabyMon` records. Row count is unchanged.

### App-side consumers (verified unchanged)

These call sites assume `stageStartType` is one of three values and were
double-checked during the migration design:

- `apps/api/src/common/stage-calculator.service.ts:94-110` — returns `'idea'`, `'pregnancy'`, `'baby'` based on the three enum values.
- `apps/api/src/baby-mon/baby-mon.service.ts:49-72` — DTO validates `@IsIn(['PLAN','INCUBATING','BORN'])`.
- `apps/api/src/baby-mon/dto/baby-mon.dto.ts:30-55` — `@ValidateIf` decorators branch on `'INCUBATING'` / `'BORN'` / `'PLAN'`.
- `apps/api/src/companion/companion.service.ts:371` — `stageStartType === 'PLAN'` → "Pre-conception".

None of these ever read `'IDEA'` from the database, so the rename is safe.

### Roll-back notes (if you ever need to undo 0004)

If you must roll back the migration:

1. `psql $DATABASE_URL -c "ALTER TABLE \"BabyMon\" ALTER COLUMN \"stageStartType\" TYPE text USING \"stageStartType\"::text;"`
2. `psql $DATABASE_URL -c "DROP TYPE \"StageStartType\";"`
3. Manually re-introduce the old `StageStartType`-free column.

The `git log` for migration 0004 is the canonical reference; do not invent a
new migration to "fix" the rename — it would be re-doing work.

---

## How To Read A Migration Diff During Code Review

When reviewing a future PR that adds migration 0005+:

1. **Diff `schema.prisma`** first. The diff tells you what the migration is
   *supposed* to do.
2. **Open the corresponding `migration.sql`**. Confirm the SQL matches the
   schema diff exactly. If they diverge, the migration was hand-edited
   (which is fine — but flag it in review so reviewers know why).
3. **Look for `ALTER COLUMN ... USING`** — these are data-coercion points. Read
   the `USING` expression and the surrounding `UPDATE` blocks. If coercion
   drops a value (like the `'IDEA'` → `'PLAN'` collapse), the migration
   should have a header comment explaining the loss (see 0004 for the
   pattern).
4. **Run `npx prisma migrate diff --from-empty --to-schema-datamodel
   prisma/schema.prisma --script`** to compare what Prisma *thinks* the
   migration should be against the hand-written SQL. They should be
   near-identical for purely structural migrations; for data-coercing
   migrations (0003, 0004) the hand-written SQL will be stricter and that's
   correct.
5. **Run `npx prisma validate`** and `npx tsc --noEmit` from `apps/api/`.
   Both should pass cleanly.

---

## Common Questions

**Q: Why isn't `Gender` an enum with the values `MALE`/`FEMALE`?**
A: Branding — BabyMon uses gender-neutral "moniese / monious / mo." See
the brand guidance in `DELIVERABLES.md`.

**Q: Why did 0002 add a `locale` column with `NOT NULL` instead of nullable?**
A: Every content table needs at least an English row; treating `locale` as
optional would let empty rows exist and confuse the i18n renderers.

**Q: Can I add a new locale without writing a new migration?**
A: No — enum/seed/columns reflect `'en'`, `'de'`, `'es'`, `'fr'`, `'he'`,
`'pt'`, `'ar'` based on what's been hand-seeded. Adding a new locale
requires both a seed file update **and** a content-fill run; consult the
i18n guide in [`docs/Production_Sprint/12_Full_Stack_i18n.md`](./Production_Sprint/12_Full_Stack_i18n.md).

**Q: Where is `prisma migrate deploy` configured to run?**
A: In the Railway deploy hook (production) and as `pnpm prisma migrate
dev` locally.

---

## See Also

- [`docs/00-README-FIRST.md`](./00-README-FIRST.md) — entry point
- [`docs/01-ARCHITECTURE.md`](./01-ARCHITECTURE.md) — layers and providers
- [`docs/04-FILE-INVENTORY.md`](./04-FILE-INVENTORY.md) — model-to-file mapping
- [`docs/Production_Sprint/10_Database_Migration_Strategy.md`](./Production_Sprint/10_Database_Migration_Strategy.md) — strategy notes (do not use `prisma db push` in production)
- [`apps/api/prisma/schema.prisma`](../apps/api/prisma/schema.prisma) — canonical schema
- [`apps/api/prisma/migrations/`](../apps/api/prisma/migrations/) — every SQL file Prisma has run
