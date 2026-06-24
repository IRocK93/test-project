# BabyMon Code Quality Audit — v4

**Date:** 2026-06-22
**Overall Grade: C+**

---

## 1. DRY Violations

| # | Duplication | Files | Lines |
|---|------------|-------|-------|
| 1 | Stage calculation algorithm | `baby-mon.service.ts`, `companion.service.ts`, `stage-content.service.ts` | 3 implementations |
| 2 | History limit date filter | `feed-logs`, `milestones`, `health-records`, `sleep-logs`, `growth` | 5 identical copies |
| 3 | Access control verification | 7+ services | 3 different patterns |
| 4 | Create/Update DTO classes | `feed-logs`, `milestones`, `health-records`, `sleep-logs`, `baby-mon` | Full duplicate fields |
| 5 | `process.env` direct access | 15 files | Bypasses ConfigService |
| 6 | Error response construction | Multiple controllers | Mix of structured `{code}` and plain strings |
| 7 | Paginated response handling | Multiple services | Similar `{ items, total, skip, take }` construction |

---

## 2. God Functions

| Function/Method | File | Lines | Issue |
|----------------|------|-------|-------|
| `DashboardScreen.build()` | `dashboard_screen.dart` | 1464 total file | Massive widget with multiple responsibilities |
| `CreateBabyMonScreen` | `create_baby_mon_screen.dart` | 1800+ total file | Should be 4-5 smaller step widgets |
| `MainScreen.build()` | `main_screen.dart` | ~1000 lines | Handles tabs, FAB, drawer, navigation all in one |
| `CompanionService` | `companion.service.ts` | 378 lines | 3+ distinct responsibilities |
| `AuthService` | `auth.service.ts` | 358 lines | Registration, login, tokens, password reset |
| `StripeService` | `stripe.service.ts` | 306 lines | Webhook, checkout, billing portal |

---

## 3. Type Safety Violations

### TypeScript (Backend)
| Issue | Count | Locations |
|-------|-------|-----------|
| `@Body() body: any` | 5 | allergies, medical-team, media, photos controllers |
| `d: any` parameter | 1 | `medical-team.service.ts:13` |
| Inline body types (erased at runtime) | 4 | photos, subscriptions, admin |
| Direct `process.env` (no type safety) | 15 files | Various services |
| `@Request() req: any` | Multiple | Controllers |

### Dart (Mobile)
| Issue | Count | Locations |
|-------|-------|-----------|
| Missing type annotations | Several | `dynamic` inference in some callbacks |
| `as` casts without `is` checks | Few | API response handling |
| Late variables without initialization guarantee | Some | Screen state |

---

## 4. Magic Numbers & Strings

### Most Common Offenders
| Value | Used In | Should Be |
|-------|---------|-----------|
| `7` (days) | Refresh token, history limit, trial duration defaults | Named constant |
| `'dev-only-secret'` | `auth.service.ts:28` | Deleted — use ConfigService |
| `'babymon-jwt-secret-do-not-use-in-production'` | `auth.module.ts:17`, `jwt.strategy.ts:10` | Deleted |
| `1_000_000` (byte limit) | File size checks | Named constant |
| `50 * 1024 * 1024` | Media upload limit | Centralized config |
| `5 * 60 * 1000` (5 min) | Cache TTL | DesignTokens |
| `12` (seconds) | PremiumBackground animation | DesignTokens |

---

## 5. Naming Consistency Issues

| Issue | Examples |
|-------|----------|
| Inconsistent method prefixes | `getCurrentSubscription` vs `fetchCurrentPlan` patterns |
| Inconsistent parameter naming | `babyMonId` vs `babymonId` vs `id` across services |
| Screen naming patterns | Mix of `XxxScreen` and just `Xxx` |
| File naming patterns | Mix of snake_case and just concatenated names |
| Badge naming mismatch | `checkAndAwardBadges` uses different names than definitions |

---

## 6. Logging Hygiene

### Issues
| Issue | Severity | Detail |
|-------|----------|--------|
| Fire-and-forget without logging | MEDIUM | `.catch(() => {})` in feed-logs, milestones — errors silently discarded |
| StageContentService error swallowing | HIGH | All errors return fake data instead of logging |
| Inconsistent log levels | LOW | Some services use `console.log`, others use injected Logger |

### Strengths
- Pino structured logger on backend
- Configurable `LOG_LEVEL`
- Audit interceptor with structured audit events
- `GlobalExceptionFilter` logs all unhandled errors

---

## 7. Dead Code Candidates

| Candidate | Location | Assessment |
|-----------|----------|------------|
| `StripeWebhookController` | `stripe-webhook.controller.ts` | Duplicate, non-functional endpoint |
| `PhotosController` | `photos.controller.ts` | Duplicate of MediaController |
| `AuditInterceptor` | `common/interceptors/` | Well-tested but never registered |
| `RolesGuard` | `common/guards/` | Implemented but never applied |
| API version stripping in client | `api_client.dart` | Strips `/api/v1/` but backend has no versioning |
| `ContentSource.EXPERT` enum | `schema.prisma` | Never used in seed or code |
| `MilestoneDomain.MOTOR` enum | `schema.prisma` | Never used in seed or code |

---

## 8. Technical Debt Hotspots

| Hotspot | Debt Score | Reason |
|---------|-----------|--------|
| `dashboard_screen.dart` | 9/10 | 1464 lines, mixed concerns, hardcoded colors |
| `auth` screens (login/register) | 9/10 | Completely bypass theme system |
| `main_screen.dart` | 8/10 | Navigation, FAB, drawer, IndexedStack all in one |
| `companion.service.ts` | 7/10 | 378 lines, 3+ responsibilities |
| `create_baby_mon_screen.dart` | 8/10 | 1800+ lines, should be decomposed |
| `api_client.dart` | 7/10 | 46+ typed methods, no request deduplication |
| `app_router.dart` | 6/10 | Embedded legal docs, recreated on auth change |

---

## 9. Quick-Win Cleanup List

1. Delete `StripeWebhookController` — consolidate into StripeController
2. Delete or merge `PhotosController` into MediaController
3. Extract stage calculation to shared service — eliminates #1 DRY violation
4. Extract history filter to shared helper — eliminates 4 more DRY violations
5. Apply `PartialType` to Update DTOs — eliminates 5 file duplication patterns
6. Remove `'dev-only-secret'` fallback in auth.service.ts
7. Replace fire-and-forget `.catch(() => {})` with `.catch((err) => this.logger.warn(...))`
8. Fix StageContentService — don't return fake data on error
9. Remove unused enum values from Prisma schema
10. Standardize access control to use `AccessControlService` consistently
