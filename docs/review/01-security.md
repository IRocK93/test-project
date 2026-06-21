# 01 — Security Audit

**Date:** 2026-06-17
**Severity Score:** 🔴 Critical (6 Critical, 5 High, 3 Medium)
**Verdict:** Would fail a security audit. Active secret leak + multiple privilege-escalation bugs.

---

## Summary

The BabyMon API has sound fundamentals — bcrypt cost 12, refresh-token rotation, global `ValidationPipe` with `forbidNonWhitelisted`, and Stripe webhook signature verification. However, these are undermined by a **committed `.env` file containing live production database credentials** and a weak hardcoded JWT secret, **three IDOR/access-control bugs** (two creating privilege escalation, one a no-op authorization gate), and a **fail-open JWT fallback** that silently signs/verifies tokens with known dev secrets unless `NODE_ENV` is exactly `'production'`. The Flutter app's social login is entirely simulated with fake tokens. No Helmet. No CSRF. The `AuditInterceptor` (138 lines) is dead code — never wired. This is a **high-severity security posture** that must be addressed before production use, especially given the children's health data the app handles.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| S01 | 🔴 Critical | **`.env` committed with live Neon DB password + JWT secret** | `apps/api/.env:1-2` | `DATABASE_URL="postgresql://neondb_owner:npg_GUVJ5Ep1XurA@..."` and `JWT_SECRET="babymon-jwt-secret-key-change-in-production-2024"`. No `.gitignore` exists at `apps/api/` level. | Rotate Neon credentials immediately. Add `.gitignore` with `.env`. Scrub git history. Use `@nestjs/config` + `ConfigService` instead of direct `process.env` reads. |
| S02 | 🔴 Critical | **IDOR — `milestones.create()` has no access check** | `apps/api/src/milestones/milestones.service.ts:17-39` | Only checks `babyMon.findFirst()` for existence (line 19-25). Never calls `verifyAccess(babymonId, userId)`. Compare: `findAll()` calls `verifyAccess` on line 67. **Any authenticated user can create milestones on any BabyMon.** | Add `await this.verifyAccess(babymonId, userId);` between lines 25-27, before any data mutation. |
| S03 | 🔴 Critical | **IDOR — `feed-logs.create()` has no access check** | `apps/api/src/feed-logs/feed-logs.service.ts:17-39` | Identical pattern: existence check only (lines 18-24). `findAll()` calls `verifyAccess` on line 63. **Any authenticated user can post feed logs to any BabyMon.** | Add `await this.verifyAccess(babymonId, userId);` between lines 24-26. |
| S04 | 🔴 Critical | **`health-records.verifyAccess` is a no-op** | `apps/api/src/health-records/health-records.service.ts:109-111` | `await this.accessControl.checkAccess(userId, babymonId);` — the `hasAccess` return value is **never checked**, no `ForbiddenException` thrown. Compare correct implementation in `milestones.service.ts:187-192`. Also: `health-records.create()` (line 11) never calls `verifyAccess` at all — same IDOR as S02/S03. | Destructure `const { hasAccess } = await ...` then `if (!hasAccess) throw new ForbiddenException(...)`. Add `verifyAccess` call to `create()`. |
| S05 | 🔴 Critical | **JWT secret fail-open — 3 copies, 2 different dev fallbacks** | `auth.service.ts:10-14`, `auth.module.ts:11-16`, `jwt.strategy.ts:6-10` | All 3 check `if (!jwtSecret && process.env.NODE_ENV === 'production') throw ...` — falls through to `safeJwtSecret = jwtSecret \|\| 'hardcoded'` when `NODE_ENV` is anything other than `'production'` literally (e.g., `'staging'`, `'prod'`, unset). `auth.service.ts` falls back to `'dev-only-secret'` while the other two fall back to `'babymon-jwt-secret-do-not-use-in-production'` — two **different** fallbacks could cause token mismatch. | Centralize in one place via `ConfigModule` + `ConfigService`. Throw if `JWT_SECRET` is unset regardless of `NODE_ENV`. Use `JwtModule.registerAsync`. |
| S06 | 🔴 Critical | **Social login is fully simulated — fake tokens** | `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart:159,204,238` | `googleLogin()` creates `User(id: 'google-${timestamp}')` with TODO: "Send ID token to backend for verification". Same for Apple and Facebook. No backend OAuth endpoints exist. Anyone can log in with any social provider without owning the account. | Implement real backend token verification for Google/Apple/Facebook. Remove the simulated implementations. |
| S07 | 🟠 High | **`AuditInterceptor` is dead code — never registered** | `apps/api/src/common/interceptors/audit.interceptor.ts` (138 lines) | Full implementation exists with event routing, babyMonId extraction, IP/user-agent capture. But `app.module.ts` only provides `AuditService` (line 74) — no `APP_INTERCEPTOR` for `AuditInterceptor`. Services write audit logs directly via `prisma.auditLog.create` (5 files), bypassing the `AuditService`'s error-safe `log()` method which catches failures so audit errors don't crash requests. | Either: (a) register `AuditInterceptor` as `APP_INTERCEPTOR` in `app.module.ts` and remove direct `prisma.auditLog.create` calls, or (b) delete the interceptor and route all audit writes through `AuditService.log()`. |
| S08 | 🟠 High | **No Helmet (security headers)** | `apps/api/package.json`, `apps/api/src/main.ts` | No `helmet` package installed. No security headers (X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Strict-Transport-Security, Content-Security-Policy). | Install `helmet` (`npm i helmet`) and add `app.use(helmet())` in `main.ts` before any routes. |
| S09 | 🟠 High | **No CSRF protection** | `apps/api/src/main.ts` | No `csurf` or `@nestjs/platform-express` CSRF middleware. JWT bearer tokens provide some CSRF resistance but state-changing endpoints should have additional protection. | Add `csurf` or cookie-based CSRF token for sensitive mutations. At minimum, ensure `SameSite` cookies. |
| S10 | 🟠 High | **Token stored in both Secure Storage AND SharedPreferences** | `apps/mobile/lib/features/auth/data/datasources/auth_remote_datasource.dart` | `isLoggedIn()` checks `_prefs.containsKey('accessToken')` — reading from `SharedPreferences` (plaintext) instead of `FlutterSecureStorage`. The token is written to both stores. | Use `FlutterSecureStorage` as single source of truth. Remove duplicate `SharedPreferences` writes. |
| S11 | 🟠 High | **Hardcoded emulator URL in Flutter constants** | `apps/mobile/lib/core/constants/api_constants.dart:3` | `static const String baseUrl = 'http://10.0.2.2:3000';` — HTTP not HTTPS. No environment switching. Same URL used in all builds. | Use `--dart-define=API_BASE_URL=https://api.babymon.com` for release builds. Add `envied` package for compile-time injection. |
| S12 | 🟡 Medium | **RATE_LIMIT_TTL unit mismatch** | `apps/api/src/app.module.ts:43` vs `.env.example` | Code: `parseInt(process.env.RATE_LIMIT_TTL \|\| '60000', 10)` — treats value as **milliseconds** (default 60s = 60000ms). `.env.example` shows `RATE_LIMIT_TTL=60` (would be 60ms = essentially disabled). | Document clearly: "RATE_LIMIT_TTL in milliseconds". Change default to `60000` and example to `RATE_LIMIT_TTL=60000`. |
| S13 | 🟡 Medium | **`dev-override-trial` is `@Public()`** | `apps/api/src/subscriptions/subscriptions.controller.ts:21-30` | `@Public()` decorator — only protection is runtime `NODE_ENV === 'production'` check. If misconfigured, anyone can override trial periods. | Remove `@Public()`. Require admin auth. Or remove the endpoint entirely and use admin panel. |
| S14 | 🟡 Medium | **No access-log throttler on file upload** | `apps/api/src/media/media.controller.ts:14` | `@Post('upload')` accepts `@Body() body: any` with base64 data — no rate limit override. A malicious user can spam large uploads. | Add `@Throttle({ default: { limit: 10, ttl: 60000 } })` or similar to media endpoints. |

