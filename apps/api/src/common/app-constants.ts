/**
 * Application-wide named constants.
 *
 * Replaces magic numbers scattered across services with a single source of truth.
 * All time/duration values are in milliseconds unless suffixed otherwise.
 */

// ── Durations ──────────────────────────────────────────────────
export const MS_PER_SECOND = 1000;
export const MS_PER_MINUTE = 60 * MS_PER_SECOND;
export const MS_PER_HOUR = 60 * MS_PER_MINUTE;
export const MS_PER_DAY = 24 * MS_PER_HOUR;

// ── Change Proposal / Undo Window ──────────────────────────────
/** Number of days a user can directly edit/delete their own entry (undo window). */
export const UNDO_WINDOW_DAYS = 7;
/** Number of days a change proposal stays open for partner review. */
export const PROPOSAL_EXPIRY_DAYS = 7;

// ── Auth ───────────────────────────────────────────────────────
/** Password reset token validity in hours. */
export const RESET_TOKEN_EXPIRY_HOURS = 1;
/** Default JWT access token TTL (seconds). */
export const JWT_ACCESS_TTL_SECONDS = 15 * 60; // 15 minutes
/** Default JWT refresh token TTL (days). */
export const JWT_REFRESH_TTL_DAYS = 7;
/** Rate limit TTL (ms) for auth endpoints. */
export const AUTH_RATE_LIMIT_TTL_MS = 60_000; // 1 minute
/** Maximum auth attempts per TTL window. */
export const AUTH_RATE_LIMIT_MAX = 5;

// ── Subscriptions ──────────────────────────────────────────────
/** Default trial duration in days. */
export const DEFAULT_TRIAL_DAYS = 14;
/** Buffer days after trial expiry before restricting features. */
export const TRIAL_GRACE_PERIOD_DAYS = 3;

// ── Media / Uploads ────────────────────────────────────────────
/** Maximum upload file size in bytes (50 MB). */
export const MAX_UPLOAD_SIZE_BYTES = 50 * 1024 * 1024;

// ── Data Retention ─────────────────────────────────────────────
/** Days before soft-deleted records are hard-deleted by the purge job. */
export const DATA_RETENTION_DAYS = 90;

// ── API ────────────────────────────────────────────────────────
/** Default pagination page size. */
export const DEFAULT_PAGE_SIZE = 20;
/** Maximum items per page. */
export const MAX_PAGE_SIZE = 100;
/** Default rate limit TTL (ms) for general endpoints. */
export const DEFAULT_RATE_LIMIT_TTL_MS = 60_000;
/** Default max requests per TTL window. */
export const DEFAULT_RATE_LIMIT_MAX = 100;

// ── XP / Gamification ──────────────────────────────────────────
/** Base XP awarded for a single feeding/milestone/sleep/health log. */
export const BASE_XP_PER_LOG = 5;
/** XP required for level 2 (each subsequent level scales). */
export const BASE_XP_FOR_LEVEL = 50;

// ── Dashboard ──────────────────────────────────────────────────
/** Cooldown between dashboard data refreshes (ms). */
export const DASHBOARD_REFRESH_COOLDOWN_MS = 10_000; // 10 seconds
/** Background timeout before forcing a dashboard refresh (ms). */
export const DASHBOARD_BACKGROUND_TIMEOUT_MS = 5 * MS_PER_MINUTE;
