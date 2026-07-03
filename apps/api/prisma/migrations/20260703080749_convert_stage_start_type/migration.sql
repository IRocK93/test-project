/*
  Warnings:

  - Changed the type of `stageStartType` on the `BabyMon` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- CreateEnum
CREATE TYPE "StageStartType" AS ENUM ('PLAN', 'INCUBATING', 'BORN');

-- AlterTable
ALTER TABLE "BabyMon" DROP COLUMN "stageStartType",
ADD COLUMN     "stageStartType" "StageStartType" NOT NULL;

-- AlterTable
ALTER TABLE "ScreeningReminder" ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en';

-- AlterTable
ALTER TABLE "VaccinationSchedule" ADD COLUMN     "locale" TEXT NOT NULL DEFAULT 'en';

-- CreateIndex
CREATE INDEX "ScreeningReminder_dueAgeMonths_locale_idx" ON "ScreeningReminder"("dueAgeMonths", "locale");

-- CreateIndex
CREATE INDEX "VaccinationSchedule_dueAgeMonths_locale_idx" ON "VaccinationSchedule"("dueAgeMonths", "locale");
