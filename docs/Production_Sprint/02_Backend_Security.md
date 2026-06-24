# Issues 5-6, 12-14: Backend Security

**Date:** 2026-06-23 | **Priority:** CRITICAL/HIGH

---

## Issue 5: dev-override-trial @Public() Endpoint

**File:** `apps/api/src/subscriptions/subscriptions.controller.ts`, lines 63-71

```typescript
@Public()
@Post('dev-override-trial')
async devOverrideTrial(@Body() body: { days: number }, @Req() req: any) {
  if (process.env.NODE_ENV === 'production') {
    throw new ForbiddenException('Not available in production');
  }
  // ... extends trial
}
```

**Risk:** HIGH. The only guard is a runtime `NODE_ENV` check. Since `NODE_ENV` is hardcoded to `development` in docker-compose (see Issue 3), this endpoint is effectively **unauthenticated** on any deployment using the default compose file. Anyone can extend their trial indefinitely.

**Fix:** Remove `@Public()`, add `@Roles('ADMIN')` guard, OR gate with a NestJS guard that checks `ConfigService.get('nodeEnv')` and throws at the guard level (before the controller executes).

---

## Issue 6: Allergies Controller Missing Authorization

**File:** `apps/api/src/allergies/allergies.controller.ts`

Six mutation endpoints accept `babyMonId` as a URL param but **never verify** that the requesting user owns that BabyMon:

| Endpoint | Method | Missing Check |
|----------|--------|---------------|
| `deleteEvent` | DELETE | User owns babyMonId? |
| `cure` | POST | User owns babyMonId? |
| `reactivate` | POST | User owns babyMonId? |
| `remove` | DELETE | User owns babyMonId? |
| `clearAll` | POST | User owns babyMonId? |
| `clearAllEvents` | POST | User owns babyMonId? |

**Compare with baby-mon.controller.ts** which properly injects `AccessControlService` and calls `this.accessControl.checkAccess(userId, babyMonId)`.

**Fix:** Inject `AccessControlService` into `AllergiesController`. Add `const userId = req.user.id` and `await this.accessControl.checkAccess(userId, babyMonId)` to each mutation endpoint.

---

## Issue 12: Error Response Code Inconsistency

**File:** `apps/api/src/common/filters/global-exception.filter.ts`

The filter reads `exceptionResponse.error` but many services throw with `{ code: '...' }` instead:

```typescript
// Filter reads:
const code = (exceptionResponse as any).error || 'ERROR';

// Auth service throws:
{ message: '...', error: 'UNAUTHORIZED' }   // ← uses 'error'

// TierGuard throws:
{ statusCode: 402, message: '...', code: 'UPGRADE_REQUIRED' }  // ← uses 'code'
```

TierGuard errors with `code: 'UPGRADE_REQUIRED'` are returned as `"code": "ERROR"` to the client because the filter reads `.error` (undefined) and falls back to `'ERROR'`.

**Fix:** Update the filter to check both fields: `const code = (exceptionResponse as any).code || (exceptionResponse as any).error || 'ERROR';` OR standardize all exception throws to use `code`.

---

## Issue 13: Swagger UI Exposed in All Environments

**File:** `apps/api/src/main.ts`, lines 93-114

```typescript
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);   // no env check
```

**Risk:** MEDIUM. Full API schema (endpoints, DTOs, auth patterns) is publicly accessible at `/api/docs` in production. This is an information disclosure vector — attackers can enumerate all endpoints without trial and error.

**Fix:**
```typescript
if (process.env.NODE_ENV !== 'production') {
  SwaggerModule.setup('api/docs', app, document);
}
```

---

## Issue 14: SKIP_TIER_GUARD=true in .env

**File:** `apps/api/.env`, line 10

```
SKIP_TIER_GUARD=true
```

**File:** `apps/api/src/companion/tier.guard.ts`, line 14

```typescript
if (process.env.SKIP_TIER_GUARD === 'true') return true; // bypasses all checks
```

**Risk:** MEDIUM. This bypasses ALL subscription/tier checks for companion AI features. If left enabled in production, every user gets premium AI access for free.

**Fix:** Set `SKIP_TIER_GUARD=false` in `.env`. Add a guard in `tier.guard.ts` that checks `NODE_ENV` and refuses to honor the bypass in production.
