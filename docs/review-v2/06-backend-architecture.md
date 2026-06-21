# S06 — Backend Architecture Audit

**Date:** 2026-06-18 | **Overall Severity:** 🟠 High

The NestJS backend has 28 modules with good module boundaries but suffers from **inconsistent internal patterns**: some services are fully wired (milestones, feeding: access control + XP + badges + proposals + undo), while others are completely bare (allergies, medical-team: no auth, no XP, no badges). Dead code is scattered throughout, and critical infrastructure (config module, global error filter, audit interceptor) is missing.

---

## Findings

### BA-C01 | 🔴 CRITICAL | Two Competing Access Control Models

**Location:** Across 10+ services

**What:** Three different access control patterns coexist:
1. **AccessControlService** (proper) — used by milestones, feed-logs, health-records, growth (read)
2. **Inline owner check** — growth (write), media, export, journal
3. **No access control** — allergies, medical-team, sleep-logs (swapped args)

No clear rule for which pattern to use. Services that use AccessControlService don't always check the return value. Services that do inline checks use different logic (LinkedAccount vs LinkedBabyMon).

**Remediation:** Standardize on AccessControlService for ALL services. Add a `verifyAccessOrThrow()` method that throws instead of returning boolean. Remove all inline access checks.

---

### BA-C02 | 🔴 CRITICAL | SleepLogs — Access Control Argument Swap (Active Bug)

**Location:** `apps/api/src/sleep-logs/sleep-logs.service.ts`

**What:** `AccessControlService.checkAccess(userId, babyMonId)` is called as `checkAccess(babymonId, userId)` — arguments swapped. The return value is never checked. Every access control check passes for the wrong reason.

**Remediation:** Fix argument order and check return value: `const { hasAccess } = await this.accessControl.checkAccess(userId, babymonId)`.

---

### BA-C03 | 🔴 CRITICAL | No Config Module — 30+ process.env References Scattered

**Location:** Across entire backend

**What:** Environment variables accessed directly via `process.env.VARIABLE` in 30+ locations. No validation, no defaults management, no type safety. Key examples: 3 different JWT fallback secrets (auth.service.ts, auth.module.ts, jwt.strategy.ts all have different defaults), Stripe price IDs, S3 region, database URL.

**Remediation:** Create a `ConfigModule` with `@nestjs/config` and `Joi` validation. Export typed config service. Remove all direct `process.env` access.

---

### BA-C04 | 🔴 CRITICAL | No Global Exception Filter

**Location:** Absent from codebase (no `.filter.ts` files)

**What:** Errors propagate directly from services (throwing NestJS exceptions) to controllers to clients. No centralized error transformation, no error code standardization, no PII scrubbing from error messages. Prisma errors (unique constraints, foreign keys) leak database schema details.

**Remediation:** Create `GlobalExceptionFilter` implementing `ExceptionFilter`. Map Prisma errors to user-friendly messages. Log full errors server-side. Standardize error response shape.

---

### BA-H01 | 🟠 HIGH | AuditInterceptor Not Wired as APP_INTERCEPTOR

**Location:** `apps/api/src/common/interceptors/audit.interceptor.ts` vs `app.module.ts`

**What:** `AuditInterceptor` is a well-implemented interceptor that logs requests to AuditLog table. But it's NOT registered as `APP_INTERCEPTOR` in `app.module.ts`. It exists but never fires.

**Remediation:** Add `{ provide: APP_INTERCEPTOR, useClass: AuditInterceptor }` to AppModule providers.

---

### BA-H02 | 🟠 HIGH | Dead Code: StripeWebhookController (Silent Webhook Acceptance)

**Location:** `apps/api/src/stripe/stripe-webhook.controller.ts`

**What:** Registers at `POST /webhooks/stripe`, accepts any payload without signature verification, returns `{ received: true }`. Dead code that silently accepts forged webhooks.

**Remediation:** Delete the controller and its module registration.

---

### BA-H03 | 🟠 HIGH | Dead Code: SubscriptionWriteGuard Never Applied

**Location:** `apps/api/src/common/guards/subscription-write.guard.ts`

**What:** Guard implements write-gating based on subscription/trial status but is never applied to any controller. Trial-expired users can write data unimpeded.

**Remediation:** Apply to all write-enabled controllers, or delete the dead code.

---

### BA-H04 | 🟠 HIGH | Duplicate Public Decorator