---

## Things Done Well

1. **bcrypt cost 12** — `auth.service.ts` uses `bcrypt.hash(password, 12)`. Industry-standard cost.
2. **Refresh-token rotation** — `auth.service.ts:140-195` revokes old token before issuing new pair. Good protection against token theft replay.
3. **Global ValidationPipe hardened** — `main.ts:35-44`: `whitelist: true, forbidNonWhitelisted: true, transform: true`. Strips and rejects unknown JSON properties app-wide.
4. **Stripe webhook signature verified** — `stripe.service.ts:126` checks `stripe.webhooks.constructEvent()` with `STRIPE_WEBHOOK_SECRET`.
5. **Stripe idempotency** — `StripeEvent` table with `@unique([eventId])` prevents duplicate webhook processing.
6. **Rate limiting tiers** — AUTH (30/min), SENSITIVE (20/min), DEFAULT (100/min) with per-route overrides.
7. **`FlutterSecureStorage`** is used for token storage (alongside the SharedPreferences duplicate).
8. **Access control service centralized** — `AccessControlService.checkAccess()` handles owner + linked co-parent access with VIEW/EDIT levels.
9. **Validation pipe + class-validator DTOs** on core resources (auth, baby-mon, milestones, feed-logs, sleep-logs, health-records).

---

## Action Plan

| # | Action | Effort | Finds addressed |
|---|---|---|---|
| 1 | **Rotate all exposed credentials.** Delete `.env` from disk & git history. Add `.gitignore` at `apps/api/`. | S | S01 |
| 2 | **Fix IDOR bugs.** Add `this.verifyAccess()` to `milestones.create()`, `feed-logs.create()`, and `health-records.create()`. Fix `health-records.verifyAccess` to actually check `hasAccess`. | S | S02, S03, S04 |
| 3 | **Centralize JWT config.** Adopt `@nestjs/config` + `ConfigModule`. Throw if `JWT_SECRET` missing regardless of `NODE_ENV`. Single source of truth. | M | S05 |
| 4 | **Implement real social login.** Verify Google/Apple/Facebook ID tokens on the backend. Add OAuth endpoints. Remove simulated login. | L | S06 |
| 5 | **Wire AuditInterceptor** as `APP_INTERCEPTOR`. Route all audit writes through `AuditService.log()`. | S | S07 |
| 6 | **Add Helmet** (`npm i helmet`, `app.use(helmet())`). | S | S08 |
| 7 | **Fix token storage.** Use `FlutterSecureStorage` only. Remove `SharedPreferences` duplicate. | S | S10 |
| 8 | **Environment-based API URL.** Add `--dart-define` for flutter build. Use HTTPS. | S | S11 |
| 9 | **Fix rate limit TTL documentation.** Clarify milliseconds vs seconds. | S | S12 |
| 10 | **Gate `dev-override-trial`** behind admin auth. Remove `@Public()`. | S | S13 |
| 11 | **Add CSRF protection.** Evaluate `csurf` or `SameSite` cookie approach. | M | S09 |
| 12 | **Add upload rate limiting** on media endpoints. | S | S14 |
