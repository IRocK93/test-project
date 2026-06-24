import { PrismaClient } from '@prisma/client';

/**
 * Upsert a DailyActivity row when an entry is created.
 * Call this from each entry-creation service (milestones, feed-logs, etc.)
 * to enable streak-based badge detection.
 */
export async function trackDailyActivity(
  tx: Omit<PrismaClient, '$connect' | '$disconnect' | '$on' | '$transaction' | '$use' | '$extends'>,
  babymonId: string,
  type: 'milestone' | 'feedLog' | 'sleepLog' | 'healthRecord' | 'growthRecord',
) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const fieldMap = {
    milestone: 'hasMilestone',
    feedLog: 'hasFeedLog',
    sleepLog: 'hasSleepLog',
    healthRecord: 'hasHealthRecord',
    growthRecord: 'hasGrowthRecord',
  };

  const field = fieldMap[type];

  await (tx as any).dailyActivity.upsert({
    where: { babymonId_date: { babymonId, date: today } },
    create: { babymonId, date: today, [field]: true },
    update: { [field]: true },
  });
}
