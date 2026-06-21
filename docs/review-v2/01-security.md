# S01 — Security Audit

**Date:** 2026-06-18 | **Overall Severity:** 🔴 Critical
**Scope:** NestJS API (27 modules) + Flutter Mobile + Infrastructure

---

## Things Done Well

1. **Password hashing** uses bcryptjs with cost factor 12 — solid choice
2. **DTO validation** with `class-validator`: `whitelist: true, forbidNonWhitelisted: true` correctly enabled in `ValidationPipe` in `main.ts`
3. **Password policies** require 8+ chars, upper, lower, and digit in `RegisterDto` and `ResetPasswordDto`
4. **Rate limiting** via `@nestjs/throttler` applied globally and tightened on auth endpoints (5/min login/register, 3/min forgot-password)
5. **Token type checking** in `refreshTokens()` (`payload.type !== 'refresh'`) prevents access-token-for-refresh substitution
6. **Refresh token rotation** — old refresh tokens revoked on use and password reset
7. **Soft deletion** used consistently; users with `deletedAt` set cannot log in
8. **Stripe webhook** signature verification uses `constructEvent()` with `STRIPE_WEBHOOK_SECRET`
9. **Idempotent Stripe event processing** via `stripeEvent` deduplication table
10. **AccessControlService** centralizes ownership + co-parent lookup (when used correctly)
11. **`.env` correctly gitignored** — not tracked in git
12. **Swagger** configured with Bearer auth
13. **Admin endpoints** properly guarded with `@Roles('ADMIN')` + `RolesGuard`
14. **Firm error messages** in login avoid user enumeration
15. **Co-parent proposal system** with 7-day expiry and explicit accept/reject flow

---

## Findings

### S01-01 | 🔴 CRITICAL | Access Control Bypass — SleepLogs

**Location:** `apps/api/src/sleep-logs/sleep-logs.service.ts:24,52,84,98,122`

**What:** `AccessControlService.checkAccess(userId, babyMonId)` expects `(userId, babyMonId)` but every call passes `(babymonId, userId)` — arguments are swapped. Additionally, the return value `{ hasAccess }` is never checked; `checkAccess` is called as fire-and-forget. Any authenticated user can create, read, update, and delete sleep logs for any BabyMon.

**Evidence:**
```typescript
await this.accessControl.checkAccess(babymonId, userId); // Swapped args
// Result completely ignored — no error thrown
```

**Remediation:** Swap argument order to `(userId, babymonId)` and check the return value:
```typescript
const { hasAccess } = await this.accessControl.checkAccess(userId, babymonId);
if (!hasAccess) throw new ForbiddenException('Access denied');
```

---

### S01-02 | 🔴 CRITICAL | Journal Access Control — Missing LINKED Status Filter

**Location:** `apps/api/src/journal/journal.service.ts:18-21`

**What:** The `checkAccess` method queries `linkedAccount` without filtering `status: 'LINKED'`. Any record in the `linkedAccount` table (including `PENDING`, `REJECTED`, or expired invitations) between two users grants access. An attacker who has ever sent or received a co-parent invitation retains permanent journal access.

**Evidence:**
```typescript
const linked = await this.prisma.linkedAccount.findFirst({
  where: { OR: [{ userAId: userId, userBId: babyMon.ownerUserId }, 
                { userBId: userId, userAId: babyMon.ownerUserId }] },
  // MISSING: status: 'LINKED'
});
```

**Remediation:** Add `status: 'LINKED'` to both OR conditions.

---

### S01-03 | 🔴 CRITICAL | AllergiesService — Zero Access Control

**Location:** `apps/api/src/allergies/allergies.service.ts` (entire file)

**What:** Not a single method calls `AccessControlService`. The `_userId` parameter in `findAll` is prefixed with underscore (unused). Any authenticated user can read, create, delete, cure, and reactivate allergies for any BabyMon.

**Remediation:** Inject `AccessControlService` and add `verifyAccess(babyMonId, userId)` to every method.

---

### S01-04 | 🔴 CRITICAL | MedicalTeamService — Zero Access Control

