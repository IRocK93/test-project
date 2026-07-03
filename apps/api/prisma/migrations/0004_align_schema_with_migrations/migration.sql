-- Migration 0004: align_schema_with_migrations
--
-- WHY THIS EXISTS
-- ---------------
-- The production Neon database was originally populated via `prisma db push`
-- (not `prisma migrate deploy`), so the `_prisma_migrations` table was empty
-- even though the tables themselves existed. Migrations 0001 through 2026 have
-- been "resolved as applied" in the migrations table (via `prisma migrate
-- resolve --applied ...`), but the actual schema was never updated to match
-- what those migrations would have created.
--
-- This migration is idempotent: every statement uses `IF NOT EXISTS` (or a
-- DO block for enums, which don't support `IF NOT EXISTS`). Running it twice
-- is a no-op; running it on a fresh DB just creates everything; running it on
-- a half-migrated DB fills in the missing pieces.
--
-- It brings the actual schema into sync with what `schema.prisma` expects.

-- ===========================================================================
-- User model: add consent + locale + push-notification fields
-- ===========================================================================
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "tosAcceptedAt"        TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "tosVersion"           TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "privacyAcceptedAt"    TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "privacyVersion"       TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "consentDataAt"        TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "locale"               TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "notificationsEnabled" BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pushMilestones"       BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pushBadges"           BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pushGrowth"           BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pushProposals"        BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "quietHoursStart"      TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "quietHoursEnd"        TEXT;

-- ===========================================================================
-- Content tables: add locale column
-- ===========================================================================
ALTER TABLE "ExpertAdviceCard"    ADD COLUMN IF NOT EXISTS "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "RoutineTemplate"     ADD COLUMN IF NOT EXISTS "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "MilestoneExpectation" ADD COLUMN IF NOT EXISTS "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "StageContent"        ADD COLUMN IF NOT EXISTS "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "ScreeningReminder"   ADD COLUMN IF NOT EXISTS "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "VaccinationSchedule" ADD COLUMN IF NOT EXISTS "locale" TEXT NOT NULL DEFAULT 'en';

-- ===========================================================================
-- Enums (CREATE TYPE doesn't support IF NOT EXISTS; wrap in DO block)
-- ===========================================================================
DO $$ BEGIN
  CREATE TYPE "Gender" AS ENUM ('MONIESE', 'MONIOUS', 'MO');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "StageStartType" AS ENUM ('PLAN', 'INCUBATING', 'BORN');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ===========================================================================
-- BabyMon: add stageStartType, convert gender + stageStartType to enums
-- ===========================================================================
ALTER TABLE "BabyMon" ADD COLUMN IF NOT EXISTS "stageStartType" TEXT;

-- Convert BabyMon.gender to Gender enum (defensive: map unknowns to 'MO')
DO $$
DECLARE
  col_type TEXT;
BEGIN
  SELECT data_type INTO col_type
  FROM information_schema.columns
  WHERE table_name = 'BabyMon' AND column_name = 'gender';

  IF col_type <> 'USER-DEFINED' THEN
    -- Pre-enum string column: clean up unknown values, then cast
    UPDATE "BabyMon"
      SET "gender" = 'MO'
      WHERE "gender" IS NOT NULL
        AND "gender" NOT IN ('MONIESE', 'MONIOUS', 'MO');

    ALTER TABLE "BabyMon"
      ALTER COLUMN "gender" TYPE "Gender"
      USING "gender"::"Gender";
  END IF;
END $$;

-- Convert BabyMon.stageStartType to StageStartType enum
DO $$
DECLARE
  col_type TEXT;
BEGIN
  SELECT data_type INTO col_type
  FROM information_schema.columns
  WHERE table_name = 'BabyMon' AND column_name = 'stageStartType';

  IF col_type <> 'USER-DEFINED' THEN
    -- Pre-enum string column: backfill NULLs, clean up unknowns, then cast
    UPDATE "BabyMon"
      SET "stageStartType" = 'PLAN'
      WHERE "stageStartType" IS NULL;

    UPDATE "BabyMon"
      SET "stageStartType" = 'PLAN'
      WHERE "stageStartType" NOT IN ('PLAN', 'INCUBATING', 'BORN');

    ALTER TABLE "BabyMon"
      ALTER COLUMN "stageStartType" TYPE "StageStartType"
      USING "stageStartType"::"StageStartType";

    ALTER TABLE "BabyMon"
      ALTER COLUMN "stageStartType" SET NOT NULL;
  END IF;
END $$;

-- ===========================================================================
-- Unique constraints: swap single-column for composite (stageKey, locale)
-- ===========================================================================
-- Defensive dedup: if any existing rows share a (stageKey, locale) or
-- (babymonId, stageKey, locale) pair (likely on a db-pushed prod DB that
-- was seeded before the locale column existed), append the row id to the
-- locale so the upcoming composite unique can be created. This is a no-op
-- when there are no duplicates: the subquery's MIN(id) IS the row's own id,
-- so the WHERE clause excludes every row.

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

-- ===========================================================================
-- Indexes (from 0003 + 2026)
-- ===========================================================================
CREATE INDEX IF NOT EXISTS "UserRoutine_babyMonId_idx"        ON "UserRoutine"("babyMonId");
CREATE INDEX IF NOT EXISTS "BabyMilestone_expectationId_idx"  ON "BabyMilestone"("expectationId");
CREATE INDEX IF NOT EXISTS "SavedAdvice_babyMonId_idx"        ON "SavedAdvice"("babyMonId");
CREATE INDEX IF NOT EXISTS "AdviceRating_userId_idx"          ON "AdviceRating"("userId");

CREATE INDEX IF NOT EXISTS "Subscription_isActive_idx"         ON "Subscription"("isActive");
CREATE INDEX IF NOT EXISTS "Subscription_tier_idx"            ON "Subscription"("tier");
CREATE INDEX IF NOT EXISTS "Subscription_stripeCustomerId_idx" ON "Subscription"("stripeCustomerId");

CREATE INDEX IF NOT EXISTS "PromoRedemption_promoCodeId_idx"   ON "PromoRedemption"("promoCodeId");

CREATE INDEX IF NOT EXISTS "Media_babyMonId_fileType_idx"      ON "Media"("babyMonId", "fileType");

CREATE INDEX IF NOT EXISTS "GrowthRecord_babyMonId_measuredAt_idx" ON "GrowthRecord"("babyMonId", "measuredAt");
CREATE INDEX IF NOT EXISTS "Allergy_babyMonId_status_idx"      ON "Allergy"("babyMonId", "status");

CREATE INDEX IF NOT EXISTS "Milestone_babymonId_happenedAt_idx"   ON "Milestone"("babymonId", "happenedAt");
CREATE INDEX IF NOT EXISTS "FeedLog_babymonId_happenedAt_idx"     ON "FeedLog"("babymonId", "happenedAt");
CREATE INDEX IF NOT EXISTS "HealthRecord_babymonId_happenedAt_idx" ON "HealthRecord"("babymonId", "happenedAt");
CREATE INDEX IF NOT EXISTS "SleepLog_babymonId_startTime_idx"    ON "SleepLog"("babymonId", "startTime");

CREATE INDEX IF NOT EXISTS "ExpertAdviceC
