/**
 * Shared 10-minute undo-window helper.
 *
 * Multiple services (milestones, feed-logs, health-records) had duplicated
 * inline logic to check whether an entry was created within the last N minutes.
 * This helper centralises that check so the window duration can be changed in
 * one place and all services stay consistent.
 */

/**
 * Returns `true` if `createdAt` is within `windowMinutes` of the current time.
 * Default window is 10 minutes.
 */
export function isWithinUndoWindow(
  createdAt: Date | string,
  windowMinutes = 10,
): boolean {
  const created = new Date(createdAt).getTime();
  const now = Date.now();
  const diffMs = now - created;
  return diffMs / (1000 * 60) <= windowMinutes;
}
