-- Migration 0005: align_babymon_fields
--
-- WHY THIS EXISTS
-- ---------------
-- On 2026-07-04, migration 0004 (align_schema_with_migrations) added
-- `User.consentDataAt`, the `Gender` and `StageStartType` enums, three
-- new tables (`PromoCode`, `PromoRedemption`, `DailyActivity`), and
-- several indexes — and it converted `BabyMon.gender` / `BabyMon.stageStartType`
-- from text to enums. However it did NOT add the new BabyMon columns
-- that the schema had introduced in a recent commit.
--
-- As a result, the API's `GET /api/v1/baby-mons` endpoint started
-- returning 500 with P2022:
--     "The column BabyMon.gestationalAgeAtBirth does not exist"
--
-- This migration backfills the 6 missing BabyMon columns (and 1 missing
-- index) that should have been in 0004. All statements are idempotent
-- (`ADD COLUMN IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`) so re-running
-- is a no-op.
--
-- 0005 columns align prod BabyMon with schema.prisma's BabyMon model.
-- Future migrations should be sourced from `prisma migrate diff
-- --from-schema-datasource --to-schema-datamodel` and reviewed before
-- commit (see docs/16 and docs/17 for the postmortems of two schema-
-- drift incidents on this project).

-- ===========================================================================
-- Missing columns on BabyMon (added to schema after the original db-push
-- that bootstrapped prod, and missed by 0004)
-- ===========================================================================
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "gestationalAgeAtBirth" INTEGER;
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "dueDate"               TIMESTAMP(3);
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "traitsUpdatedAt"       TIMESTAMP(3);
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "siblingGroupId"        TEXT;
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "isGraduated"           BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "graduatedAt"           TIMESTAMP(3);

-- ===========================================================================
-- Missing index: BabyMon_siblingGroupId_idx (for twins / multiples)
-- ===========================================================================
CREATE INDEX IF NOT EXISTS "BabyMon_siblingGroupId_idx" ON "BabyMon"("siblingGroupId");
