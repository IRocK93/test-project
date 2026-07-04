-- CreateIndex
CREATE INDEX "FeedLog_syncStatus_idx" ON "FeedLog"("syncStatus");

-- CreateIndex
CREATE INDEX "HealthRecord_syncStatus_idx" ON "HealthRecord"("syncStatus");

-- CreateIndex
CREATE INDEX "Media_s3Key_idx" ON "Media"("s3Key");

-- CreateIndex
CREATE INDEX "Milestone_syncStatus_idx" ON "Milestone"("syncStatus");

-- CreateIndex
CREATE INDEX "SleepLog_syncStatus_idx" ON "SleepLog"("syncStatus");

-- CreateIndex
CREATE INDEX "Subscription_stripeSubscriptionId_idx" ON "Subscription"("stripeSubscriptionId");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "User"("role");

