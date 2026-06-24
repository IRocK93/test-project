# BabyMon Security Audit Report — v4

**Date:** 2026-06-22
**Auditor:** Senior Application Security Specialist
**Overall Grade: C+**

---

## Critical Findings (Must-Fix Before Production)

### C1. OAuth Login Endpoints Do Not Exist on Backend
**Severity:** CRITICAL

The mobile client calls `POST /api/auth/google`, `POST /api/auth/apple`, and `POST /api/auth/facebook` but **no corresponding controller methods exist on the backend**. These endpoints will return 404 in all environments, breaking Google Sign-In, Sign in with Apple, and Facebook Login. Additionally, there is no server-side ID token verification.

**Files:**
- `apps/mobile/lib/core/constants/api_constants.dart` (lines 12-14)
- `apps/api/src/auth/auth.controller.ts` — no google, apple, or facebook routes

### C2. Biometric Authentication Endpoint Does Not Exist
**Severity:** CRITICAL

The mobile `biometricLogin()` method sends POST to `/api/auth/biometric-verify` which does not exist on the backend. No device-level biometric verification is implemented.

### C3. Inconsistent JWT Secret Fallbacks Across Multiple Files
**Severity:** CRITICAL

Three different hardcoded fallback secrets exist across four files:
- `auth.module.ts:17`: `'babymon-jwt-secret-do-not-use-in-production'`
- `jwt.strategy.ts:10`: `'babymon-jwt-secret-do-not-use-in-production'`
- `auth.service.ts:28`: `'dev-only-secret'` — different!
- `configuration.ts:78`: `'babymon-jwt-dev-secret-do-not-use-in-production'` — yet another variant!

### C4. Helmet Security Headers Missing Entirely
**Severity:** CRITICAL

No Helmet middleware installed or configured. Missing: CSP, X-Content-Type-Options, X-Frame-Options, HSTS, Referrer-Policy.

### C5. Two Stripe Webhook Controllers — One Does Not Verify Signatures
**Severity:** CRITICAL

`StripeWebhookController` at `/api/webhooks/stripe` never calls `stripe.webhooks.constructEvent()` — just logs and returns `{ received: true }`. The working implementation is at `/api/subscriptions/webhook`. If the wrong URL is configured in Stripe dashboard, forged events could be processed.

---

## High Severity Findings

### H1. Tokens Stored in Both FlutterSecureStorage and SharedPreferences
Access tokens, refresh tokens, and user IDs are stored in both encrypted and plain-text storage, doubling the attack surface.

### H2. Public dev-override-trial Endpoint Exposed
`POST /api/subscriptions/dev-override-trial` is `@Public()` and accepts arbitrary `userId`. A misconfiguration of `NODE_ENV` could expose this in production.

### H3. No Rate Limiting on Stripe Webhook Endpoints
Webhook endpoints are `@Public()` with no rate limiting — vulnerable to resource exhaustion attacks.

### H4. Presigned Download URL Lacks Access Control
`S3Service.getSignedDownloadUrl()` generates presigned URLs with no access control verification. Anyone with the URL can download the file.

---

## Medium Severity

- M1: RolesGuard defined but never used — no admin-only endpoint enforcement
- M2: No Content-Security-Policy or security headers configured
- M3: PII exposure in profile endpoint (phone field inconsistency)
- M4: Refresh token expiry hardcoded at 7 days (should be configurable)
- M5: Direct `process.env` usage in 15 files bypassing ConfigService

## Low Severity

- L1: Email verification token in GET query string (logged by proxies)
- L2: TierGuard has dev bypass via `SKIP_TIER_GUARD` env var
- L3: Inline styles in email HTML without escaping user data
- L4: Account deletion requires password but OAuth users have none
- L5: Stripe API version pinned to 2023-10-16
- L6: Password reset token not invalidated on re-request

---

## What's Done Well

- bcrypt with 12 rounds for password hashing
- Refresh token rotation (old token revoked before new issued)
- Constant-time comparison via `bcrypt.compare()`
- DTO whitelisting (`whitelist: true` + `forbidNonWhitelisted: true`)
- Prisma parameterized queries throughout (no SQL injection)
- Enumeration resistance in login and forgot-password
- Stripe webhook idempotency via `stripeEvent` deduplication
- Co-parent access control with BabyMon-scoped `LinkedBabyMon`
- Comprehensive audit logging infrastructure
- Tiered rate limiting: 5/min auth, 10/min sensitive, 100/min default
- Soft deletes for Users and BabyMons
- Graceful degradation for Stripe, S3, and SendGrid

---

## Fix Priority Matrix

| Priority | Finding | Description | Effort |
|----------|---------|-------------|--------|
| P0 | C4 | Add Helmet security headers | Small |
| P0 | C3 | Unify JWT secret management | Small |
| P0 | C5 | Remove duplicate webhook controller | Small |
| P1 | C1 | Implement OAuth backend endpoints | Large |
| P1 | C2 | Implement biometric auth flow | Medium |
| P1 | H1 | Remove SharedPreferences token storage | Small |
| P1 | H2 | Secure dev-override-trial endpoint | Small |
| P1 | H3 | Add rate limiting to webhook | Small |
| P2 | H4 | Add access control to presigned download URLs | Medium |
| P2 | M1 | Apply RolesGuard to admin endpoints | Medium |
| P2 | M3 | Remove PII from profile endpoint | Small |
| P2 | M4 | Make refresh token TTL configurable | Small |
| P2 | M5 | Migrate process.env to ConfigService | Medium |
