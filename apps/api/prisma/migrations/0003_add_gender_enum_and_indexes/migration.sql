-- Clean up stale unique indexes from 0001 that 0002's DROP CONSTRAINT IF EXISTS
-- did not remove (unique indexes are not constraints in PostgreSQL).
DROP INDEX IF EXISTS "RoutineTemplate_stageKey_key";
DROP INDEX IF EXISTS "StageContent_babymonId_stageKey_key";

-- Create Gender enum (only if not already present in DB)
DO $$ BEGIN
  CREATE TYPE "Gender" AS ENUM ('MONIESE', 'MONIOUS', 'MO');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Migrate BabyMon.gender column from String to Gender enum
-- Map any legacy 'UNKNOWN' values to 'MO' before casting.
UPDATE "BabyMon" SET "gender" = 'MO' WHERE "gender" = 'UNKNOWN';
ALTER TABLE "BabyMon" ALTER COLUMN "gender" TYPE "Gender" USING "gender"::"Gender";

-- ── New indexes for query performance ──

-- SleepLog: timeline queries per baby (babymonId + startTime)
CREATE INDEX IF NOT EXISTS "SleepLog_babymonId_startTime_idx" ON "SleepLog"("babymonId", "startTime");

-- SavedAdvice: lookup by babyMon
CREATE INDEX IF NOT EXISTS "SavedAdvice_babyMonId_idx" ON "SavedAdvice"("babyMonId");

-- Allergy: filter active allergies per baby
CREATE INDEX IF NOT EXISTS "Allergy_babyMonId_status_idx" ON "Allergy"("babyMonId", "status");

-- Subscription: active subscription lookups
CREATE INDEX IF NOT EXISTS "Subscription_isActive_idx" ON "Subscription"("isActive");
CREATE INDEX IF NOT EXISTS "Subscription_tier_idx" ON "Subscription"("tier");
CREATE INDEX IF NOT EXISTS "Subscription_stripeCustomerId_idx" ON "Subscription"("stripeCustomerId");

-- UserRoutine: routines per babyMon
CREATE INDEX IF NOT EXISTS "UserRoutine_babyMonId_idx" ON "UserRoutine"("babyMonId");

-- BabyMilestone: lookup by expectation
CREATE INDEX IF NOT EXISTS "BabyMilestone_expectationId_idx" ON "BabyMilestone"("expectationId");

-- GrowthRecord: growth data sorted by date per baby
CREATE INDEX IF NOT EXISTS "GrowthRecord_babyMonId_measuredAt_idx" ON "GrowthRecord"("babyMonId", "measuredAt");

-- AdviceRating: user's ratings
CREATE INDEX IF NOT EXISTS "AdviceRating_userId_idx" ON "AdviceRating"("userId");

-- Media: filter by file type per baby
CREATE INDEX IF NOT EXISTS "Media_babyMonId_fileType_idx" ON "Media"("babyMonId", "fileType");

-- PromoRedemption: count redemptions per promo code
CREATE INDEX IF NOT EXISTS "PromoRedemption_promoCodeId_idx" ON "PromoRedemption"("promoCodeId");
