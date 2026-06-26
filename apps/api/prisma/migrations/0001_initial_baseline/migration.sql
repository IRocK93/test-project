-- CreateEnum
CREATE TYPE "AdviceCategory" AS ENUM ('GROWTH_HEALTH', 'DEVELOPMENT', 'NUTRITION_FEEDING', 'SLEEP', 'PLAY_ACTIVITIES', 'PARENT_WELLBEING');

-- CreateEnum
CREATE TYPE "ContentSource" AS ENUM ('CLINICAL', 'DEVELOPMENT', 'EXPERT', 'PARENT_COMMUNITY', 'GENERAL');

-- CreateEnum
CREATE TYPE "MilestoneDomain" AS ENUM ('MOTOR', 'GROSS_MOTOR', 'FINE_MOTOR', 'COGNITIVE', 'LANGUAGE', 'LANGUAGE_COMMUNICATION', 'SOCIAL_EMOTIONAL', 'SELF_HELP');

-- CreateEnum
CREATE TYPE "MilestoneStatus" AS ENUM ('EXPECTED', 'EMERGING', 'ADVANCED', 'RED_FLAG');

-- CreateEnum
CREATE TYPE "GrowthType" AS ENUM ('WEIGHT', 'HEIGHT', 'HEAD_CIRCUMFERENCE');

-- CreateEnum
CREATE TYPE "SubscriptionTier" AS ENUM ('FREE', 'PREMIUM');

-- CreateEnum
CREATE TYPE "PromoCodeType" AS ENUM ('TRIAL_EXTEND', 'FULL_PREMIUM');

