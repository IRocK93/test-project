import { SubscriptionsService } from '../subscriptions/subscriptions.service';

/**
 * Shared helper to build a date filter for FREE-tier history limits.
 * Used by feed-logs, milestones, health-records, sleep-logs, and growth services.
 */
export async function buildHistoryDateFilter(
  subscriptionsService: SubscriptionsService,
  userId: string,
  dateField: string = 'happenedAt',
): Promise<Record<string, { gte: Date }> | Record<string, never>> {
  const historyDays = await subscriptionsService.getHistoryLimitDays(userId);
  if (!historyDays) return {};
  return {
    [dateField]: { gte: new Date(Date.now() - historyDays * 24 * 60 * 60 * 1000) },
  };
}