**Location:** `auth/decorators/public.decorator.ts` and `common/decorators/public.decorator.ts`

**What:** Two identical files defining `IS_PUBLIC_KEY = 'isPublic'`. Works because string value is identical, but fragile.

**Remediation:** Delete `auth/decorators/public.decorator.ts`. Keep only the common one.

---

### BA-H05 | 🟠 HIGH | AdminModule — Implicit PrismaModule Dependency

**Location:** `apps/api/src/admin/admin.module.ts`

**What:** AdminModule does not import PrismaModule but AdminService depends on PrismaService. Relies on PrismaModule being global. Implicit dependency.

**Remediation:** Add `PrismaModule` to AdminModule imports for explicit dependency declaration.

---

### BA-M01 | 🟡 MEDIUM | Inconsistent Transaction Patterns

**Location:** Various services

**What:** Some services use Prisma `$transaction` for multi-step operations (milestones, feed-logs, baby-mon delete). Others perform sequential operations without transactions (journal proposals approve/reject has separate update calls). Risk of partial state on failure.

**Remediation:** Wrap all multi-step mutations in `prisma.$transaction`.

---

### BA-M02 | 🟡 MEDIUM | Manual + Cascade Delete — Dual Deletion with Gaps

**Location:** `baby-mon.service.ts:148-167`, `users.service.ts:86-114`

**What:** BabyMon delete manually cascades to milestones, feedLogs, healthRecords, badges, stageContent, linkedBabyMon, media, growthRecords, auditLog, entryChangeProposal, journalProposal. BUT misses: sleepLogs, allergies, allergyEvents, medicalTeams, babyMilestones, userRoutines. These rely on Prisma schema `onDelete: Cascade`. Inconsistent and fragile.

**Remediation:** Standardize on one approach. Either rely exclusively on Prisma cascade (and ensure all relations have it) or manually delete all models. Add integration tests.

---

### BA-M03 | 🟡 MEDIUM | No Request ID / Correlation ID

**Location:** `main.ts`, logging middleware

**What:** No request ID generated for tracing requests across logs. Pino logger is configured but without correlation IDs, debugging multi-service issues is difficult.

**Remediation:** Add request ID middleware. Include in all log lines. Return in response headers.

---

### BA-M04 | 🟡 MEDIUM | Hardcoded Rate Limit Values

**Location:** `app.module.ts`

**What:** ThrottlerModule limits (AUTH: 30/min, SENSITIVE: 20/min, DEFAULT: 100/min) are hardcoded. No environment variable override.

**Remediation:** Move rate limit values to configuration.

---

### BA-L01 | 🔵 LOW | Inconsistent Controller Path Strategies

**What:** Some controllers nest paths (`@Controller('baby-mons/:babyMonId/growth')`), others put on each route (`@Controller()` with `@Get('baby-mons/:babyMonId/milestones')`). Both work but lack consistency.

---

### BA-L02 | 🔵 LOW | ExportService HTML Method Not Exposed

**Location:** `apps/api/src/export/export.service.ts`

**What:** `exportBabyMon()` generates HTML export but is not exposed via any controller endpoint. Only JSON/CSV endpoints are wired.

---

### BA-L03 | 🔵 LOW | JournalService Uses Different Access Model Than AccessControlService

**Location:** `apps/api/src/journal/journal.service.ts`

**What:** JournalService checks `linkedAccount` directly (with missing `status: 'LINKED'` filter — see S01-02). AccessControlService checks `linkedBabyMon`. Two different models for the same concept.

**Remediation:** Migrate JournalService to use AccessControlService.

---

## Module Dependency Map

**Global modules:** PrismaModule (global), ThrottlerModule (global)
**Modules with implicit dependencies:** AdminModule (relies on global PrismaModule)
**Clean modules:** AuthModule, UsersModule, BabyMonModule, MilestonesModule, FeedLogsModule, HealthRecordsModule, SleepLogsModule, AllergiesModule, GrowthModule, BadgesModule, EvolutionModule, XpModule, StageContentModule, CompanionModule, LinkedAccountsModule, SubscriptionsModule, StripeModule, S3Module, MediaModule, ExportModule, NotificationsModule, MailModule, JournalModule, MedicalTeamModule

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 4 |
| 🟠 High | 5 |
| 🟡 Medium | 4 |
| 🔵 Low | 3 |
| **Total** | **16** |