-- CreateEnum
CREATE TYPE "ProposalStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "ExpertAdviceCard" (
    "id" TEXT NOT NULL,
    "stageKey" TEXT NOT NULL,
    "category" "AdviceCategory" NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 50,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "source" "ContentSource" NOT NULL DEFAULT 'DEVELOPMENT',
    "tags" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ExpertAdviceCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RoutineTemplate" (
    "id" TEXT NOT NULL,
    "stageKey" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT,
    "wakeWindowMins" INTEGER,
    "napCount" INTEGER,
    "totalNapHours" DOUBLE PRECISION,
    "nightSleepHours" DOUBLE PRECISION,
    "feedFrequency" TEXT,
    "sampleSchedule" JSONB,
    "bedtimeRitual" JSONB,
    "flexible" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RoutineTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MilestoneExpectation" (
    "id" TEXT NOT NULL,
    "stageKey" TEXT NOT NULL,
    "domain" "MilestoneDomain" NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "MilestoneStatus" NOT NULL DEFAULT 'EXPECTED',
    "ageRangeMinDays" INTEGER,
    "ageRangeMaxDays" INTEGER,
    "redFlagText" TEXT,
    "activityPrompt" TEXT,
    "xpReward" INTEGER NOT NULL DEFAULT 10,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MilestoneExpectation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VaccinationSchedule" (
    "id" TEXT NOT NULL,
    "vaccineName" TEXT NOT NULL,
    "diseasePrevents" TEXT NOT NULL,
    "dueAgeMonths" DOUBLE PRECISION NOT NULL,
    "dueAgeWeeks" INTEGER,
    "doseNumber" INTEGER NOT NULL DEFAULT 1,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "VaccinationSchedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScreeningReminder" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "dueAgeMonths" DOUBLE PRECISION NOT NULL,
    "targetAgeDays" INTEGER,
    "screeningTool" TEXT,
    "targetAudience" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ScreeningReminder_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserRoutine" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "babyMonId" TEXT,
    "templateId" TEXT NOT NULL,
    "routineDate" TIMESTAMP(3),
    "stageKey" TEXT,
    "completedSteps" JSONB NOT NULL DEFAULT '[]',
    "customizations" JSONB,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserRoutine_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BabyMilestone" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "expectationId" TEXT NOT NULL,
    "achievedAt" TIMESTAMP(3),
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BabyMilestone_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SavedAdvice" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "babyMonId" TEXT,
    "adviceCardId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SavedAdvice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdviceRating" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "adviceCardId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "helpful" BOOLEAN,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdviceRating_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT,
    "name" TEXT,
    "phone" TEXT,
    "role" TEXT NOT NULL DEFAULT 'USER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "verificationToken" TEXT,
    "verificationExpires" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "verifiedAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),
    "tosAcceptedAt" TIMESTAMP(3),
    "tosVersion" TEXT,
    "privacyAcceptedAt" TIMESTAMP(3),
    "privacyVersion" TEXT,    "consentDataAt"       TIMESTAMP(3),
    "locale"              TEXT NOT NULL DEFAULT 'en',
    "notificationsEnabled" BOOLEAN NOT NULL DEFAULT true,
    "pushMilestones" BOOLEAN NOT NULL DEFAULT true,
    "pushBadges" BOOLEAN NOT NULL DEFAULT true,
    "pushGrowth" BOOLEAN NOT NULL DEFAULT true,
    "pushProposals" BOOLEAN NOT NULL DEFAULT true,
    "quietHoursStart" TEXT,
    "quietHoursEnd" TEXT,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PasswordResetToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PasswordResetToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Device" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "deviceToken" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastActiveAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Device_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LinkedAccount" (
    "id" TEXT NOT NULL,
    "userAId" TEXT NOT NULL,
    "userBId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "role" TEXT DEFAULT 'PARENT',
    "babyMonId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "linkedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),

    CONSTRAINT "LinkedAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LinkedBabyMon" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "access" TEXT NOT NULL DEFAULT 'EDIT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LinkedBabyMon_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BabyMon" (
    "id" TEXT NOT NULL,
    "ownerUserId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "middleName" TEXT,
    "lastName" TEXT,
    "stageStartType" TEXT NOT NULL,
    "conceptionDate" TIMESTAMP(3),
    "lmpDate" TIMESTAMP(3),
    "birthDate" TIMESTAMP(3),
    "gestationalAgeAtBirth" INTEGER,
    "dueDate" TIMESTAMP(3),
    "ideaDate" TIMESTAMP(3),
    "gender" TEXT NOT NULL,
    "traits" TEXT[],
    "traitsUpdatedAt" TIMESTAMP(3),
    "specialMove" TEXT,
    "biologicalMother" TEXT,
    "biologicalFather" TEXT,
    "bloodGroup" TEXT,
    "eyeColor" TEXT,
    "siblingGroupId" TEXT,
    "currentXp" INTEGER NOT NULL DEFAULT 0,
    "currentStage" INTEGER NOT NULL DEFAULT 1,
    "isGraduated" BOOLEAN NOT NULL DEFAULT false,
    "graduatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "BabyMon_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Milestone" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "authorUserId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "notes" TEXT,
    "happenedAt" TIMESTAMP(3) NOT NULL,
    "localMediaRefs" TEXT[],
    "isCustom" BOOLEAN NOT NULL DEFAULT false,
    "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "xpAwarded" INTEGER NOT NULL DEFAULT 10,

    CONSTRAINT "Milestone_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeedLog" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "authorUserId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "amount" TEXT,
    "unit" TEXT,
    "notes" TEXT,
    "happenedAt" TIMESTAMP(3) NOT NULL,
    "localMediaRefs" TEXT[],
    "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "xpAwarded" INTEGER NOT NULL DEFAULT 5,

    CONSTRAINT "FeedLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HealthRecord" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "authorUserId" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "value" TEXT,
    "unit" TEXT,
    "notes" TEXT,
    "happenedAt" TIMESTAMP(3) NOT NULL,
    "localMediaRefs" TEXT[],
    "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "xpAwarded" INTEGER NOT NULL DEFAULT 5,

    CONSTRAINT "HealthRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SleepLog" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "authorUserId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3) NOT NULL,
    "quality" INTEGER,
    "notes" TEXT,
    "happenedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "localMediaRefs" TEXT[],
    "syncStatus" TEXT NOT NULL DEFAULT 'SYNCED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "xpAwarded" INTEGER NOT NULL DEFAULT 5,

    CONSTRAINT "SleepLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Badge" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "badgeType" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "icon" TEXT,
    "description" TEXT,
    "xpValue" INTEGER NOT NULL DEFAULT 10,
    "unlockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Badge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StageContent" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT,
    "stageKey" TEXT NOT NULL,
    "weekNumber" INTEGER,
    "monthNumber" INTEGER,
    "isPostBirth" BOOLEAN NOT NULL DEFAULT false,
    "summaryText" TEXT NOT NULL,
    "nurturingText" TEXT NOT NULL,
    "encouragementText" TEXT NOT NULL,
    "xpThreshold" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "StageContent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Subscription" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tier" "SubscriptionTier" NOT NULL DEFAULT 'FREE',
    "stripeCustomerId" TEXT,
    "stripeSubscriptionId" TEXT,
    "stripePriceId" TEXT,
    "trialStartDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "trialEndDate" TIMESTAMP(3) NOT NULL,
    "currentPeriodStart" TIMESTAMP(3),
    "currentPeriodEnd" TIMESTAMP(3),
    "cancelAtPeriodEnd" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("id")
);

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
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT,
    "actorUserId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "payloadJson" JSONB,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EntryChangeProposal" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "proposerUserId" TEXT NOT NULL,
    "entryType" TEXT NOT NULL,
    "entryId" TEXT NOT NULL,
    "proposalType" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "proposedPayloadJson" TEXT NOT NULL,
    "originalPayloadJson" TEXT,
    "responseReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "autoAcceptedAt" TIMESTAMP(3),
    "respondedAt" TIMESTAMP(3),

    CONSTRAINT "EntryChangeProposal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StripeEvent" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "data" TEXT NOT NULL,
    "processed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StripeEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Media" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "fileType" TEXT NOT NULL,
    "fileSize" INTEGER NOT NULL,
    "s3Key" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "thumbnailUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "JournalProposal" (
    "id" TEXT NOT NULL,
    "babymonId" TEXT NOT NULL,
    "journalEntryId" TEXT NOT NULL,
    "entryType" TEXT NOT NULL,
    "proposedById" TEXT NOT NULL,
    "changes" JSONB NOT NULL,
    "status" "ProposalStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMP(3),
    "resolvedById" TEXT,

    CONSTRAINT "JournalProposal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GrowthRecord" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "GrowthType" NOT NULL,
    "value" DOUBLE PRECISION NOT NULL,
    "unit" TEXT NOT NULL,
    "measuredAt" TIMESTAMP(3) NOT NULL,
    "notes" TEXT,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GrowthRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Allergy" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "triggers" TEXT,
    "severity" TEXT,
    "treatment" TEXT,
    "notes" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "curedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Allergy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AllergyEvent" (
    "id" TEXT NOT NULL,
    "allergyId" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "happenedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AllergyEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MedicalTeam" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "specialty" TEXT,
    "facility" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "MedicalTeam_pkey" PRIMARY KEY ("id")
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
CREATE INDEX "ExpertAdviceCard_stageKey_idx" ON "ExpertAdviceCard"("stageKey");

-- CreateIndex
CREATE INDEX "ExpertAdviceCard_category_idx" ON "ExpertAdviceCard"("category");

-- CreateIndex
CREATE INDEX "ExpertAdviceCard_priority_idx" ON "ExpertAdviceCard"("priority");

-- CreateIndex
CREATE UNIQUE INDEX "RoutineTemplate_stageKey_key" ON "RoutineTemplate"("stageKey");

-- CreateIndex
CREATE INDEX "RoutineTemplate_stageKey_idx" ON "RoutineTemplate"("stageKey");

-- CreateIndex
CREATE INDEX "MilestoneExpectation_stageKey_domain_idx" ON "MilestoneExpectation"("stageKey", "domain");

-- CreateIndex
CREATE INDEX "MilestoneExpectation_domain_idx" ON "MilestoneExpectation"("domain");

-- CreateIndex
CREATE INDEX "VaccinationSchedule_dueAgeMonths_idx" ON "VaccinationSchedule"("dueAgeMonths");

-- CreateIndex
CREATE INDEX "ScreeningReminder_dueAgeMonths_idx" ON "ScreeningReminder"("dueAgeMonths");

-- CreateIndex
CREATE INDEX "UserRoutine_userId_idx" ON "UserRoutine"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "UserRoutine_babyMonId_routineDate_key" ON "UserRoutine"("babyMonId", "routineDate");

-- CreateIndex
CREATE INDEX "BabyMilestone_babyMonId_idx" ON "BabyMilestone"("babyMonId");

-- CreateIndex
CREATE UNIQUE INDEX "BabyMilestone_babyMonId_expectationId_key" ON "BabyMilestone"("babyMonId", "expectationId");

-- CreateIndex
CREATE INDEX "SavedAdvice_userId_idx" ON "SavedAdvice"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "SavedAdvice_userId_adviceCardId_key" ON "SavedAdvice"("userId", "adviceCardId");

-- CreateIndex
CREATE INDEX "AdviceRating_adviceCardId_idx" ON "AdviceRating"("adviceCardId");

-- CreateIndex
CREATE UNIQUE INDEX "AdviceRating_userId_adviceCardId_key" ON "AdviceRating"("userId", "adviceCardId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "PasswordResetToken_token_key" ON "PasswordResetToken"("token");

-- CreateIndex
CREATE INDEX "PasswordResetToken_userId_idx" ON "PasswordResetToken"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Device_deviceToken_key" ON "Device"("deviceToken");

-- CreateIndex
CREATE INDEX "Device_userId_idx" ON "Device"("userId");

-- CreateIndex
CREATE INDEX "LinkedAccount_userAId_idx" ON "LinkedAccount"("userAId");

-- CreateIndex
CREATE INDEX "LinkedAccount_userBId_idx" ON "LinkedAccount"("userBId");

-- CreateIndex
CREATE INDEX "LinkedAccount_status_idx" ON "LinkedAccount"("status");

-- CreateIndex
CREATE INDEX "LinkedAccount_babyMonId_idx" ON "LinkedAccount"("babyMonId");

-- CreateIndex
CREATE UNIQUE INDEX "LinkedAccount_userAId_userBId_key" ON "LinkedAccount"("userAId", "userBId");

-- CreateIndex
CREATE INDEX "LinkedBabyMon_userId_idx" ON "LinkedBabyMon"("userId");

-- CreateIndex
CREATE INDEX "LinkedBabyMon_babymonId_idx" ON "LinkedBabyMon"("babymonId");

-- CreateIndex
CREATE UNIQUE INDEX "LinkedBabyMon_userId_babymonId_key" ON "LinkedBabyMon"("userId", "babymonId");

-- CreateIndex
CREATE INDEX "BabyMon_ownerUserId_idx" ON "BabyMon"("ownerUserId");

-- CreateIndex
CREATE INDEX "BabyMon_deletedAt_idx" ON "BabyMon"("deletedAt");

-- CreateIndex
CREATE INDEX "BabyMon_siblingGroupId_idx" ON "BabyMon"("siblingGroupId");

-- CreateIndex
CREATE INDEX "Milestone_babymonId_idx" ON "Milestone"("babymonId");

-- CreateIndex
CREATE INDEX "Milestone_authorUserId_idx" ON "Milestone"("authorUserId");

-- CreateIndex
CREATE INDEX "Milestone_happenedAt_idx" ON "Milestone"("happenedAt");

-- CreateIndex
CREATE INDEX "Milestone_deletedAt_idx" ON "Milestone"("deletedAt");

-- CreateIndex
CREATE INDEX "Milestone_babymonId_happenedAt_idx" ON "Milestone"("babymonId", "happenedAt");

-- CreateIndex
CREATE INDEX "FeedLog_babymonId_idx" ON "FeedLog"("babymonId");

-- CreateIndex
CREATE INDEX "FeedLog_authorUserId_idx" ON "FeedLog"("authorUserId");

-- CreateIndex
CREATE INDEX "FeedLog_happenedAt_idx" ON "FeedLog"("happenedAt");

-- CreateIndex
CREATE INDEX "FeedLog_deletedAt_idx" ON "FeedLog"("deletedAt");

-- CreateIndex
CREATE INDEX "FeedLog_babymonId_happenedAt_idx" ON "FeedLog"("babymonId", "happenedAt");

-- CreateIndex
CREATE INDEX "HealthRecord_babymonId_idx" ON "HealthRecord"("babymonId");

-- CreateIndex
CREATE INDEX "HealthRecord_authorUserId_idx" ON "HealthRecord"("authorUserId");

-- CreateIndex
CREATE INDEX "HealthRecord_happenedAt_idx" ON "HealthRecord"("happenedAt");

-- CreateIndex
CREATE INDEX "HealthRecord_deletedAt_idx" ON "HealthRecord"("deletedAt");

-- CreateIndex
CREATE INDEX "HealthRecord_babymonId_happenedAt_idx" ON "HealthRecord"("babymonId", "happenedAt");

-- CreateIndex
CREATE INDEX "SleepLog_babymonId_idx" ON "SleepLog"("babymonId");

-- CreateIndex
CREATE INDEX "SleepLog_authorUserId_idx" ON "SleepLog"("authorUserId");

-- CreateIndex
CREATE INDEX "SleepLog_startTime_idx" ON "SleepLog"("startTime");

-- CreateIndex
CREATE INDEX "SleepLog_deletedAt_idx" ON "SleepLog"("deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Badge_babymonId_badgeType_key" ON "Badge"("babymonId", "badgeType");

-- CreateIndex
CREATE INDEX "StageContent_stageKey_idx" ON "StageContent"("stageKey");

-- CreateIndex
CREATE UNIQUE INDEX "StageContent_babymonId_stageKey_key" ON "StageContent"("babymonId", "stageKey");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_token_key" ON "RefreshToken"("token");

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "RefreshToken"("userId");

-- CreateIndex
CREATE INDEX "Subscription_userId_idx" ON "Subscription"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "PromoCode_code_key" ON "PromoCode"("code");

-- CreateIndex
CREATE INDEX "PromoRedemption_userId_idx" ON "PromoRedemption"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "PromoRedemption_promoCodeId_userId_key" ON "PromoRedemption"("promoCodeId", "userId");

-- CreateIndex
CREATE INDEX "AuditLog_babymonId_idx" ON "AuditLog"("babymonId");

-- CreateIndex
CREATE INDEX "AuditLog_actorUserId_idx" ON "AuditLog"("actorUserId");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_eventType_idx" ON "AuditLog"("eventType");

-- CreateIndex
CREATE INDEX "EntryChangeProposal_babymonId_idx" ON "EntryChangeProposal"("babymonId");

-- CreateIndex
CREATE INDEX "EntryChangeProposal_proposerUserId_idx" ON "EntryChangeProposal"("proposerUserId");

-- CreateIndex
CREATE INDEX "EntryChangeProposal_status_idx" ON "EntryChangeProposal"("status");

-- CreateIndex
CREATE UNIQUE INDEX "StripeEvent_eventId_key" ON "StripeEvent"("eventId");

-- CreateIndex
CREATE INDEX "Media_babyMonId_idx" ON "Media"("babyMonId");

-- CreateIndex
CREATE INDEX "Media_userId_idx" ON "Media"("userId");

-- CreateIndex
CREATE INDEX "Media_createdAt_idx" ON "Media"("createdAt");

-- CreateIndex
CREATE INDEX "JournalProposal_babymonId_idx" ON "JournalProposal"("babymonId");

-- CreateIndex
CREATE INDEX "JournalProposal_proposedById_idx" ON "JournalProposal"("proposedById");

-- CreateIndex
CREATE INDEX "JournalProposal_status_idx" ON "JournalProposal"("status");

-- CreateIndex
CREATE INDEX "GrowthRecord_babyMonId_idx" ON "GrowthRecord"("babyMonId");

-- CreateIndex
CREATE INDEX "GrowthRecord_measuredAt_idx" ON "GrowthRecord"("measuredAt");

-- CreateIndex
CREATE INDEX "GrowthRecord_deletedAt_idx" ON "GrowthRecord"("deletedAt");

-- CreateIndex
CREATE INDEX "Allergy_babyMonId_idx" ON "Allergy"("babyMonId");

-- CreateIndex
CREATE UNIQUE INDEX "Allergy_babyMonId_name_key" ON "Allergy"("babyMonId", "name");

-- CreateIndex
CREATE INDEX "AllergyEvent_allergyId_idx" ON "AllergyEvent"("allergyId");

-- CreateIndex
CREATE INDEX "AllergyEvent_babyMonId_idx" ON "AllergyEvent"("babyMonId");

-- CreateIndex
CREATE INDEX "AllergyEvent_happenedAt_idx" ON "AllergyEvent"("happenedAt");

-- CreateIndex
CREATE INDEX "MedicalTeam_babyMonId_idx" ON "MedicalTeam"("babyMonId");

-- CreateIndex
CREATE INDEX "MedicalTeam_facility_idx" ON "MedicalTeam"("facility");

-- CreateIndex
CREATE INDEX "MedicalTeam_specialty_idx" ON "MedicalTeam"("specialty");

-- CreateIndex
CREATE UNIQUE INDEX "MedicalTeam_babyMonId_name_key" ON "MedicalTeam"("babyMonId", "name");

-- CreateIndex
CREATE INDEX "DailyActivity_babymonId_idx" ON "DailyActivity"("babymonId");

-- CreateIndex
CREATE UNIQUE INDEX "DailyActivity_babymonId_date_key" ON "DailyActivity"("babymonId", "date");
