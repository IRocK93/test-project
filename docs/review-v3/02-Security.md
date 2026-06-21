# Security Audit Report

## Grade: C+

## Summary

BabyMon's security posture shows genuinely thoughtful design in several areas -- FlutterSecureStorage for tokens, comprehensive rate limiting, proper Stripe webhook signature verification, bcrypt with cost factor 12, and a solid access-control service that is widely wired into child-resource operations. However, two critical vulnerabilities and a pattern of inconsistent enforcement drag the grade down significantly. The Apple ID token verification is utterly broken (it merely base64-decodes the JWT payload without any cryptographic signature check, allowing trivial token forgery), and the `calculateCurrentStage` endpoint has zero access control, letting any authenticated user read any BabyMon's stage data. The JWT secret has a hardcoded dev fallback that a misconfigured production deploy could activate, and the global exception filter logs raw exception objects with potential sensitive data. These issues mean the application is not ready for production deployment handling real child health data.

## Findings

| # | Severity | File:Line | Vulnerability | Exploit Scenario | Fix |
|---|----------|-----------|---------------|-----------------|-----|
| 1 | **CRITICAL** | `auth.service.ts:479-488` | Apple ID token is NOT cryptographically verified -- it only base64-decodes the JWT payload locally with no signature verification against Apple's public keys | Attacker crafts a forged JWT with any email, base64-encodes it, sends to `/auth/apple` -- gains access to that account or creates a new one with chosen identity | Use `apple-signin-auth` npm package or manually fetch Apple's JWKS from `https://appleid.apple.com/auth/keys` and verify JWT signature. Validate `aud` claim matches app's Apple client ID and `iss` is `https://appleid.apple.com` |
| 2 | **CRITICAL** | `baby-mon.controller.ts:59-63` and `baby-mon.service.ts:192-248` | `calculateCurrentStage` endpoint has zero access control -- no ownership check, no `AccessControlService.verifyAccessOrThrow`, no user context used at all | Attacker authenticates, enumerates BabyMon UUIDs, and reads pregnancy week/month stage data (revealing due dates, conception dates, birth dates) of any family on the platform | Add `req.user.id` parameter passing and call `this.accessControl.verifyAccessOrThrow(userId, babymonId, AccessLevel.VIEW)` before computing stage |
| 3 | **HIGH** | `jwt-config.ts:12` | Hardcoded JWT fallback secret `'babymon-jwt-dev-secret-do-not-use-in-production'` is used when `jwt.secret` is not configured and `nodeEnv !== 'production'` | If staging/CI environment is misconfigured, every JWT is verifiable with this publicly known secret -- attacker can forge tokens for any user | Remove hardcoded fallback entirely. Require `JWT_SECRET` unconditionally by changing Joi schema's `otherwise` clause to also `.required()` |
| 4 | **HIGH** | `global-exception.filter.ts:41-43` | Global exception filter logs raw exception object: `this.logger.error({ err: exception, path: request.url, status }, message)` -- serializes full exception including stack traces, potentially request bodies, tokens, or passwords | Error during login that includes password in stack/context gets persisted to pino logs. If logs shipped to third-party service or kept in plaintext, credentials leak | Sanitize logged object: only log `exception.constructor.name`, `exception.message`, and `exception.stack`. Never embed `request.body` or `request.headers.authorization` in log output |
| 5 | **HIGH** | `main.ts` and `package.json` | No Helmet middleware installed -- app lacks Content-Security-Policy, X-Content-Type-Options, Strict-Transport-Security, X-Frame-Options, Referrer-Policy | API responses lack HSTS headers enabling MITM downgrade attacks; missing X-Frame-Options allows clickjacking; missing CSP increases XSS risk | Add `helmet` npm package and `app.use(helmet())` early in middleware chain. Configure HSTS with `maxAge: 31536000` in production |
| 6 | **MEDIUM** | `auth.controller.ts:60-65` | Email verification endpoint has NO rate limiting (no `@Throttle` decorator) | While tokens have 256-bit entropy making brute-force impractical, rate limiting should exist as defense-in-depth | Add `@Throttle({ SENSITIVE: { limit: 5, ttl: 60000 } })` to `verifyEmail` endpoint |
| 7 | **MEDIUM** | `auth.service.ts:434` | Social login fallback password hash uses bcrypt cost factor 10 instead of 12 (inconsistent with rest of app) | 32-byte random password is high-entropy so exploitation impractical, but inconsistent cost factors confuse future maintainers | Change to `bcrypt.hash(randomBytes(32).toString('hex'), 12)` for consistency |
| 8 | **MEDIUM** | `baby-mon.service.ts:79-98` | `findAll` only returns BabyMons where `ownerUserId === userId`, completely ignoring linked co-parent table -- co-parents see empty list | Co-parent invited to manage a BabyMon will see empty dashboard | Union owner's and linked BabyMons: `where: { OR: [ { ownerUserId: userId }, { linkedBabyMons: { some: { userId } } } ] }` |
| 9 | **MEDIUM** | `auth.service.ts:253-277` | `verifyEmail` uses `findFirst` with bare token lookup. Token reuse/downgrade attacks possible if token leaks via HTTP referrer headers or email forwarding | Token has 24-hour expiry but bare storage means leaked token is directly usable | Store hashed version of verification token. Shorten expiry to 1 hour |
| 10 | **LOW** | `auth.dto.ts:97-101` | `SocialLoginDto.provider` field only validated as `@IsString()` with no `@IsIn` validator -- TypeScript union type has no runtime enforcement | Currently mitigated because each endpoint hardcodes provider string, but future shared endpoint would be vulnerable | Add `@IsIn(['google', 'apple', 'facebook'])` validator |
| 11 | **LOW** | `api_client.dart:118-123` | `logout()` catches errors silently and uses `print()` for error logging instead of structured logger | Loss of audit trail if logout API call fails -- client clears tokens locally but server never receives revocation request | Use proper logger instead of `print()` |
| 12 | **LOW** | `audit.interceptor.ts:50-55` | Error path in audit interceptor logs error message without sanitization | Validation errors on sensitive fields could leak field names/values into audit logs | Sanitize or truncate error messages before logging: only log first 200 characters, strip known sensitive key patterns |

