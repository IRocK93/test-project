# 16 — Prisma Baselining Incident (2026-07-04)

**Audience:** Backend devs, DevOps, future on-call engineers.
**Status:** Resolved. Prevention in place (see [§ 4 Prevention](#4-prevention)).
**Related:** [`docs/15-MIGRATION-NOTES.md`](./15-MIGRATION-NOTES.md) (the migrations themselves), [`docs/Production_Sprint/10_Database_Migration_Strategy.md`](./Production_Sprint/10_Database_Migration_Strategy.md) (the general strategy that this incident violated).

This document records the **specific** prod incident from 2026-07-04, the **exact** fix that was applied, and the **CI guard** that now prevents it from recurring. Read this before touching the production database.

---

## 1. What happened

On 2026-07-04, the production NestJS API at `https://babymon-api-production.up.railway.app` was returning `HTTP 500 "A database error occurred"` on every `POST /api/v1/auth/register`. The Prisma error was:

```
PrismaClientKnownRequestError:
The column 'User.consentDataAt' does not exist in the current database.
```

Six hours of debugging later, the root cause turned out to be a mismatch between what the Prisma client expected and what the actual Postgres schema in Neon contained. The two were out of sync in a way that the existing CI checks (which only run `prisma migrate diff` against a fresh local DB) could not catch.

---

## 2. Root cause

**The production Neon database was originally populated via `prisma db push`, not via `prisma migrate deploy`.**

`prisma db push` is a **development-only** command that synchronises the database schema to match `schema.prisma` without writing any migration history. It does **not** populate the `_prisma_migrations` table, which is what `prisma migrate deploy` reads to decide which migrations to apply.

The result:

| What `prisma db push` did | What it did **not** do |
|---------------------------|------------------------|
| Created every table, column, and enum in `schema.prisma` at the time of the push | Record any of those operations in `_prisma_migrations` |
| Made the DB structurally usable for the running app | Make the DB aware that those operations *had been "applied"* |

When the schema was later modified (new columns like `consentDataAt`, new enums like `Gender` and `StageStartType`, composite unique constraints on `RoutineTemplate` and `StageContent`, new locale columns on content tables, new performance indexes), the changes only existed in:

- `schema.prisma` (what the code expects)
- New migration files in `apps/api/prisma/migrations/0002_*`, `0003_*`, `20260703080749_*` (what the migration system tracks)

…but **not** in the actual production database. Because `_prisma_migrations` was empty, the entrypoint's `npx prisma migrate deploy` tried to apply every migration from scratch, hit `CREATE TABLE "User" ...` from 0001 first, failed with "relation already exists" (the db-pushed table was already there), rolled back the transaction, and left the prod DB in its original stale state.

### Why the existing CI did not catch this

The CI workflow's `Verify Prisma schema is fully migrated` step runs:

```yaml
npx prisma migrate diff \
  --from-migrations prisma/migrations \
  --to-schema-datamodel prisma/schema.prisma \
  --shadow-database-url "postgresql://...babymon_shadow..." \
  --exit-code
```

This is a **fresh-database** check. It asks "if I were to spin up a brand-new database and apply all the migration files, would I end up with the same schema as `schema.prisma`?" The answer is **yes** — the migrations are internally consistent. But the CI never asks the other half of the question: "does the actual production database match the migrations?" Because the production DB was db-pushed, that question has no CI guard at all.

---

## 3. The fix

The fix is a one-time **baselining** of the production database. It has three steps, in order.

### 3.1 Mark the existing migration files as already applied

For every migration folder in `apps/api/prisma/migrations/`, tell Prisma "this migration was applied to the production DB; don't try to run it again":

```bash
# Run from apps/api/ with the production DATABASE_URL exported
railway run --service babymon-api -- \
  npx prisma migrate resolve --applied 0001_initial_baseline
railway run --service babymon-api -- \
  npx prisma migrate resolve --applied 0002_add_locale_to_content
railway run --service babymon-api -- \
  npx prisma migrate resolve --applied 0003_add_gender_enum_and_indexes
railway run --service babymon-api -- \
  npx prisma migrate resolve --applied 20260703080749_convert_stage_start_type
```

After these four commands, `_prisma_migrations` contains four rows, but **the actual database schema is still the old db-pushed state**. We have just told Prisma to consider the migrations "done" so it won't try to re-apply them (and fail on `CREATE TABLE`).

### 3.2 Write an idempotent schema-sync migration

Create a new migration folder `0005_align_schema_with_migrations/` (or the next number after whatever already exists) with a `migration.sql` that uses `IF NOT EXISTS` (or DO blocks for enums) for every change. The pattern for each kind of object:

```sql
-- ADD COLUMN — natively idempotent in Postgres 9.6+
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "consentDataAt" TIMESTAMP(3);

-- CREATE INDEX — natively idempotent
CREATE INDEX IF NOT EXISTS "SleepLog_babymonId_startTime_idx"
  ON "SleepLog"("babymonId", "startTime");

-- Unique-constraint swap — drop old, create new (both idempotent)
DROP INDEX IF EXISTS "RoutineTemplate_stageKey_key";
CREATE UNIQUE INDEX IF NOT EXISTS "RoutineTemplate_stageKey_locale_key"
  ON "RoutineTemplate"("stageKey", "locale");

-- CREATE TYPE — wrap in DO block (no IF NOT EXISTS for types)
DO $$ BEGIN
  CREATE TYPE "Gender" AS ENUM ('MONIESE', 'MONIOUS', 'MO');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Enum conversion — check information_schema, then UPDATE + ALTER in one DO block
DO $$
DECLARE col_type TEXT;
BEGIN
  SELECT data_type INTO col_type
  FROM information_schema.columns
  WHERE table_name = 'BabyMon' AND column_name = 'gender';
  IF col_type <> 'USER-DEFINED' THEN
    UPDATE "BabyMon" SET "gender" = 'MO'
      WHERE "gender" IS NOT NULL
        AND "gender" NOT IN ('MONIESE', 'MONIOUS', 'MO');
    ALTER TABLE "BabyMon"
      ALTER COLUMN "gender" TYPE "Gender"
      USING "gender"::"Gender";
  END IF;
END $$;

-- Defensive dedup before creating a composite unique on existing data
UPDATE "RoutineTemplate" SET "locale" = "locale" || '_' || "id"
WHERE "id" NOT IN (
  SELECT MIN("id") FROM "RoutineTemplate" GROUP BY "stageKey", "locale"
);
```

The full migration we shipped for this incident is at `apps/api/prisma/migrations/0004_align_schema_with_migrations/migration.sql` (~160 lines). Every statement is idempotent — running it twice is a no-op, running it on a half-migrated DB fills in the missing pieces, running it on a fresh DB just creates everything.

### 3.3 Deploy and verify

1. Commit the new migration folder and push to `master`.
2. Railway's webhook triggers a rebuild. The new container's entrypoint runs `npx prisma migrate deploy`, which now sees:
   - 0001–2026 marked as applied → skipped
   - 0004 (the new one) → applies
3. The schema is now in sync. Verify with a smoke test:

```bash
curl -s https://babymon-api-production.up.railway.app/api/v1/auth/register \
  -X POST -H 'Content-Type: application/json' \
  -d '{"email":"verify-…@babymon.app","password":"Smoke1234!","name":"Verify","locale":"en","tosAccepted":true,"privacyAccepted":true,"consentToDataProcessing":true}'
# Expect: HTTP 201 with { user, accessToken, refreshToken }
```

The full conversation log of the original incident + fix is in the session history (commit messages reference the symptom; the PR diff is the authoritative record).

---

## 4. Prevention

Three layers of defence, in order of how soon they fire:

### 4.1 CI guard (catches the mistake at PR time)

`.github/workflows/ci.yml` runs a `Fail if prisma db push is referenced` step in the `lint-and-test` job. It greps every executable script (`.sh`, `.ps1`, `.bat`, `Dockerfile`, `package.json`, `docker-entrypoint.sh`, etc.) under `apps/` for the string `prisma db push` and fails the build if found.

The grep explicitly **excludes** `docs/` and `*.md` files because the documentation is allowed to mention `prisma db push` as a warning (this file does, `Production_Sprint/10_Database_Migration_Strategy.md` does, etc.). Only the things that **run** are flagged.

If a developer adds a new shell script or CI step that runs `prisma db push`, the PR fails before it can be merged. The error message links back to this document so the developer can read the incident and understand why.

### 4.2 Existing `prisma migrate diff` check (catches schema/migration drift on a fresh DB)

Already in CI. Runs `prisma migrate diff --from-migrations prisma/migrations --to-schema-datamodel prisma/schema.prisma --exit-code` against a shadow database. Fails the build if a future `schema.prisma` change is not reflected in a migration file. This is a necessary but not sufficient guard — it does not catch the case where the **production** database is out of sync with the migrations (the original incident).

### 4.3 Local development rules (human layer)

- **Never run `prisma db push` against a non-local database.** Use it for local dev only (where losing data is acceptable). For Neon, Railway, or any hosted Postgres, use `prisma migrate deploy` after committing a new migration file.
- **Never commit a `.env` with a production `DATABASE_URL`** to a developer machine. Railway / Neon credentials should live only in CI secrets and the Railway dashboard.
- **The first deploy of a fresh production database must go through `prisma migrate deploy`**, not `prisma db push`. If you find yourself wanting to db-push prod, you are almost certainly in the situation this document describes — go to [§ 3 The fix](#3-the-fix).

---

## 5. Runbook for the next incident

If you see `PrismaClientKnownRequestError: The column 'X' does not exist in the current database` in production logs but the migration for column `X` is in `apps/api/prisma/migrations/`:

1. **Check the migrations table** to see if the migration is marked as applied:
   ```bash
   railway run --service babymon-api -- \
     npx prisma db execute --stdin --schema /app/prisma/schema.prisma \
     <<< "SELECT migration_name, finished_at IS NOT NULL AS applied
          FROM _prisma_migrations ORDER BY started_at;"
   ```
2. **If the migration is NOT in the table**, the prod DB was probably set up via `prisma db push` (this incident). Jump to [§ 3 The fix](#3-the-fix).
3. **If the migration IS in the table but the column is still missing**, the prod DB was probably re-pushed by a developer running `prisma db push` from a local machine with prod credentials. Check `git log` for any commits that mention "schema sync" or "db push", and audit `.env` files for leaked `DATABASE_URL`s. Then run the idempotent schema-sync migration to add the missing columns back.
4. **Always re-verify with the smoke test** in [§ 3.3](#33-deploy-and-verify) before declaring the incident resolved.

---

## 6. References

- [`docs/15-MIGRATION-NOTES.md`](./15-MIGRATION-NOTES.md) — the four migrations this incident touched (0001–0004) and what each does
- [`docs/Production_Sprint/10_Database_Migration_Strategy.md`](./Production_Sprint/10_Database_Migration_Strategy.md) — the general strategy that was violated; covers the `prisma db push` danger
- [`docs/Production_Sprint/13_Production_Deployment_Plan.md`](./Production_Sprint/13_Production_Deployment_Plan.md) — Phase 4 (Database Migration Strategy for Production) reinforces "never use `prisma db push` in production"
- `apps/api/prisma/migrations/0004_align_schema_with_migrations/migration.sql` — the idempotent schema-sync migration shipped during this incident
- `.github/workflows/ci.yml` — the `Fail if prisma db push is referenced` step that now prevents recurrence

---

*Document Version: 1.0 · Authored: 2026-07-04 (post-incident) · Owner: Backend team*
