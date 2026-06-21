# Subscription Guard & Access Tiers Explained

## Overview

BabyMon has a two-tier subscription model. The `SubscriptionGuard` enforces write-access gating: once your trial expires, you must subscribe to keep creating or editing data. Reading your data is always free.

---

## How the Guard Works

The `SubscriptionGuard` is a NestJS route guard that sits in front of **write endpoints** (POST, PATCH, DELETE). On every write request, it:

1. Extracts the authenticated `userId` from the request
2. Calls `SubscriptionsService.canWrite(userId)` which checks:
   - **Active Stripe subscription?** → allowed
   - **Active trial?** (trial end date still in the future, no Stripe subscription yet) → allowed
   - **Neither?** → denied with HTTP 403 and code `TRIAL_EXPIRED`
3. Throws `ForbiddenException` if neither condition is met, short-circuiting the request before any data mutation

The mobile app receives a structured error response:

```json
{
  "statusCode": 403,
  "message": "Trial expired. Please subscribe to continue tracking your parenting journey.",
  "code": "TRIAL_EXPIRED",
  "error": "Payment Required"
}
```

---

## Tiers

### CORE (Free)

The CORE tier is the baseline — it's what every user falls back to after their trial expires if they don't subscribe.

| Feature | Access |
|---------|--------|
| View BabyMon profiles | ✅ |
| View milestones, feed logs, health records, sleep logs, growth data | ✅ |
| View badges, XP, stage progress | ✅ |
| View AI companion content (read-only) | ✅ |
| View journal entries | ✅ |
| View linked co-parent data | ✅ |
| Export data | ✅ |
| Manage account settings, partners, preferences | ✅ |
| **Create** milestones, feed logs, health records, sleep logs, growth records | ❌ |
| **Edit** existing entries | ❌ |
| **Delete** entries | ❌ |
| **Create** or **delete** BabyMon profiles | ❌ |

**The rule**: CORE is read-only for all data. You can see everything you already tracked, but you cannot add new entries, edit existing ones, or delete them.

### AI_COMPANION (Paid — $4.99/month)

The AI_COMPANION tier unlocks full write access across all tracking features.

| Feature | Access |
|---------|--------|
| Everything in CORE | ✅ |
| Create new milestones, feed logs, health records, sleep logs, growth records | ✅ |
| Edit existing entries | ✅ |
| Delete entries (with confirmation) | ✅ |
| Create and delete BabyMon profiles | ✅ |
| On-device AI companion with personalized advice | ✅ |
| Daily brief, routine suggestions, milestone tracker | ✅ |

---

## Trial

Every new account starts with a **14-day free trial** at the AI_COMPANION tier (configurable via `trialDays` in env). During the trial:

- Full write access is granted (same as paid)
- No payment method is required
- After 14 days, write access is revoked unless the user subscribes

Trial state is determined by:

```
if (no stripeSubscriptionId AND trialEndDate > now) → trial active
if (no stripeSubscriptionId AND trialEndDate ≤ now) → trial expired → CORE
```

---

## Endpoints Protected by SubscriptionGuard

The guard is applied at the **method level** on POST/PATCH/DELETE endpoints. GET endpoints are never protected.

| Controller | Protected Methods | Notes |
|-----------|-------------------|-------|
| `BabyMonController` | `POST /baby-mons`, `PATCH /baby-mons/:id`, `DELETE /baby-mons/:id` | Creating/editing/deleting BabyMon profiles requires subscription |
| `MilestonesController` | `POST .../milestones`, `PATCH /milestones/:id`, `DELETE /milestones/:id` | |
| `FeedLogsController` | `POST .../feed-logs`, `PATCH /feed-logs/:id`, `DELETE /feed-logs/:id` | |
| `HealthRecordsController` | `POST .../health-records`, `PATCH /health-records/:id`, `DELETE /health-records/:id` | |
| `SleepLogsController` | `POST .../sleep-logs`, `PATCH /sleep-logs/:id`, `DELETE /sleep-logs/:id` | |
| `GrowthController` | `POST /growth`, `PATCH /growth/:id`, `DELETE /growth/:id` | |

---

## Endpoints NOT Protected (Always Free)

These endpoints are read-only or operate outside the write-tracking scope:

| Controller | Free Endpoints |
|-----------|---------------|
| All controllers (GET) | `GET` on any resource — reading your data is always free |
| `JournalController` | Journal viewing, proposal viewing |
| `AllergiesController` | Allergy tracking CRUD (currently ungated) |
| `MediaController` | Photo uploads (currently ungated) |
| `MedicalTeamController` | Medical team management (currently ungated) |
| `CompanionController` | AI companion chat (currently ungated) |
| `ExportController` | Data export (GDPR) |
| `BadgesController` | Badge viewing |
| `EvolutionController` | Evolution/stage viewing |
| `LinkedAccountsController` | Co-parent linking |
| `NotificationsController` | Push notification preferences |
| `AuthController` | Login, register, password reset, token refresh |
| `AdminController` | Admin operations (role-gated separately) |
| `HealthController` | Health checks |

> **Note:** Controllers marked "currently ungated" may be intentionally free or may need SubscriptionGuard in a future update. The current gating focuses on the 6 core tracking controllers.

---

## Stripe Integration

When a user subscribes via Stripe:

1. The Stripe webhook (`stripe.controller.ts`) receives `checkout.session.completed` events
2. The subscription record is updated with `stripeSubscriptionId`, `currentPeriodEnd`, and tier
3. `hasSubscription` returns `true` based on `currentPeriodEnd > now`
4. The guard allows writes

When a subscription is canceled (but not yet expired):

- `cancelAtPeriodEnd` is set to `true`
- The user retains write access until `currentPeriodEnd`
- After period end, `hasSubscription` becomes `false` and writes are blocked

---

## Dev Override

For development and testing, the `SubscriptionsService.devOverrideTrial(userId, days)` method extends or creates a trial. This is **only available in non-production environments**. It creates or updates a subscription record with an extended `trialEndDate`.

---

## What Happens When Trial Expires

From the user's perspective:

1. Any POST/PATCH/DELETE attempt returns a 403 error
2. The mobile app should detect the `TRIAL_EXPIRED` code and show the subscription upsell screen
3. All existing data remains visible and accessible
4. Data export continues to work (GDPR compliance)
5. The user can subscribe at any time to restore write access immediately

---

## Files

| File | Role |
|------|------|
| `apps/api/src/common/guards/subscription.guard.ts` | NestJS guard that enforces write access |
| `apps/api/src/subscriptions/subscriptions.service.ts` | Business logic: trial checks, Stripe integration, dev override |
| `apps/api/src/auth/auth.service.ts` | Creates trial subscription on registration and social login |
| `apps/api/src/stripe/stripe.controller.ts` | Stripe webhook handler for subscription lifecycle |
| `apps/api/prisma/schema.prisma` | `Subscription` model with `tier`, `trialEndDate`, `stripeSubscriptionId`, `currentPeriodEnd` |
| `apps/mobile/lib/features/settings/subscription_screen.dart` | Mobile subscription UI |
