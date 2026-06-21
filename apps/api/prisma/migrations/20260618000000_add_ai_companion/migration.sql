-- CreateEnum
CREATE TYPE "AdviceCategory" AS ENUM ('GROWTH_HEALTH', 'DEVELOPMENT', 'NUTRITION_FEEDING', 'SLEEP', 'PLAY_ACTIVITIES', 'PARENT_WELLBEING');
CREATE TYPE "ExpertVoice" AS ENUM ('DR_VASQUEZ', 'MARIA_CHEN', 'BOTH');
CREATE TYPE "MilestoneDomain" AS ENUM ('GROSS_MOTOR', 'FINE_MOTOR', 'LANGUAGE_COMMUNICATION', 'COGNITIVE', 'SOCIAL_EMOTIONAL');
CREATE TYPE "MilestoneStatus" AS ENUM ('EXPECTED', 'EMERGING', 'ACHIEVED', 'NEEDS_EVALUATION');

-- CreateTable ExpertAdviceCard
CREATE TABLE "ExpertAdviceCard" (
    "id" TEXT NOT NULL,
    "stageKey" TEXT NOT NULL,
    "category" "AdviceCategory" NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "expertVoice" "ExpertVoice" NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 0,
    "ageRangeMinDays" INTEGER,
    "ageRangeMaxDays" INTEGER,
    "tags" TEXT[],
    "isRedFlag" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "ExpertAdviceCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable RoutineTemplate
CREATE TABLE "RoutineTemplate" (
    "id" TEXT NOT NULL,
    "stageKey" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "wakeWindowMins" INTEGER NOT NULL,
    "napCount" INTEGER NOT NULL,
    "totalNapHours" DOUBLE PRECISION NOT NULL,
    "nightSleepHours" DOUBLE PRECISION NOT NULL,
    "feedFrequency" TEXT NOT NULL,
    "sampleSchedule" JSONB NOT NULL,
    "bedtimeRitual" TEXT[],
    "flexible" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "RoutineTemplate_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "RoutineTemplate_stageKey_key" UNIQUE ("stageKey")
);

-- CreateTable MilestoneExpectation
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

-- CreateTable VaccinationSchedule
CREATE TABLE "VaccinationSchedule" (
    "id" TEXT NOT NULL,
    "vaccineName" TEXT NOT NULL,
    "diseasePrevents" TEXT NOT NULL,
    "dueAgeMonths" DOUBLE PRECISION NOT NULL,
    "dueAgeWeeks" INTEGER,
    "doseNumber" INTEGER NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "VaccinationSchedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable ScreeningReminder
CREATE TABLE "ScreeningReminder" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "targetAgeDays" INTEGER NOT NULL,
    "screeningTool" TEXT NOT NULL,
    "targetAudience" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "ScreeningReminder_pkey" PRIMARY KEY ("id")
);

-- CreateTable UserRoutine
CREATE TABLE "UserRoutine" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "routineDate" TIMESTAMP(3) NOT NULL,
    "templateId" TEXT NOT NULL,
    "customizations" JSONB NOT NULL,
    "completedSteps" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "UserRoutine_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "UserRoutine_babyMonId_fkey" FOREIGN KEY ("babyMonId") REFERENCES "BabyMon"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "UserRoutine_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "RoutineTemplate"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable BabyMilestone
CREATE TABLE "BabyMilestone" (
    "id" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "expectationId" TEXT NOT NULL,
    "achievedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "BabyMilestone_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "BabyMilestone_babyMonId_fkey" FOREIGN KEY ("babyMonId") REFERENCES "BabyMon"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "BabyMilestone_expectationId_fkey" FOREIGN KEY ("expectationId") REFERENCES "MilestoneExpectation"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateIndex
CREATE INDEX "ExpertAdviceCard_stageKey_category_idx" ON "ExpertAdviceCard"("stageKey", "category");
CREATE INDEX "ExpertAdviceCard_category_idx" ON "ExpertAdviceCard"("category");
CREATE INDEX "ExpertAdviceCard_expertVoice_idx" ON "ExpertAdviceCard"("expertVoice");
CREATE INDEX "MilestoneExpectation_stageKey_domain_idx" ON "MilestoneExpectation"("stageKey", "domain");
CREATE INDEX "MilestoneExpectation_domain_idx" ON "MilestoneExpectation"("domain");
CREATE INDEX "VaccinationSchedule_dueAgeMonths_idx" ON "VaccinationSchedule"("dueAgeMonths");
CREATE INDEX "ScreeningReminder_targetAgeDays_idx" ON "ScreeningReminder"("targetAgeDays");
CREATE UNIQUE INDEX "UserRoutine_babyMonId_routineDate_key" ON "UserRoutine"("babyMonId", "routineDate");
CREATE INDEX "UserRoutine_babyMonId_idx" ON "UserRoutine"("babyMonId");
CREATE UNIQUE INDEX "BabyMilestone_babyMonId_expectationId_key" ON "BabyMilestone"("babyMonId", "expectationId");
CREATE INDEX "BabyMilestone_babyMonId_idx" ON "BabyMilestone"("babyMonId");
