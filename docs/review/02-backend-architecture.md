# 02 — Backend Architecture Audit

**Date:** 2026-06-17
**Severity Score:** 🟠 High (3 High, 7 Medium, 5 Low)
**Verdict:** Functionally complete but operationally immature. No configuration layer, god services, redundant cascade deletes, and inconsistent patterns block safe scaling.

---

## Summary

The BabyMon NestJS API is a **functionally complete** 25-module codebase with solid fundamentals — global Prisma module, Swagger documentation, rate limiting, pino logging, and proper module boundaries. However, it lacks a **configuration layer** entirely: all 30+ `process.env` reads are scattered across 13 files. Several services have grown into god classes (`auth.service` 346 lines, `linked-accounts.service` 308 lines, `stripe.service` 306 lines). The cascade-delete logic is **duplicated and redundant** — the Prisma schema already declares `onDelete: Cascade` on most child FKs, making the 11-table manual cascade in `baby-mon.service.ts` dead weight. Tier strings (`'CORE'`, `'AI_COMPANION'`) and badge tiers (`'BRONZE'`, `'SILVER'`) are raw literals with no Prisma enum. The `AuditService` exists but is bypassed — 5 services write audit logs directly via `prisma.auditLog.create`, defeating its error-safety wrapper. Pino is configured bare with no secret redaction and no request-ID correlation.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| BA01 | 🟠 High | **No `@nestjs/config` — 30 scattered `process.env` reads** | 13 files: `app.module.ts:37,43`; `auth.module.ts:12,13`; `auth.service.ts:10,11,54`; `jwt.strategy.ts:6,7`; `mail.service.ts:17,36,52,73,94`; `main.ts:17,70,78`; `notifications.service.ts:21`; `s3.service.ts:18-21,70`; `stripe.controller.ts:41,61`; `stripe.service.ts:11,118,271,272`; `subscriptions.controller.ts:26`; `subscriptions.service.ts:84` | JWT secret is read in 4 separate locations with 2 different hardcoded fallbacks. No config validation at startup. | Introduce `ConfigModule.forRoot({ validationSchema })` + inject `ConfigService`. Consolidate JWT config into `JwtModule.registerAsync`. |
| BA02 | 🟠 High | **God services** | `auth.service.ts` (346 LoC); `linked-accounts.service.ts` (308 LoC); `stripe.service.ts` (306 LoC); `growth.service.ts` (269 LoC); `export.service.ts` (233 LoC); `baby-mon.service.ts` (226 LoC); `badges.service.ts` (211 LoC) | `auth.service` handles: register, login, refresh, verify-email, forgot/reset password, profile, token issue, logout — 10 methods. `stripe.service` handles: customer/checkout/portal + webhook dispatcher + tier mapping + cancel — entire billing domain in one file. `export.service` has inline HTML templates (70 lines) mixed with export logic. | Split `AuthService` → `AuthService` + `TokenService` + `PasswordResetService`. Extract `StripeWebhookHandler`. Move HTML/CSV rendering out of `ExportService`. |
| BA03 | 🟠 High | **`BADGE_DEFINITIONS` is dead code; award logic hardcoded separately** | `apps/api/src/badges/badges.service.ts:4-122` vs `:144-210` | 86-line `BADGE_DEFINITIONS` table with 48 badges (categories, traits, xpValues) but `checkAndAwardBadges` hardcodes only 8 badge keys (`FIRST_MILESTONE`, `MILESTONES_5`, etc.) with mismatched names vs the definitions table. Two parallel sources of truth will drift. | Either drive awarding from `BADGE_DEFINITIONS` (data-driven) or delete the 118-line table. |
| BA04 | 🟡 Medium | **Cascade delete: 11-table manual loop is redundant** | `apps/api/src/baby-mon/baby-mon.service.ts:148-167` vs `schema.prisma` FK rules | 10 of 11 child FKs already declare `onDelete: Cascade` (`schema.prisma:161,186,210,236,255,272,338,363,389,403,425`). Only `AuditLog.babymonId` lacks `onDelete` — hence line 161 must NULL it. The `deleteMany` calls are dead code that will drift from schema. Same pattern duplicated in `users.service.ts:74-136`. | Set `AuditLog.babymonId` to `onDelete: SetNull` explicitly. Replace `baby-mon.service.ts:152-164` with single `babyMon.delete()`. |
| BA05 | 🟡 Medium | **Audit writes bypass `AuditService` error-safety wrapper** | 5 files: `baby-mon.service.ts:51,136`, `badges.service.ts:203`, `feed-logs.service.ts:50`, `health-records.service.ts:33`, `milestones.service.ts:54` | Services call `prisma.auditLog.create()` directly — if audit write fails, it throws and rolls back the business operation. `AuditService.log()` at `common/audit.service.ts:38-41` catches errors so audit failures are non-blocking. | Route all audit writes through `AuditService.log()`. |
| BA06 | 🟡 Medium | **XP/badge/level-up fan-out not transactional** | `feed-logs.service.ts:26-48`, `sleep-logs.service.ts:26-46`, `health-records.service.ts:15-31`, `milestones.service.ts:27-61` | Four sequential awaits: `create` → `babyMon.update(increment)` → `badgesService.checkAndAwardBadges` → `xpService.checkAndProcessLevelUp` → `auditLog.create`. Failure mid-sequence leaves XP awarded but no audit, or vice-versa. | Wrap in `prisma.$transaction(async tx => …)` and thread `tx` through `BadgesService`/`XpService`. |
| BA07 | 🟡 Medium | **pino configured bare — no redaction, no request-ID** | `apps/api/src/app.module.ts:35-39` | Only `level` is set. No `redact` for auth headers/passwords/refresh tokens. No `genReqId`. No `autoLogging` exclusion for `/health`. JWTs and passwords will be logged verbatim on error. | Add `redact: ['req.headers.authorization', 'req.body.password', 'req.body.refreshToken']` and `genReqId`. |
| BA08 | 🟡 Medium | **Services use Nest `Logger` not pino — bypasses structured JSON** | 10 files: `audit.service.ts:7`, `audit.interceptor.ts:11`, `growth.service.ts:54`, etc. | `new Logger(...)` in 10 files. One `console.error` at `auth.service.ts:85`. These go through Nest's default logger shim, not pino's JSON pipeline. | Inject pino logger (`@InjectPinoLogger`) or set `LoggerModule.forRootAsync` to make Nest `Logger` pino-backed. |
| BA09 | 🟡 Medium | **`PrismaService` has no graceful shutdown** | `apps/api/src/main.ts:1-87`, `prisma/prisma.service.ts:5-13` | `OnModuleDestroy` exists but `enableShutdownHooks(app)` is never called in `main.ts`. Container SIGTERM won't drain Prisma connections cleanly. | Add `app.enableShutdownHooks()` in `main.ts` after `app.listen()`. |
| BA10 | 🟡 Medium | **Feature modules leak cross-feature deps** | `auth.module.ts:28` imports `SubscriptionsModule`; `feed-logs.module.ts:8` imports `BadgesModule` | `AuthService` depends on `SubscriptionsService` to seed trial subscriptions — couples identity to billing. Badge outage blocks feed-logs writes. | Extract `UserSignupService` or emit `user.registered` event for `SubscriptionsModule` to handle. |
| BA11 | 🔵 Low | **Tier strings not enum'd** | `auth.service.ts:63`; `subscriptions.service.ts:16,96`; `stripe.service.ts:269,276,279` | `'CORE'` / `'AI_COMPANION'` scattered as raw strings. Badge tiers `'BRONZE'`/`'SILVER'` hardcoded 86 times in `BADGE_DEFINITIONS`. | Add `enum Tier { CORE AI_COMPANION }` and `enum BadgeTier { BRONZE SILVER GOLD DIAMOND }` to Prisma schema. |
| BA12 | 🔵 Low | **Mixed singular/plural feature folder naming** | `src/baby-mon/` (singular) vs `src/feed-logs/`, `linked-accounts/` (plural) vs `media/`, `health/` (singular) | Inconsistent naming slows navigation for new developers. | Standardize to plural-everywhere or singular-everywhere. |
| BA13 | 🔵 Low | **Swallowed errors** | `notifications.service.ts:72` (`.catch(() => {})`), `journal.service.ts:80` (`try { JSON.parse() } catch {}`) | Device deletion errors silently swallowed. Malformed journal payloads silently treated as empty. | Log at `warn` level with error object. For journal, return 400 instead. |
| BA14 | 🔵 Low | **Inconsistent REST routing styles** | 8 controllers: `allergies`, `feed-logs`, `health-records`, `linked-accounts`, `media/photos`, `medical-team`, `milestones`, `sleep-logs` | `@Controller()` (empty) with fully-qualified method paths vs class-level prefix (`@Controller('baby-mons')`). Mixed within same module (linked-accounts). | Standardize on class-level prefix + nested-resource paths. |
| BA15 | 🔵 Low | **Naming: `babymonId` vs `babyMonId` in schema** | `schema.prisma:353` (Media uses `babyMonId`) vs `:161` (Milestone uses `babymonId`) | Two different camelCase conventions for the same column across models. | Standardize to one (recommend `babyMonId` with capital M). |

