# 16 — Prisma Baselining Incident (2026-07-04)

> **⚠️ CORRECTION (2026-07-04 evening):** The previous version of this document attributed the column-drop to a developer running `prisma db push` locally with a leaked `.env` pointing at prod. **That hypothesis was wrong.** A follow-up investigation (using `pg_attribute` on the production database) found that zero User columns have ever been dropped at the PostgreSQL level. The actual story is in [§ 2 Root cause](#2-root-cause): 4 deploys of `0004_align_schema_with_migrations` ran between 00:07 and 00:25 UTC on 2026-07-04, the first 3 failed (NUL artifacts blocking the Docker build, then composite unique-constraint conflict on `RoutineTemplate`/`StageContent`), and the 4th succeeded at 00:25:18 UTC. The column was never dropped from prod — it was simply never added until the 4th deploy. The earlier in-session writeup (commit `0b788ec`, "docs: baselining incident postmortem + CI guard against prisma db push") is now superseded by this corrected version.

**Audience:** Backend devs, DevOps, future on-call engineers.
**Status:** Resolved. Prevention in place (see [§ 4 Prevention](#4-prevention)).
**Related:** [`docs/15-MIGRATION-NOTES.md`](./15-MIGRATION-NOTES.md) (the migrations themselves), [`docs/17-SCHEMA-DRIFT-REFERENCE.sql`](./17-SCHEMA-DRIFT-REFERENCE.sql) (the full canonical schema drift, reference-only), [`docs/Production_Sprint/10_Database_Migration_Strategy.md`](./Production_Sprint/10_Database_Migration_Strategy.md) (the general strategy this incident touched).

This document records the **specific** prod incident from 2026-07-04, the **actual** cause (4 deploys of `0004`, 3 failed, 1 succeeded), the **proof** that no column was ever dropped (`pg_attribute.attisdropped = 0` for all 28 User columns), and the **defences** in place to prevent recurrence.

---

## 1. What happened

On 2026-07-04, the production NestJS API at `https://babymon-api-production.up.railway.app` was returning `HTTP 500 "A database error occurred"` on every `POST /api/v1/auth/register`. The Prisma error was:

```
PrismaClientKnownRequestError:
The column 'User.consentDataAt' does not exist in the current database.
```

The investigation revealed a sequence of **4 deploys** of `apps/api/prisma/migrations/0004_align_schema_with_migrations/migration.sql` running between 00:07 and 00:25 UTC on 2026-07-04. The first three failed and were rolled back; the fourth succeeded at 00:25:18 UTC. During the 18-minute failure window, the new app code (which referenced `User.consentDataAt`) was running against a schema that didn't have the column yet — because `0004`, the migration that **adds** the column, hadn't successfully applied.

---

## 2. Root cause

**`0004_align_schema_with_migrations` failed three times in a row before succeeding once.** The failure sequence:

| # | started (UTC) | rolled back (UTC) | root cause of failure |
|---|---|---|---|
| 1 | 00:07:04 | 00:14:40 | NUL artifacts in the working tree blocked the Docker `COPY prisma ./prisma/` step |
| 2 | 00:14:51 | 00:22:51 | After NUL cleanup, `prisma migrate deploy` failed on the unique-constraint swap (composite unique on `(stageKey, locale)` for `RoutineTemplate` and `StageContent`) because pre-existing rows had non-unique `locale` values |
| 3 | 00:23:02 | 00:25:06 | Same as #2 — the defensive dedup in `migration.sql` had not yet been added |
| 4 | 00:25:17 | ✅ finished 00:25:18 | Succeeded after commit `0f6ec71` (09:48 AEST) added the defensive dedup before the `DROP INDEX` / `CREATE UNIQUE INDEX` swap |

During the 3 failed deploys, the **new app code was already in the build** (the `fix(auth): RegisterDto now includes locale + consent booleans` commit from 09:15 AEST on 2026-07-03 had been merged earlier). The new code referenced `User.consentDataAt`; the schema didn't have the column (because `0004` hadn't applied); every `auth/register` call hit `P2022 "column does not exist"`.

### The column was never dropped from prod

PostgreSQL's `pg_attribute` catalog keeps a permanent record of every column that has ever been dropped: `attisdropped=true` stays in the catalog even after `DROP COLUMN`, invisible via `information_schema.columns` but absolutely visible to `pg_attribute`. Querying `pg_attribute` for all 28 User columns in prod:

```sql
SELECT attname, attisdropped FROM pg_attribute
JOIN pg_class ON pg_attribute.attrelid = pg_class.oid
WHERE pg_class.relname = 'User' AND attnum > 0;

-- Result: 28 rows
-- Dropped column count: 0
-- Every column has attisdropped = false
```

**Zero User columns have ever been dropped at the PG level.** If a `prisma db push`, a manual `ALTER TABLE ... DROP COLUMN`, or anything else had dropped the column, `attisdropped=true` would be there forever. It's not. The column was never "added then dropped" — it was simply never added until the 4th deploy at 00:25:18 UTC.

### Why the earlier "local prisma db push" theory was wrong

A previous post-incident writeup (commit `0b788ec`, "docs: baselining incident postmortem + CI guard against prisma db push") hypothesised that the column was dropped by a developer running `prisma db push` locally with an `apps/api/.env` pointing at the production Neon DB. The follow-up investigation for this incident found:

- **No `prisma db push` invocation** in any current or historical CI workflow (`.github/workflows/ci.yml`), Dockerfile, `docker-entrypoint.sh`, Makefile, or shell/PowerShell/batch script.
- **No `prisma db push`** in any tracked `package.json` script. The only `prisma:push` npm script is now guarded by `apps/api/scripts/guard-db-url.js` (added in commit `1e5230f`) to block non-local `DATABASE_URL`s.
- **No `.env` file in git history** other than `apps/api/.env.example` and `apps/api/.env.test`. `git log -G 'ep-cold-feather'` returns no commits.
- The currently-leaked `apps/api/.env` (with the prod Neon URL) is **not** in any branch's history; it was a local-only file that has since been replaced with a localhost-only `.env` (defence in depth).

The earlier theory is now superseded by the actual evidence: 4 deploys of `0004`, 3 failed, 1 succeeded, and `pg_attribute` proving no column was ever dropped.

---

## 3. The fix

The fix was iterative, not single-step. Each of the 3 failures led to a small fix that eventually let the 4th attempt succeed.

### 3.1 Remove NUL artifacts

NUL files (zero-byte files with the Windows reserved name) were being committed to the working tree by some tooling. They blocked Docker's `COPY prisma ./prisma/` step because Docker cannot copy NUL files. The fix was:

- Delete all NUL files from the working tree (commits `c5a9def`, `c7d36b6`, `18f63f6`)
- Add a CI step that fails the build if any tracked file contains NUL bytes
- Add a `.gitattributes` rule to prevent NUL files from being checked in

### 3.2 Add defensive dedup to `0004`

The composite unique-constraint swap on `RoutineTemplate` and `StageContent` required deduplicating pre-existing rows that had the same `(stageKey, locale)` pair. The defensive dedup statement (added in commit `0f6ec71`):

```sql
-- RoutineTemplate: keep one row per (stageKey, locale), rename the rest
UPDATE "RoutineTemplate" SET "locale" = "locale" || '_' || "id"
WHERE "id" NOT IN (
  SELECT MIN("id") FROM "RoutineTemplate" GROUP BY "stageKey", "locale"
);

-- StageContent: keep one row per (babymonId, stageKey, locale), rename the rest
UPDATE "StageContent" SET "locale" = "locale" || '_' || "id"
WHERE "id" NOT IN (
  SELECT MIN("id") FROM "StageContent" GROUP BY "babymonId", "stageKey", "locale"
);

DROP INDEX IF EXISTS "RoutineTemplate_stageKey_key";
CREATE UNIQUE INDEX IF NOT EXISTS "RoutineTemplate_stageKey_locale_key"
  ON "RoutineTemplate"("stageKey", "locale");

DROP INDEX IF EXISTS "StageContent_babymonId_stageKey_key";
CREATE UNIQUE INDEX IF NOT EXISTS "StageContent_babymonId_stageKey_locale_key"
  ON "StageContent"("babymonId", "stageKey", "locale");
```

On a fresh DB this is a no-op (the subquery's `MIN(id) IS` the row's own id for every row, so the `WHERE` clause excludes every row). On a half-migrated DB it renames the duplicates so the `DROP INDEX` / `CREATE UNIQUE INDEX` swap can succeed.

### 3.3 The 4th deploy succeeded

After the NUL cleanup (commits `c5a9def`, `c7d36b6`, `18f63f6`) and the defensive dedup (commit `0f6ec71`), the migration applied successfully on the 4th attempt at 00:25:18 UTC. The full migration is at `apps/api/prisma/migrations/0004_align_schema_with_migrations/migration.sql` (~265 lines). Every statement uses `IF NOT EXISTS` (or a `DO` block for `CREATE TYPE`, which doesn't support `IF NOT EXISTS`), so re-running it is a no-op.

### 3.4 Verify

After the 4th deploy:

1. `GET /api/v1/health/deep` returns `200` with `{ "userConsentDataAt": "present" }` (the new schema-drift probe from the three-pronged defence, see [§ 4.4](#44-the-runtime-schema-drift-probe-get-healthdeep))
2. `POST /api/v1/auth/register` returns `201` with `{ user, accessToken, refreshToken }`

---

## 4. Prevention

### 4.1 CI guard against `prisma db push`

`.github/workflows/ci.yml` runs a `Fail if prisma db push is referenced` step in the `lint-and-test` job. It greps every executable script (`.sh`, `.ps1`, `.bat`, `Dockerfile`, `package.json`, `docker-entrypoint.sh`, etc.) under `apps/` for the string `prisma db push` and fails the build if found.

The grep explicitly **excludes** `docs/` and `*.md` files because the documentation is allowed to mention `prisma db push` as a warning (this file does, `Production_Sprint/10_Database_Migration_Strategy.md` does, etc.). Only the things that **run** are flagged.

### 4.2 `prisma migrate status` in CI

`.github/workflows/ci.yml` runs `npx prisma migrate status` after `migrate deploy`. Fails the build if any migration in `_prisma_migrations` is in a failed or rolled-back state, or if a migration is missing.

### 4.3 The local dev guard (`apps/api/scripts/guard-db-url.js`)

Any npm script that mutates the DB (`prisma:migrate`, `prisma:migrate:prod`, `prisma:push`, `prisma:seed`, `prisma:studio`) is prefixed with `node scripts/guard-db-url.js`, which exits 1 if `DATABASE_URL` points at a non-local host. Bypass: `ALLOW_PROD_DB_MUTATION=true`.

### 4.4 The runtime schema-drift probe (`GET /api/v1/health/deep`)

`apps/api/src/health/health.controller.ts` exposes `GET /api/v1/health/deep` which queries `information_schema.columns` for `User.consentDataAt` and returns `503 ServiceUnavailableException` if missing. Wire this to your uptime monitor for a real-time schema-drift alarm.

### 4.5 The `pg_attribute` check (recommended followup)

`pg_attribute.attisdropped=true` is the only way to detect a past `DROP COLUMN` in Postgres. Add this query to `/health/deep`:

```sql
SELECT count(*) FROM pg_attribute a
JOIN pg_class c ON a.attrelid = c.oid
WHERE c.relname = 'User' AND a.attisdropped = true;
```

If non-zero, the prod DB has had columns dropped — investigate immediately.

---

## 5. Runbook for the next incident

If you see `PrismaClientKnownRequestError: The column 'X' does not exist in the current database` in production logs:

1. **Check the migrations table** to see if the migration that adds column `X` is in `_prisma_migrations` and is marked as `finished`:
   ```bash
   railway run --service babymon-api -- \
     npx prisma migrate status
   ```
2. **If the migration is in the table but `finished_at` is null and `rolled_back_at` is not null**, the migration failed and was rolled back. Check the deploy logs for the error. The most common causes are:
   - NUL artifacts blocking the Docker build (check `git log` for files with NUL bytes; commits like `c5a9def` are the fix)
   - Composite unique-constraint conflict (add defensive dedup like the `0f6ec71` commit; rename duplicates' columns before the `DROP INDEX` / `CREATE UNIQUE INDEX` swap)
3. **If the migration is missing from the table entirely**, the prod DB was probably set up via `prisma db push` (legacy case). Mark prior migrations as applied and create a new idempotent schema-sync migration (see [§ 3 The fix](#3-the-fix)).
4. **If the migration is in the table, marked as `finished`, but the column is still missing**, query `pg_attribute` to see if the column was ever dropped:
   ```sql
   SELECT attname, attisdropped FROM pg_attribute
   JOIN pg_class ON pg_attribute.attrelid = pg_class.oid
   WHERE pg_class.relname = 'User' AND attname = 'consentDataAt';
   ```
   If `attisdropped = false` and the column exists in `pg_attribute` but not in `information_schema.columns`, there's a deeper issue. If `attisdropped = true`, the column was dropped by something (an external `prisma db push`, a manual `ALTER TABLE`, or a destructive migration). Run the audit in [§ 4.5](#45-the-pg_attribute-check-recommended-followup) to enumerate all dropped columns, then write an idempotent migration to recreate the missing ones.
5. **Always re-verify with `GET /api/v1/health/deep` and `POST /api/v1/auth/register`** before declaring the incident resolved.

---

## 6. References

- [`docs/15-MIGRATION-NOTES.md`](./15-MIGRATION-NOTES.md) — the four migrations this incident touched (0001–0004) and what each does
- [`docs/17-SCHEMA-DRIFT-REFERENCE.sql`](./17-SCHEMA-DRIFT-REFERENCE.sql) — the full canonical drift between prod and `schema.prisma` (reference-only, not to be applied)
- [`docs/Production_Sprint/10_Database_Migration_Strategy.md`](./Production_Sprint/10_Database_Migration_Strategy.md) — the general strategy this incident touched; covers the `prisma db push` danger
- [`docs/Production_Sprint/13_Production_Deployment_Plan.md`](./Production_Sprint/13_Production_Deployment_Plan.md) — Phase 4 (Database Migration Strategy for Production) reinforces "never use `prisma db push` in production"
- `apps/api/prisma/migrations/0004_align_schema_with_migrations/migration.sql` — the idempotent schema-sync migration shipped during this incident
- `.github/workflows/ci.yml` — the `Fail if prisma db push is referenced` step that now prevents recurrence
- `apps/api/scripts/guard-db-url.js` — the local dev guard that blocks `prisma db push` against non-local `DATABASE_URL`s
- `apps/api/src/health/health.controller.ts` — the `/health/deep` runtime schema-drift probe

---

*Document Version: 2.0 · Authored: 2026-07-04 (post-incident) · Last corrected: 2026-07-04 (evening, after `pg_attribute` investigation) · Owner: Backend team*
