/*
  Warnings:

  - Made the column `babymonId` on table `StageContent` required. This step will fail if there are existing NULL values in that column.

*/
-- CreateEnum
CREATE TYPE "ProposalStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterTable
ALTER TABLE "Badge" ADD COLUMN     "xpValue" INTEGER NOT NULL DEFAULT 10;

-- AlterTable
ALTER TABLE "StageContent" ALTER COLUMN "babymonId" SET NOT NULL;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "isActive" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "role" TEXT NOT NULL DEFAULT 'USER',
ADD COLUMN     "verificationExpires" TIMESTAMP(3),
ADD COLUMN     "verificationToken" TEXT;

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
    "type" TEXT NOT NULL,
    "value" DOUBLE PRECISION NOT NULL,
    "unit" TEXT NOT NULL,
    "measuredAt" TIMESTAMP(3) NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GrowthRecord_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PasswordResetToken_token_key" ON "PasswordResetToken"("token");

-- CreateIndex
CREATE UNIQUE INDEX "Device_deviceToken_key" ON "Device"("deviceToken");

-- CreateIndex
CREATE INDEX "Device_userId_idx" ON "Device"("userId");

-- CreateIndex
CREATE INDEX "Media_babyMonId_idx" ON "Media"("babyMonId");

-- CreateIndex
CREATE INDEX "Media_userId_idx" ON "Media"("userId");

-- CreateIndex
CREATE INDEX "Media_createdAt_idx" ON "Media"("createdAt");

-- CreateIndex
CREATE INDEX "GrowthRecord_babyMonId_idx" ON "GrowthRecord"("babyMonId");

-- CreateIndex
CREATE INDEX "GrowthRecord_measuredAt_idx" ON "GrowthRecord"("measuredAt");

-- CreateIndex
CREATE INDEX "BabyMon_ownerUserId_idx" ON "BabyMon"("ownerUserId");

-- CreateIndex
CREATE INDEX "BabyMon_deletedAt_idx" ON "BabyMon"("deletedAt");

-- CreateIndex
CREATE INDEX "FeedLog_babymonId_idx" ON "FeedLog"("babymonId");

-- CreateIndex
CREATE INDEX "FeedLog_authorUserId_idx" ON "FeedLog"("authorUserId");

-- CreateIndex
CREATE INDEX "FeedLog_happenedAt_idx" ON "FeedLog"("happenedAt");

-- CreateIndex
CREATE INDEX "FeedLog_deletedAt_idx" ON "FeedLog"("deletedAt");

-- CreateIndex
CREATE INDEX "HealthRecord_babymonId_idx" ON "HealthRecord"("babymonId");

-- CreateIndex
CREATE INDEX "HealthRecord_authorUserId_idx" ON "HealthRecord"("authorUserId");

-- CreateIndex
CREATE INDEX "HealthRecord_happenedAt_idx" ON "HealthRecord"("happenedAt");

-- CreateIndex
CREATE INDEX "HealthRecord_deletedAt_idx" ON "HealthRecord"("deletedAt");

-- CreateIndex
CREATE INDEX "LinkedAccount_userAId_idx" ON "LinkedAccount"("userAId");

-- CreateIndex
CREATE INDEX "LinkedAccount_userBId_idx" ON "LinkedAccount"("userBId");

-- CreateIndex
CREATE INDEX "LinkedAccount_status_idx" ON "LinkedAccount"("status");

-- CreateIndex
CREATE INDEX "LinkedBabyMon_userId_idx" ON "LinkedBabyMon"("userId");

-- CreateIndex
CREATE INDEX "LinkedBabyMon_babymonId_idx" ON "LinkedBabyMon"("babymonId");

-- CreateIndex
CREATE INDEX "Milestone_babymonId_idx" ON "Milestone"("babymonId");

-- CreateIndex
CREATE INDEX "Milestone_authorUserId_idx" ON "Milestone"("authorUserId");

-- CreateIndex
CREATE INDEX "Milestone_happenedAt_idx" ON "Milestone"("happenedAt");

-- CreateIndex
CREATE INDEX "Milestone_deletedAt_idx" ON "Milestone"("deletedAt");

-- CreateIndex
CREATE INDEX "StageContent_stageKey_idx" ON "StageContent"("stageKey");

-- AddForeignKey
ALTER TABLE "PasswordResetToken" ADD CONSTRAINT "PasswordResetToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Device" ADD CONSTRAINT "Device_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Media" ADD CONSTRAINT "Media_babyMonId_fkey" FOREIGN KEY ("babyMonId") REFERENCES "BabyMon"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Media" ADD CONSTRAINT "Media_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JournalProposal" ADD CONSTRAINT "JournalProposal_babymonId_fkey" FOREIGN KEY ("babymonId") REFERENCES "BabyMon"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GrowthRecord" ADD CONSTRAINT "GrowthRecord_babyMonId_fkey" FOREIGN KEY ("babyMonId") REFERENCES "BabyMon"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GrowthRecord" ADD CONSTRAINT "GrowthRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
