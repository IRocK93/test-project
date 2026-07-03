-- Add locale column to content tables with default 'en'
ALTER TABLE "ExpertAdviceCard" ADD COLUMN "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "RoutineTemplate" ADD COLUMN "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "MilestoneExpectation" ADD COLUMN "locale" TEXT NOT NULL DEFAULT 'en';
ALTER TABLE "StageContent" ADD COLUMN "locale" TEXT NOT NULL DEFAULT 'en';

-- Update RoutineTemplate: drop old single-column unique, add composite unique
ALTER TABLE "RoutineTemplate" DROP CONSTRAINT IF EXISTS "RoutineTemplate_stageKey_key";
CREATE UNIQUE INDEX "RoutineTemplate_stageKey_locale_key" ON "RoutineTemplate"("stageKey", "locale");

-- Update StageContent: drop old composite unique, add new composite unique with locale
ALTER TABLE "StageContent" DROP CONSTRAINT IF EXISTS "StageContent_babymonId_stageKey_key";
CREATE UNIQUE INDEX "StageContent_babymonId_stageKey_locale_key" ON "StageContent"("babymonId", "stageKey", "locale");

-- New indexes for locale-aware queries
CREATE INDEX "ExpertAdviceCard_stageKey_locale_idx" ON "ExpertAdviceCard"("stageKey", "locale");
CREATE INDEX "MilestoneExpectation_stageKey_domain_locale_idx" ON "MilestoneExpectation"("stageKey", "domain", "locale");
CREATE INDEX "StageContent_stageKey_locale_idx" ON "StageContent"("stageKey", "locale");