---

## Things Done Well

1. **Global Prisma module with lifecycle** — `prisma.module.ts` is `@Global()`; `PrismaService` implements `OnModuleInit`/`OnModuleDestroy`.
2. **Transactions where it matters** — `$transaction` used for user registration + trial creation, password reset + token revoke, badge awarding (with race-condition comment), account deletion.
3. **`AccessControlService` as shared abstraction** — centralizes owner + linked co-parent checks; reused by 7+ services.
4. **Health endpoint real DB check** — `SELECT 1` with latency reporting; separate `/live` and `/ready` probes follow Kubernetes conventions.
5. **DTO validation globally enforced** — `ValidationPipe` with `whitelist`, `forbidNonWhitelisted`, `transform`.
6. **Stripe webhook raw body correctly preserved** — `main.ts:24-29` keeps raw body for signature verification before JSON parsing.
7. **Soft-delete consistently applied** across mutable entities; `findAll` queries filter `deletedAt: null`.
8. **Swagger structured** — `DocumentBuilder` with tagged grouping and `@ApiBearerAuth`.
9. **Pagination on core resources** — `{ items, total, skip, take }` envelope with capped `take` via `PaginationDto`.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | Introduce `@nestjs/config` with Zod/Joi schema. Replace 30 `process.env` reads with `ConfigService`. | L |
| 2 | Add Prisma enums for Tier, BadgeTier. Replace string literals. Regenerate client. | S |
| 3 | Drive badge awarding from `BADGE_DEFINITIONS` or delete the dead table. | M |
| 4 | Set `AuditLog.babymonId` to `onDelete: SetNull`. Replace manual cascade with FK cascade. | M |
| 5 | Route all audit writes through `AuditService.log()`. Register `AuditInterceptor` or remove it. | S |
| 6 | Wrap XP/badge/level-up in `$transaction` for create operations. | M |
| 7 | Harden pino: add `redact`, `genReqId`. Switch all `new Logger()` to injected pino logger. | M |
| 8 | Add `enableShutdownHooks()` in `main.ts`. | S |
| 9 | Decompose god services (auth, stripe, export, growth, linked-accounts). | L |
| 10 | Standardize controller routing on class-level prefix. | M |
| 11 | Fix swallowed errors in notifications and journal services. | S |
| 12 | Decouple `AuthModule` from `SubscriptionsModule` via event pattern. | M |
| 13 | Standardize folder naming and FK column casing. | S |
