-- Create SavedAdvice table for bookmarking expert advice cards
CREATE TABLE "SavedAdvice" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "adviceCardId" TEXT NOT NULL,
    "babyMonId" TEXT NOT NULL,
    "savedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "SavedAdvice_pkey" PRIMARY KEY ("id")
);

-- Create AdviceRating table for thumbs up/down feedback
CREATE TABLE "AdviceRating" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "adviceCardId" TEXT NOT NULL,
    "helpful" BOOLEAN NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AdviceRating_pkey" PRIMARY KEY ("id")
);

-- Add unique constraints
CREATE UNIQUE INDEX "SavedAdvice_userId_adviceCardId_key" ON "SavedAdvice"("userId", "adviceCardId");
CREATE UNIQUE INDEX "AdviceRating_userId_adviceCardId_key" ON "AdviceRating"("userId", "adviceCardId");

-- Add indices for common queries
CREATE INDEX "SavedAdvice_userId_idx" ON "SavedAdvice"("userId");
CREATE INDEX "SavedAdvice_babyMonId_idx" ON "SavedAdvice"("babyMonId");
CREATE INDEX "AdviceRating_adviceCardId_idx" ON "AdviceRating"("adviceCardId");

-- Add stageKey column to VaccinationSchedule for pregnancy/baby differentiation
ALTER TABLE "VaccinationSchedule" ADD COLUMN "stageKey" TEXT;
CREATE INDEX "VaccinationSchedule_stageKey_idx" ON "VaccinationSchedule"("stageKey");

-- Add stageKey column to ScreeningReminder for pregnancy/baby differentiation
ALTER TABLE "ScreeningReminder" ADD COLUMN "stageKey" TEXT;
CREATE INDEX "ScreeningReminder_stageKey_idx" ON "ScreeningReminder"("stageKey");
