# 11 — Promo Code System

**Date:** 2026-06-25
**Status:** Implemented

---

## Overview

App-level promo code system for granting trial extensions or premium access. No Stripe integration required — codes are validated and redeemed entirely in-app.

### Code types

| Type | Behavior |
|------|----------|
| `TRIAL_EXTEND` | Adds N days to the user's existing trial. If no trial exists, creates one. |
| `FULL_PREMIUM` | Sets the user's subscription tier to PREMIUM for N days, then reverts. |

---

## Database

### New models (Prisma)

```
model PromoCode {
  id                 String         @id @default(uuid())
  code               String         @unique        // e.g. "LAUNCH-A3F7-K9M2"
  type               PromoCodeType                 // TRIAL_EXTEND | FULL_PREMIUM
  valueDays          Int                           // how many days this grants
  maxRedemptions     Int?                          // null = unlimited
  currentRedemptions Int            @default(0)
  isActive           Boolean        @default(true)
  expiresAt          DateTime?                     // optional expiry
  createdBy          String?                       // admin note for tracking
  createdAt          DateTime       @default(now())
  updatedAt          DateTime       @updatedAt

  redemptions PromoRedemption[]
}

model PromoRedemption {
  id          String   @id @default(uuid())
  promoCodeId String
  userId      String
  redeemedAt  DateTime @default(now())

  promoCode PromoCode @relation(fields: [promoCodeId], references: [id])
  user      User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([promoCodeId, userId])   // one redemption per user per code
  @@index([userId])
}
```

User model updated with: `promoRedemptions PromoRedemption[]`

### No migration file

Schema was pushed via `prisma db push`. Before production, generate a proper migration with `prisma migrate dev --name add_promo_codes`.

---

## API Endpoints

### User-facing (JWT protected)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/subscriptions/validate-promo` | Check if a code is valid. Returns `{ code, type, valueDays, description }`. No side effects. |
| POST | `/subscriptions/redeem-promo` | Apply the code. Body: `{ code }`. Returns `{ success, type, valueDays, accessUntil }`. |

### Admin (JWT + ADMIN role required)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/promo-codes` | List all promo codes with redemption counts |
| POST | `/admin/promo-codes/generate` | Batch generate codes |

### Generate codes (admin)

```
POST /admin/promo-codes/generate
Authorization: Bearer <admin-jwt>
Content-Type: application/json

{
  "prefix": "LAUNCH",
  "count": 100,
  "type": "TRIAL_EXTEND",
  "valueDays": 30,
  "maxRedemptions": 1,
  "expiresAt": "2026-12-31T23:59:59Z",
  "createdBy": "Launch campaign #1"
}
```

Response:
```json
{
  "generated": ["LAUNCH-A3F7-K9M2", "LAUNCH-B8C4-D1E6", ...],
  "count": 100,
  "type": "TRIAL_EXTEND",
  "valueDays": 30
}
```

Code format: `{PREFIX}-{4CHAR}-{4CHAR}` using `crypto.randomBytes` hex. Collision-checked against existing codes.

### Validation rules (enforced on both validate and redeem)

1. Code must exist in database (case-insensitive)
2. Code must be active (`isActive: true`)
3. Code must not be expired (`expiresAt` in the future, or null)
4. Code must not have reached `maxRedemptions` (if set)
5. User must not have already redeemed this code (unique constraint on `promoCodeId + userId`)

---

## Redemption logic

### TRIAL_EXTEND
- Finds the user's active subscription (most recent)
- If found: extends `trialEndDate` by `valueDays` from the later of now or current end date
- If not found: creates a new FREE subscription with trial spanning now → now + valueDays

