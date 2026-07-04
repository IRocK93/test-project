-- ============================================================================
-- Schema Drift Reference (2026-07-04 incident)
-- ============================================================================
-- THIS IS A REFERENCE ARTIFACT. DO NOT APPLY THIS SQL TO ANY DATABASE.
--
-- This file is the raw output of:
--   npx prisma migrate diff \
--     --from-url "$PROD_DATABASE_URL" \
--     --to-schema-datamodel apps/api/prisma/schema.prisma \
--     --script
--
-- It documents the FULL canonical schema drift between the production Neon
-- database and apps/api/prisma/schema.prisma as of 2026-07-04.
--
-- WHY IT WASN'T APPLIED
-- ----------------------
-- The actual migration that was applied to prod is
-- apps/api/prisma/migrations/0004_align_schema_with_migrations/migration.sql
-- — a minimum-viable, idempotent fix. This file (the canonical diff) was
-- deliberately NOT applied because:
--
--   1. It includes DROP CONSTRAINT statements for FK constraints. The schema
--      uses relationMode = "prisma", which means no actual FKs exist in the
--      DB, so these would fail (or no-op, but they're confusing).
--   2. It includes DROP COLUMN operations for type changes (e.g., BabyMon.gender
--      from text to Gender enum), which would lose data.
--   3. It includes DROP TYPE for old enums, which would break running code
--      that references them.
--   4. The CREATE INDEX statements are not idempotent (no IF NOT EXISTS), so
--      re-running on a partially-migrated DB would fail.
--
-- The actual migration.sql adds the same columns/tables/indexes idempotently
-- (using IF NOT EXISTS and DO blocks) and uses defensive casts to convert
-- text columns to enums in place.
--
-- WHEN TO REVISIT
-- ---------------
-- If a future migration is planned that does a full schema rebuild (e.g.,
-- dropping obsolete enums, removing the old text columns), this file can be
-- the starting point — after careful manual review of the destructive
-- statements and a data-preservation plan.
--
-- The original output (565 lines) follows below. It was generated on
-- 2026-07-04 during the incident debugging; see commit 0f6ec71 for context.
-- ============================================================================


-- CreateEnum
CREATE TYPE "PromoCodeType" AS ENUM ('TRIAL_EXTEND', 'FULL_PREMIUM');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "ContentSource" ADD VALUE 'EXPERT';
ALTER TYPE "ContentSource" ADD VALUE 'PARENT_COMMUNITY';

-- AlterEnum
BEGIN;
CREATE TYPE "Gender_new" AS ENUM ('MONIESE', 'MONIOUS', 'MO');
ALTER TABLE "BabyMon" ALTER COLUMN "gender" TYPE "Gender_new" USING ("gender"::text::"Gender_new");
ALTER TYPE "Gender" RENAME TO "Gender_old";
ALTER TYPE "Gender_new" RENAME TO "Gender";
DROP TYPE "Gender_old";
COMMIT;

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "MilestoneDomain" ADD VALUE 'MOTOR';
ALTER TYPE "MilestoneDomain" ADD VALUE 'LANGUAGE';
ALTER TYPE "MilestoneDomain" ADD VALUE 'SELF_HELP';

-- AlterEnum
BEGIN;
CREATE TYPE "MilestoneStatus_new" AS ENUM ('EXPECTED', 'EMERGING', 'ADVANCED', 'RED_FLAG');
ALTER TABLE "MilestoneExpectation" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "MilestoneExpectation" ALTER COLUMN "status" TYPE "MilestoneStatus_new" USING ("status"::text::"MilestoneStatus_new");
ALTER TYPE "MilestoneStatus" RENAME TO "MilestoneStatus_old";
ALTER TYPE "MilestoneStatus_new" RENAME TO "MilestoneStatus";
DROP TYPE "MilestoneStatus_old";
ALTER TABLE "MilestoneExpectation" ALTER COLUMN "status" SET DEFAULT 'EXPECTED';
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "StageStartType_new" AS ENUM ('PLAN', 'INCUBATING', 'BORN');
ALTER TABLE "BabyMon" ALTER COLUMN "stageStartType" TYPE "StageStartType_new" USING ("stageStartType"::text::"StageStartType_new");
ALTER TYPE "StageStartType" RENAME TO "StageStartType_old";
ALTER TYPE "StageStartType_new" RENAME TO "StageStartType";
DROP TYPE "StageStartType_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "SubscriptionTier_new" AS ENUM ('FREE', 'PREMIUM');
ALTER TABLE "Subscription" ALTER COLUMN "tier" DROP DEFAULT;
ALTER TABLE "Subscription" ALTER COLUMN "tier" TYPE "SubscriptionTier_new" USING ("tier"::text::"SubscriptionTier_new");
ALTER TYPE "SubscriptionTier" RENAME TO "SubscriptionTier_old";
ALTER TYPE "SubscriptionTier_new" RENAME TO "SubscriptionTier";
DROP TYPE "SubscriptionTier_old";
ALTER TABLE "Subscription" ALTER COLUMN "tier" SET DEFAULT 'FREE';
COMMIT;

-- DropForeignKey
ALTER TABLE "Allergy" DROP CONSTRAINT "Allergy_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "Allergy" DROP CONSTRAINT "Allergy_userId_fkey";

-- DropForeignKey
ALTER TABLE "AllergyEvent" DROP CONSTRAINT "AllergyEvent_allergyId_fkey";

-- DropForeignKey
ALTER TABLE "AllergyEvent" DROP CONSTRAINT "AllergyEvent_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "AllergyEvent" DROP CONSTRAINT "AllergyEvent_userId_fkey";

-- DropForeignKey
ALTER TABLE "AuditLog" DROP CONSTRAINT "AuditLog_actorUserId_fkey";

-- DropForeignKey
ALTER TABLE "AuditLog" DROP CONSTRAINT "AuditLog_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "BabyMilestone" DROP CONSTRAINT "BabyMilestone_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "BabyMilestone" DROP CONSTRAINT "BabyMilestone_expectationId_fkey";

-- DropForeignKey
ALTER TABLE "BabyMon" DROP CONSTRAINT "BabyMon_ownerUserId_fkey";

-- DropForeignKey
ALTER TABLE "Badge" DROP CONSTRAINT "Badge_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "Device" DROP CONSTRAINT "Device_userId_fkey";

-- DropForeignKey
ALTER TABLE "EntryChangeProposal" DROP CONSTRAINT "EntryChangeProposal_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "EntryChangeProposal" DROP CONSTRAINT "EntryChangeProposal_proposerUserId_fkey";

-- DropForeignKey
ALTER TABLE "FeedLog" DROP CONSTRAINT "FeedLog_authorUserId_fkey";

-- DropForeignKey
ALTER TABLE "FeedLog" DROP CONSTRAINT "FeedLog_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "GrowthRecord" DROP CONSTRAINT "GrowthRecord_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "GrowthRecord" DROP CONSTRAINT "GrowthRecord_userId_fkey";

-- DropForeignKey
ALTER TABLE "HealthRecord" DROP CONSTRAINT "HealthRecord_authorUserId_fkey";

-- DropForeignKey
ALTER TABLE "HealthRecord" DROP CONSTRAINT "HealthRecord_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "JournalProposal" DROP CONSTRAINT "JournalProposal_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "LinkedAccount" DROP CONSTRAINT "LinkedAccount_userAId_fkey";

-- DropForeignKey
ALTER TABLE "LinkedAccount" DROP CONSTRAINT "LinkedAccount_userBId_fkey";

-- DropForeignKey
ALTER TABLE "LinkedBabyMon" DROP CONSTRAINT "LinkedBabyMon_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "LinkedBabyMon" DROP CONSTRAINT "LinkedBabyMon_userId_fkey";

-- DropForeignKey
ALTER TABLE "Media" DROP CONSTRAINT "Media_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "Media" DROP CONSTRAINT "Media_userId_fkey";

-- DropForeignKey
ALTER TABLE "MedicalTeam" DROP CONSTRAINT "MedicalTeam_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "MedicalTeam" DROP CONSTRAINT "MedicalTeam_userId_fkey";

-- DropForeignKey
ALTER TABLE "Milestone" DROP CONSTRAINT "Milestone_authorUserId_fkey";

-- DropForeignKey
ALTER TABLE "Milestone" DROP CONSTRAINT "Milestone_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "PasswordResetToken" DROP CONSTRAINT "PasswordResetToken_userId_fkey";

-- DropForeignKey
ALTER TABLE "RefreshToken" DROP CONSTRAINT "RefreshToken_userId_fkey";

-- DropForeignKey
ALTER TABLE "SleepLog" DROP CONSTRAINT "SleepLog_authorUserId_fkey";

-- DropForeignKey
ALTER TABLE "SleepLog" DROP CONSTRAINT "SleepLog_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "StageContent" DROP CONSTRAINT "StageContent_babymonId_fkey";

-- DropForeignKey
ALTER TABLE "Subscription" DROP CONSTRAINT "Subscription_userId_fkey";

-- DropForeignKey
ALTER TABLE "UserRoutine" DROP CONSTRAINT "UserRoutine_babyMonId_fkey";

-- DropForeignKey
ALTER TABLE "UserRoutine" DROP CONSTRAINT "UserRoutine_templateId_fkey";

-- DropIndex
DROP INDEX "ExpertAdviceCard_source_idx";

-- DropIndex
DROP INDEX "ExpertAdviceCard_stageKey_category_idx";

-- DropIndex
DROP INDEX "PasswordResetToken_token_idx";

-- DropIndex
DROP INDEX "RoutineTemplate_stageKey_key";

-- DropIndex
DROP INDEX "ScreeningReminder_stageKey_idx";

-- DropIndex
DROP INDEX "ScreeningReminder_targetAgeDays_idx";

-- DropIndex
DROP INDEX "StageContent_babymonId_stageKey_key";

-- DropIndex
DROP INDEX "VaccinationSchedule_stageKey_idx";

-- AlterTable
ALTER TABLE "AdviceRating" ADD COLUMN     "comment" TEXT,
ADD COLUMN     "rating" INTEGER NOT NULL,
ALTER COLUMN "helpful" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Allergy" DROP COLUMN "severity",
ADD COLUMN     "severity" TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'ACTIVE';

-- AlterTable
ALTER TABLE "AllergyEvent" ADD COLUMN     "deletedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "AuditLog" DROP COLUMN "payloadJson",
ADD COLUMN     "payloadJson" JSONB;

-- AlterTable
ALTER TABLE "BabyMilestone" ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "achievedAt" DROP NOT NULL,
ALTER COLUMN "achievedAt" DROP DEFAULT;

-- AlterTable
ALTER TABLE "BabyMon" ADD COLUMN     "dueDate" TIMESTAMP(3),
ADD COLUMN     "gestationalAgeAtBirth" INTEGER,
ADD COLUMN     "graduatedAt" TIMESTAMP(3),
ADD COLUMN     "isGraduated" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "siblingGroupId" TEXT,
ADD COLUMN     "traitsUpdatedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "Device" DROP COLUMN "platform",
ADD COLUMN     "platform" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "EntryChangeProposal" DROP COLUMN "entryType",
ADD COLUMN     "entryType" TEXT NOT NULL,
DROP COLUMN "status",
ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'PENDING';

-- AlterTable
ALTER TABLE "ExpertAdviceCard" DROP COLUMN "ageRangeMaxDays",
DROP COLUMN "ageRangeMinDays",
DROP COLUMN "isRedFlag",
ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en',
ALTER COLUMN "source" SET DEFAULT 'DEVELOPMENT',
ALTER COLUMN "priority" SET DEFAULT 50;

-- AlterTable
ALTER TABLE "FeedLog" ADD COLUMN     "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
DROP COLUMN "type",
ADD COLUMN     "type" TEXT NOT NULL,
ALTER COLUMN "amount" SET DATA TYPE TEXT;

-- AlterTable
ALTER TABLE "GrowthRecord" DROP COLUMN "originalUnit",
ADD COLUMN     "deletedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "HealthRecord" ADD COLUMN     "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
ADD COLUMN     "unit" TEXT,
ADD COLUMN     "value" TEXT;

-- AlterTable
ALTER TABLE "JournalProposal" DROP COLUMN "entryType",
ADD COLUMN     "entryType" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "LinkedAccount" ADD COLUMN     "babyMonId" TEXT,
ADD COLUMN     "role" TEXT DEFAULT 'PARENT',
DROP COLUMN "status",
ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'PENDING';

-- AlterTable
ALTER TABLE "LinkedBabyMon" DROP COLUMN "access",
ADD COLUMN     "access" TEXT NOT NULL DEFAULT 'EDIT';

-- AlterTable
ALTER TABLE "Milestone" ADD COLUMN     "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED';

-- AlterTable
ALTER TABLE "MilestoneExpectation" ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en';

-- AlterTable
ALTER TABLE "RoutineTemplate" ADD COLUMN     "category" TEXT,
ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en',
ALTER COLUMN "description" DROP NOT NULL,
ALTER COLUMN "wakeWindowMins" DROP NOT NULL,
ALTER COLUMN "napCount" DROP NOT NULL,
ALTER COLUMN "totalNapHours" DROP NOT NULL,
ALTER COLUMN "nightSleepHours" DROP NOT NULL,
ALTER COLUMN "feedFrequency" DROP NOT NULL,
ALTER COLUMN "sampleSchedule" DROP NOT NULL,
DROP COLUMN "bedtimeRitual",
ADD COLUMN     "bedtimeRitual" JSONB,
ALTER COLUMN "flexible" SET DEFAULT false;

-- AlterTable
ALTER TABLE "SavedAdvice" DROP COLUMN "savedAt",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ALTER COLUMN "babyMonId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ScreeningReminder" DROP COLUMN "stageKey",
ADD COLUMN     "dueAgeMonths" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en',
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "description" DROP NOT NULL,
ALTER COLUMN "targetAgeDays" DROP NOT NULL,
ALTER COLUMN "screeningTool" DROP NOT NULL,
ALTER COLUMN "targetAudience" DROP NOT NULL;

-- AlterTable
ALTER TABLE "SleepLog" ADD COLUMN     "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
DROP COLUMN "type",
ADD COLUMN     "type" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "StageContent" ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en',
ALTER COLUMN "babymonId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Subscription" ALTER COLUMN "tier" SET DEFAULT 'FREE';

-- AlterTable
ALTER TABLE "User" DROP COLUMN "consentToDataProcessing",
DROP COLUMN "dateOfBirth",
ADD COLUMN     "consentDataAt" TIMESTAMP(3),
ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en',
ADD COLUMN     "notificationsEnabled" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "pushBadges" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "pushGrowth" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "pushMilestones" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "pushProposals" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "quietHoursEnd" TEXT,
ADD COLUMN     "quietHoursStart" TEXT;

-- AlterTable
ALTER TABLE "UserRoutine" ADD COLUMN     "active" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "stageKey" TEXT,
ADD COLUMN     "userId" TEXT NOT NULL,
ALTER COLUMN "babyMonId" DROP NOT NULL,
ALTER COLUMN "routineDate" DROP NOT NULL,
ALTER COLUMN "customizations" DROP NOT NULL,
DROP COLUMN "completedSteps",
ADD COLUMN     "completedSteps" JSONB NOT NULL DEFAULT '[]';

-- AlterTable
ALTER TABLE "VaccinationSchedule" DROP COLUMN "stageKey",
ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en',
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "doseNumber" SET DEFAULT 1;

-- DropEnum
DROP TYPE "AccessLevel";

-- DropEnum
DROP TYPE "AllergySeverity";

-- DropEnum
DROP TYPE "AllergyStatus";

-- DropEnum
DROP TYPE "DevicePlatform";

-- DropEnum
DROP TYPE "FeedingType";

-- DropEnum
DROP TYPE "JournalEntryType";

-- DropEnum
DROP TYPE "LinkedAccountStatus";

-- DropEnum
DROP TYPE "SleepType";

-- CreateTable
CREATE TABLE "PromoCode" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "type" "PromoCodeType" NOT NULL,
    "valueDays" INTEGER NOT NULL,
    "maxRedemptions" INTEGER,
    "currentRedemptions" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "expiresAt" TIMESTAMP(3),
    "createdBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PromoCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PromoRedemption" (
    "id" TEXT NOT NULL,
    "promoCodeId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "redeemedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PromoRedemption_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DailyActivity" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "hasMilestone" BOOLEAN NOT NULL DEFAULT false,
    "hasFeedLog" BOOLEAN NOT NULL DEFAULT false,
    "hasSleepLog" BOOLEAN NOT NULL DEFAULT false,
    "hasHealthRecord" BOOLEAN NOT NULL DEFAULT false,
    "hasGrowthRecord" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DailyActivity_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PromoCode_code_key" ON "PromoCode"("code");

-- CreateIndex
CREATE INDEX "PromoRedemption_userId_idx" ON "PromoRedemption"("userId");

-- CreateIndex
CREATE INDEX "PromoRedemption_promoCodeId_idx" ON "PromoRedemption"("promoCodeId");

-- CreateIndex
CREATE UNIQUE INDEX "PromoRedemption_promoCodeId_userId_key" ON "PromoRedemption"("promoCodeId", "userId");

-- CreateIndex
CREATE INDEX "DailyActivity_babymonId_idx" ON "DailyActivity"("babymonId");

-- CreateIndex
CREATE UNIQUE INDEX "DailyActivity_babymonId_date_key" ON "DailyActivity"("babymonId", "date");

-- CreateIndex
CREATE INDEX "AdviceRating_userId_idx" ON "AdviceRating"("userId");

-- CreateIndex
CREATE INDEX "Allergy_babyMonId_status_idx" ON "Allergy"("babyMonId", "status");

-- CreateIndex
CREATE INDEX "AuditLog_babymonId_idx" ON "AuditLog"("babymonId");

-- CreateIndex
CREATE INDEX "AuditLog_actorUserId_idx" ON "AuditLog"("actorUserId");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_eventType_idx" ON "AuditLog"("eventType");

-- CreateIndex
CREATE INDEX "BabyMilestone_expectationId_idx" ON "BabyMilestone"("expectationId");

-- CreateIndex
CREATE INDEX "BabyMon_siblingGroupId_idx" ON "BabyMon"("siblingGroupId");

-- CreateIndex
CREATE INDEX "EntryChangeProposal_babymonId_idx" ON "EntryChangeProposal"("babymonId");

-- CreateIndex
CREATE INDEX "EntryChangeProposal_proposerUserId_idx" ON "EntryChangeProposal"("proposerUserId");

-- CreateIndex
CREATE INDEX "EntryChangeProposal_status_idx" ON "EntryChangeProposal"("status");

-- CreateIndex
CREATE INDEX "ExpertAdviceCard_stageKey_idx" ON "ExpertAdviceCard"("stageKey");

-- CreateIndex
CREATE INDEX "ExpertAdviceCard_priority_idx" ON "ExpertAdviceCard"("priority");

-- CreateIndex
CREATE INDEX "ExpertAdviceCard_stageKey_locale_idx" ON "ExpertAdviceCard"("stageKey", "locale");

-- CreateIndex
CREATE INDEX "FeedLog_babymonId_happenedAt_idx" ON "FeedLog"("babymonId", "happenedAt");

-- CreateIndex
CREATE INDEX "GrowthRecord_deletedAt_idx" ON "GrowthRecord"("deletedAt");

-- CreateIndex
CREATE INDEX "GrowthRecord_babyMonId_measuredAt_idx" ON "GrowthRecord"("babyMonId", "measuredAt");

-- CreateIndex
CREATE INDEX "HealthRecord_babymonId_happenedAt_idx" ON "HealthRecord"("babymonId", "happenedAt");

-- CreateIndex
CREATE INDEX "JournalProposal_babymonId_idx" ON "JournalProposal"("babymonId");

-- CreateIndex
CREATE INDEX "JournalProposal_proposedById_idx" ON "JournalProposal"("proposedById");

-- CreateIndex
CREATE INDEX "JournalProposal_status_idx" ON "JournalProposal"("status");

-- CreateIndex
CREATE INDEX "LinkedAccount_status_idx" ON "LinkedAccount"("status");

-- CreateIndex
CREATE INDEX "LinkedAccount_babyMonId_idx" ON "LinkedAccount"("babyMonId");

-- CreateIndex
CREATE INDEX "Media_babyMonId_fileType_idx" ON "Media"("babyMonId", "fileType");

-- CreateIndex
CREATE INDEX "Milestone_babymonId_happenedAt_idx" ON "Milestone"("babymonId", "happenedAt");

-- CreateIndex
CREATE INDEX "MilestoneExpectation_stageKey_domain_locale_idx" ON "MilestoneExpectation"("stageKey", "domain", "locale");

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "RefreshToken"("userId");

-- CreateIndex
CREATE INDEX "RoutineTemplate_stageKey_idx" ON "RoutineTemplate"("stageKey");

-- CreateIndex
CREATE UNIQUE INDEX "RoutineTemplate_stageKey_locale_key" ON "RoutineTemplate"("stageKey", "locale");

-- CreateIndex
CREATE INDEX "ScreeningReminder_dueAgeMonths_idx" ON "ScreeningReminder"("dueAgeMonths");

-- CreateIndex
CREATE INDEX "ScreeningReminder_dueAgeMonths_locale_idx" ON "ScreeningReminder"("dueAgeMonths", "locale");

-- CreateIndex
CREATE INDEX "SleepLog_babymonId_startTime_idx" ON "SleepLog"("babymonId", "startTime");

-- CreateIndex
CREATE INDEX "StageContent_stageKey_locale_idx" ON "StageContent"("stageKey", "locale");

-- CreateIndex
CREATE UNIQUE INDEX "StageContent_babymonId_stageKey_locale_key" ON "StageContent"("babymonId", "stageKey", "locale");

-- CreateIndex
CREATE INDEX "Subscription_userId_idx" ON "Subscription"("userId");

-- CreateIndex
CREATE INDEX "Subscription_isActive_idx" ON "Subscription"("isActive");

-- CreateIndex
CREATE INDEX "Subscription_tier_idx" ON "Subscription"("tier");

-- CreateIndex
CREATE INDEX "Subscription_stripeCustomerId_idx" ON "Subscription"("stripeCustomerId");

-- CreateIndex
CREATE INDEX "UserRoutine_userId_idx" ON "UserRoutine"("userId");

-- CreateIndex
CREATE INDEX "VaccinationSchedule_dueAgeMonths_locale_idx" ON "VaccinationSchedule"("dueAgeMonths", "locale");