**Location:** `apps/api/src/medical-team/medical-team.service.ts` (entire file)

**What:** Same pattern as allergies. No access verification on `findAll`, `create`, or `remove`. Any authenticated user can read/modify any BabyMon's medical team.

**Remediation:** Inject `AccessControlService` and verify access before every operation.

---

### S01-05 | 🟠 HIGH | Public dev-override-trial Endpoint

**Location:** `apps/api/src/subscriptions/subscriptions.controller.ts:21-30`

**What:** The `dev-override-trial` endpoint is marked `@Public()` and accepts arbitrary `{ userId, days }`. Blocked in production by `NODE_ENV` check, but if this is ever misconfigured, anyone can extend any user's trial indefinitely.

**Remediation:** Remove the endpoint before production, or gate behind `@UseGuards(JwtAuthGuard, RolesGuard)` with `@Roles('ADMIN')`.

---

### S01-06 | 🟠 HIGH | Three Conflicting JWT Fallback Secrets

**Location:** `auth.service.ts:14` vs `auth.module.ts:16` vs `jwt.strategy.ts:10`

**What:** Three different modules compute their own fallback JWT secret:
- `auth.module.ts`: `'babymon-jwt-secret-do-not-use-in-production'` (signing)
- `auth.service.ts`: `'dev-only-secret'` (refresh token verification)
- `jwt.strategy.ts`: `'babymon-jwt-secret-do-not-use-in-production'` (passport validation)

Access tokens signed with one secret, refresh tokens verified with another — refresh always fails in dev without `JWT_SECRET` set.

**Remediation:** Use a single source of truth. Export `JWT_SECRET` validation from a shared config module.

---

### S01-07 | 🟠 HIGH | Duplicate Public Decorator Definitions

**Location:** `auth/decorators/public.decorator.ts` and `common/decorators/public.decorator.ts`

**What:** Two identical files define the same `IS_PUBLIC_KEY = 'isPublic'`. `JwtAuthGuard` imports from `common/`. Happens to work because the string value is identical, but fragile.

**Remediation:** Delete `apps/api/src/auth/decorators/public.decorator.ts`. Keep only the one in `common/decorators/`.

---

### S01-08 | 🟠 HIGH | Non-Functional Stripe Webhook Stub

**Location:** `apps/api/src/stripe/stripe-webhook.controller.ts`

**What:** Registers at `POST /webhooks/stripe`, accepts any payload without signature verification, returns `{ received: true }`. Dead code that silently accepts forged webhooks.

**Remediation:** Delete `stripe-webhook.controller.ts` and its registration. The working endpoint is in `StripeController`.

---

### S01-09 | 🟠 HIGH | Hardcoded DB Credentials in docker-compose.yml

**Location:** `docker-compose.yml:7,29`

**What:** `POSTGRES_PASSWORD: babymon_dev_password` hardcoded. PostgreSQL port `5432:5432` exposed to host.

**Remediation:** Use environment variables with dev defaults: `POSTGRES_PASSWORD: ${DB_PASSWORD:-babymon_dev_password}`. Remove port mapping in production.

---

### S01-10 | 🟡 MEDIUM | console.error Leaks Registration Errors

**Location:** `apps/api/src/auth/auth.service.ts:85`

**What:** `console.error('Registration error:', error)` dumps full error object to stdout.

**Remediation:** Replace with structured Pino logger: `this.logger.error({ err: error }, 'Registration failed')`.

---

### S01-11 | 🟡 MEDIUM | Inconsistent Access Control in GrowthService

**Location:** `apps/api/src/growth/growth.service.ts:79-81,181-183`

**What:** `addGrowthRecord()` and `deleteGrowthRecord()` check `babyMon.ownerUserId !== userId` (owner-only), while `getGrowthRecords()` uses `verifyAccess()` (allows co-parents). Co-parents can VIEW but not CREATE/DELETE growth data. Undocumented and inconsistent.

**Remediation:** Unify access control using `AccessControlService` everywhere, checking `AccessLevel.EDIT` for writes.

---