### FULL_PREMIUM
- Finds the user's active subscription
- If found: updates tier to `PREMIUM` and sets `trialEndDate` to now + valueDays
- If not found: creates a new PREMIUM subscription with trial spanning now → now + valueDays
- **Note:** After `valueDays` expires, the subscription `trialEndDate` passes but the tier stays PREMIUM. The `getCurrentSubscription()` method checks `trialEndDate > now` for trial status, but the tier field is not automatically reverted. A cleanup job or additional check is needed for production. See Deployment Notes below.

---

## Frontend

### Files changed

| File | Change |
|------|--------|
| `api_constants.dart` | Added `validatePromo` and `redeemPromo` endpoint paths |
| `api_client.dart` | Added `validatePromoCode(code)` and `redeemPromoCode(code)` methods |
| `subscription_screen.dart` | Added promo code input between hero and plan banner |

### UX flow

1. Text field "Have a promo code?" with tag icon
2. User enters code → taps Apply (or submits from keyboard)
3. Calls validate endpoint → shows confirmation dialog with description
4. User confirms → calls redeem endpoint → shows success banner
5. Subscription status refreshes automatically
6. Error states shown inline below the text field

### State management

- `_promoController` — text field controller, disposed properly
- `_promoLoading` — disables button during API calls
- `_promoError` — inline error message
- `_promoSuccess` — replaces input with success banner

---

## What needs to change for production

### 1. Generate a proper migration

```bash
cd apps/api
npx prisma migrate dev --name add_promo_codes
```

Currently the schema was pushed via `prisma db push`. A migration file is required for production deploy via `prisma migrate deploy`.

### 2. Add tier expiry job

`FULL_PREMIUM` codes upgrade the tier but never revert it. After the premium period expires, the user stays on PREMIUM with an expired trial. Add a scheduled job that runs daily:

```typescript
// Check for expired premium grants
const expired = await this.prisma.subscription.findMany({
  where: {
    tier: 'PREMIUM',
    trialEndDate: { lt: new Date() },
    stripeSubscriptionId: null,  // only promo-granted, not paid
  },
});

for (const sub of expired) {
  await this.prisma.subscription.update({
    where: { id: sub.id },
    data: { tier: 'FREE' },
  });
}
```

### 3. Add `promoCodeId` to Subscription model (optional)

Track which promo code was applied to which subscription for analytics:

```
model Subscription {
  ...
  promoCodeId  String?
  promoCode    PromoCode?  @relation(fields: [promoCodeId], references: [id])
}
```

### 4. Admin authentication

The `PromoCodesController.requireAdmin()` checks `user.role === 'ADMIN'`. Ensure at least one user has the ADMIN role in the database before going live.

### 5. Rate limiting

Add rate limiting to validate and redeem endpoints to prevent brute-force code guessing. NestJS throttle module or a simple Redis-backed limiter.

### 6. Production codes

Generate a batch before launch:

```
POST /admin/promo-codes/generate
{
  "prefix": "LAUNCH2026",
  "count": 500,
  "type": "TRIAL_EXTEND",
  "valueDays": 30,
  "maxRedemptions": 1,
  "createdBy": "Public launch campaign"
}
```

Distribute via:
- Welcome email after signup
- Social media posts
- Partner/referral programs
- Review incentives ("Leave a review, get 30 days free")

---

## Files summary

| Layer | File | Purpose |
|-------|------|---------|
| DB | `prisma/schema.prisma` | PromoCode + PromoRedemption models, enum |
| API | `subscriptions.service.ts` | `validatePromoCode()`, `redeemPromoCode()` |
| API | `subscriptions.controller.ts` | User-facing validate/redeem endpoints |
| API | `promo-codes.controller.ts` | Admin list/generate endpoints |
| API | `subscriptions.module.ts` | Module wiring |
| API | `subscriptions.dto.ts` | `PromoCodeDto` |
| Flutter | `api_constants.dart` | Endpoint paths |
| Flutter | `api_client.dart` | `validatePromoCode()`, `redeemPromoCode()` |
| Flutter | `subscription_screen.dart` | Promo code UI + apply flow |
