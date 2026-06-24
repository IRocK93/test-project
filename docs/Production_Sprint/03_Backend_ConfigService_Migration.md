# Issue 11: process.env Direct Access Instead of ConfigService

**Date:** 2026-06-23 | **Priority:** HIGH

## Summary

13 non-config files bypass the centralized `ConfigService` and read `process.env` directly. Additionally, `auth.service.ts` uses `ConfigService` but with **wrong key names** (`TRIAL_DAYS` instead of `trialDays`), silently falling back to hardcoded defaults.

---

## BONUS BUG: auth.service.ts ConfigService Keys Are Wrong

**File:** `apps/api/src/auth/auth.service.ts`

| Line | Current (WRONG) | Should Be | Impact |
|------|-----------------|-----------|--------|
| 58, 433 | `configService.get('TRIAL_DAYS')` | `configService.get('trialDays')` | `TRIAL_DAYS` env var completely ignored — always uses default 14 |
| 309 | `configService.get('JWT_REFRESH_EXPIRES_IN')` | Key missing from AppConfig | Always defaults to 7 days |

**Fix Priority:** CRITICAL — trial period and JWT refresh expiry are silently ignored.

---

## Complete Audit: process.env Usage (Excluding config/ and .spec.ts)

### CATEGORY A: Trivial Migration (keys exist in AppConfig)

| Priority | File | Env Vars | Config Keys |
|----------|------|----------|-------------|
| P0 | `stripe/stripe.service.ts` | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_*` | `stripe.*` |
| P0 | `stripe/stripe.controller.ts` | `FRONTEND_URL` | `frontendUrl` |
| P0 | `common/crypto.service.ts` | `CRYPTO_KEY`†, `NODE_ENV` | `crypto.key` (needs extension) |
| P0 | `prisma/prisma.service.ts` | `DATABASE_URL`†, `DATABASE_POOL_SIZE` | `database.*` (url needs extension) |
| P1 | `main.ts` | `SENTRY_DSN`†, `NODE_ENV`, `CORS_ORIGINS`, `PORT` | `sentry.dsn` (needs extension), `nodeEnv`, `corsOrigins`, `port` |
| P1 | `mail/mail.service.ts` | `SENDGRID_API_KEY`, `SENDGRID_FROM_EMAIL`, `APP_URL` | `sendgrid.*`, `appUrl` |
| P1 | `notifications/notifications.service.ts` | `FIREBASE_CONFIG` | `firebase.configJson` |
| P1 | `s3/s3.service.ts` | `AWS_*` (4 vars) | `aws.*` |
| P1 | `app.module.ts` | `LOG_LEVEL`, `RATE_LIMIT_*` | `logLevel`, `rateLimit.*` (needs forRootAsync) |
| P2 | `common/data-retention.service.ts` | `DATA_RETENTION_DAYS`† | `retention.days` (needs extension) |
| P2 | `companion/tier.guard.ts` | `SKIP_TIER_GUARD`† | `dev.bypassTierGuard` (needs extension) |
| P2 | `subscriptions/subscriptions.controller.ts` | `STRIPE_PRICE_PREMIUM_MONTHLY`, `NODE_ENV` | `stripe.*`, `nodeEnv` |
| P3 | `subscriptions/subscriptions.service.ts` | `NODE_ENV` | `nodeEnv` |

† = Key missing from AppConfig — needs interface extension.

---

## New AppConfig Keys Required

| New Path | Env Var | Type | Default |
|----------|---------|------|---------|
| `sentry.dsn` | `SENTRY_DSN` | `string \| undefined` | `undefined` |
| `crypto.key` | `CRYPTO_KEY` | `string \| undefined` (64 hex) | `undefined` |
| `dataRetention.days` | `DATA_RETENTION_DAYS` | `number` | `90` |
| `dev.bypassTierGuard` | `SKIP_TIER_GUARD` | `boolean` | `false` |
| `database.url` | `DATABASE_URL` | `string` | `''` |
| `jwt.refreshExpiresInDays` | `JWT_REFRESH_EXPIRES_IN` | `number` | `7` |

---

## Migration Pattern

```typescript
// BEFORE (anti-pattern):
const apiKey = process.env.SENDGRID_API_KEY;

// AFTER (correct):
import { ConfigService } from '@nestjs/config';
constructor(private configService: ConfigService) {}
const apiKey = this.configService.get<string>('sendgrid.apiKey');
```

Key naming: camelCase, dot-separated matching the `AppConfig` interface. Do NOT use UPPER_SNAKE_CASE — those return `undefined`.

For `app.module.ts`, use `forRootAsync`:
```typescript
ThrottlerModule.forRootAsync({
  imports: [ConfigModule],
  inject: [ConfigService],
  useFactory: (config: ConfigService) => [{ name: 'DEFAULT', ttl: config.get('rateLimit.ttl'), limit: config.get('rateLimit.max') }],
}),
```