## Top 5 Vulnerabilities

1. **Apple ID Token Forgery (CRITICAL)**: `auth.service.ts:479-488` performs zero cryptographic verification of Apple Sign-In tokens. Trivially exploitable -- any attacker can forge a token and impersonate any user.

2. **Missing Stage Endpoint Access Control (CRITICAL)**: `baby-mon.controller.ts:59-63` exposes `calculateCurrentStage` with no ownership check, leaking pregnancy stage/week/birth date data for any BabyMon to any authenticated user.

3. **Hardcoded JWT Dev Secret (HIGH)**: `jwt-config.ts:12` provides a fallback secret known to anyone reading the source code. A misconfigured production deploy would activate it.

4. **Sensitive Data in Exception Logs (HIGH)**: `global-exception.filter.ts:41-43` logs raw exception object, potentially capturing passwords, tokens, or PII in log output.

5. **Missing Helmet Security Headers (HIGH)**: No `helmet` middleware means no HSTS, CSP, X-Frame-Options, or other standard security headers in API responses.

## Data Privacy Concerns (baby health data)

- **Health data classification**: The application stores pregnancy stage data, feeding logs, health records, allergies, growth measurements, medical team contacts, and sleep logs. This is sensitive health data that may qualify as protected health information under various regulatory frameworks.
- **Access control gaps**: The `calculateCurrentStage` endpoint bypasses all access control entirely. The `findAll` method excludes linked co-parents.
- **Audit trail**: Commendable audit interceptor and per-service audit logging, but captures `ipAddress` and `userAgent` -- both personal data under GDPR.
- **Data export/deletion**: Export module exists but format unclear. BabyMon delete performs hard delete with cascade (correct for GDPR).
- **Co-parent access**: Access control applied at BabyMon level -- no record-level access control on individual milestones, health records, or feed logs.

## Compliance Gaps (GDPR/COPPA/HIPAA-adjacent)

- **GDPR**: Audit logs capture IPs without anonymization policy. No visible DPO contact or data processing agreement endpoint. Consent tracking good but needs withdrawal mechanism.
- **COPPA**: 18+ age gate present (good). But child health/development data about minors stored -- COPPA applicability unclear.
- **HIPAA-adjacent**: Not a covered entity but stores health-adjacent data. No encryption at rest visible. No BAA capability. Medical team feature stores provider info without verification.
- **Right to erasure (GDPR Art. 17)**: BabyMon hard delete with cascade. User account deletion endpoint not found in audit scope. Stripe subscription data not purged on account deletion.
- **Data portability (GDPR Art. 20)**: Export endpoint exists but format unclear.