### S01-12 | 🟡 MEDIUM | getPendingProposals Has No Access Check

**Location:** `apps/api/src/journal/journal-proposals.service.ts:29`

**What:** `getPendingProposals(babymonId)` does not verify requesting user has access to the BabyMon.

**Remediation:** Add `userId` parameter and call `verifyAccess(babymonId, userId)` before querying.

---

### S01-13 | 🟡 MEDIUM | 'ADMIN' Access Level Not in AccessLevel Enum

**Location:** `apps/api/src/linked-accounts/linked-accounts.service.ts:267`

**What:** Default parameter is `access: 'READ' | 'EDIT' | 'ADMIN' = 'EDIT'`. `AccessLevel` enum only has `VIEW` and `EDIT`. `'READ'` and `'ADMIN'` don't exist.

**Remediation:** Align with `AccessLevel` enum or extend the enum with proper checks.

---

### S01-14 | 🟡 MEDIUM | reset-password Lacks Rate Limiting

**Location:** `apps/api/src/auth/auth.controller.ts:52`

**What:** `POST /api/auth/reset-password` falls back to global default (100 req/min). Should be aggressively rate-limited to prevent brute-force token guessing.

**Remediation:** Add `@Throttle({ SENSITIVE: { limit: 3, ttl: 60000 } })`.

---

### S01-15 | 🟡 MEDIUM | Missing Env Vars in .env.example

**What:** `SENDGRID_API_KEY`, `SENDGRID_FROM_EMAIL`, `FIREBASE_CONFIG`, `APP_URL`, `STRIPE_PRICE_CORE_MONTHLY`, `STRIPE_PRICE_CORE_YEARLY` used in code but not documented.

**Remediation:** Add all missing variables with example placeholder values.

---

### S01-16 | 🟡 MEDIUM | Outdated Dependencies

**Location:** `apps/api/package.json`, `apps/mobile/pubspec.yaml`

**What:** NestJS 11 (very new), `class-validator` 0.14.1 (2022), `stripe` 14.17.0 (2023), `@aws-sdk/client-s3` 3.525.0, `flutter_secure_storage` 9.0.0, `firebase_core` 2.24.2 — several with known vulnerabilities or outdated.

**Remediation:** Run `npm audit` and `flutter pub outdated` regularly. Update to latest stable versions.

---

### S01-17 | 🔵 LOW | SubscriptionWriteGuard — Dead Code

**Location:** `apps/api/src/common/guards/subscription-write.guard.ts`

**What:** Guard implements write-gating based on subscription/trial status but is never applied to any controller or route. Trial expiration check not enforced.

**Remediation:** Apply the guard to write-enabled controllers or remove the dead code.

---

### S01-18 | 🔵 LOW | Refresh Token Verify Bypasses Passport Strategy

**Location:** `apps/api/src/auth/auth.service.ts:140-143`

**What:** `refreshTokens()` manually calls `this.jwtService.verify(dto.refreshToken, { secret: safeJwtSecret })` instead of using the module-configured JwtService.

**Remediation:** Use `this.jwtService.verify(dto.refreshToken)` without explicit secret override.

---

### S01-19 | 🔵 LOW | Fragile Webhook Raw Body Fallback

**Location:** `apps/api/src/stripe/stripe.controller.ts:25`

**What:** Webhook handler uses `JSON.stringify(req.body)` fallback if `rawBody` is missing, which may produce bytes different from what Stripe signed.

**Remediation:** Rely exclusively on Express raw body middleware. Throw a clear error if `req.rawBody` missing.

---

### S01-20 | ⚪ INFO | Local .env Contains Real Credentials

**Location:** `apps/api/.env` (gitignored, local dev only)

**What:** Contains live Neon PostgreSQL connection string and weak JWT secret. Gitignored, but filesystem access would expose live credentials.

**Remediation:** Rotate Neon database credentials. Use stronger JWT secret in all environments.

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 4 |
| 🟠 High | 5 |
| 🟡 Medium | 7 |
| 🔵 Low | 3 |
| ⚪ Info | 1 |
| **Total** | **20** |
