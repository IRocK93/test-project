# 03 — API Design Audit

**Date:** 2026-06-17
**Severity Score:** 🟠 High (5 High, 5 Medium, 6 Low)
**Verdict:** Core CRUD is exemplary. Surface degrades sharply outside that: half the controllers accept untyped bodies.

---

## Summary

The BabyMon REST API is well-designed at its core — feed-logs, sleep-logs, milestones, health-records, and baby-mon share an identical, well-typed controller pattern with typed DTOs and a consistent `{ items, total, skip, take }` pagination envelope. However, the **API surface quality degrades sharply beyond that core**: roughly half the controllers (allergies, medical-team, media, admin, journal, growth, notifications, stripe, subscriptions, photos) accept `@Body() body: any` or plain inline types that bypass `class-validator` entirely, produce no OpenAPI schema, and ship zero contract guarantees to consumers. There is **no global ExceptionFilter**, **no `@ApiResponse` decorators anywhere**, **no API versioning**, **inconsistent status codes**, and **inconsistent pagination** (page/limit in admin, skip/take elsewhere, none in growth/journal/media). The `/api/docs` Swagger UI is publicly accessible with no auth. Net verdict: a **functional MVP-grade API** that needs a contract-hardening pass before any external consumer or stable mobile SDK can rely on it.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| AD01 | 🟠 High | **Allergies POST: `@Body() body: any`** | `allergies.controller.ts:21,27` | `async create(..., @Body() body: any)` — no DTO. `ValidationPipe` has no metatype to validate; any JSON payload is passed directly to Prisma. | Create `CreateAllergyDto` + `CreateAllergyEventDto` with `class-validator` decorators. |
| AD02 | 🟠 High | **Medical-team POST: `@Body() b: any`** | `medical-team.controller.ts:17` | `async create(..., @Body() b: any)` — no DTO, no validation. | Create `CreateMedicalTeamMemberDto`. |
| AD03 | 🟠 High | **Media upload: `@Body() body: any` + no size/MIME validation** | `media.controller.ts:14,20,24-31` | `Buffer.from(fileData, 'base64')` with no size cap or MIME type check. Presigned URL endpoint also uses inline body. | Create `UploadMediaDto` with validation; cap file size; reject non-image MIME types. |
| AD04 | 🟠 High | **Admin status/role: inline `{ isActive }` / `{ role }` — no enum** | `admin.controller.ts:38,48` | `@Body() body: { isActive: boolean }` and `@Body() body: { role: string }` — TypeScript-only, erased at runtime. Any role string (e.g., `"SUPERADMIN"`) passes. | Create `UpdateUserStatusDto` + `UpdateUserRoleDto` with `@IsEnum(Role)`. |
| AD05 | 🟠 High | **Journal returns `any[]` / `Promise<any>`** | `journal.controller.ts:25,31,37,43` | `Promise<any[]>` — no response contract. OpenAPI sees opaque objects. | Type returns against entity interfaces or response DTOs. |
| AD06 | 🟡 Medium | **No global ExceptionFilter** | None — grep for `ExceptionFilter`/`@Catch` returns 0 hits | Nest default `{ statusCode, message, error }` varies by exception type. No correlation ID, no stable `code` field. | Add `AllExceptionsFilter` emitting `{ statusCode, error, message, code, requestId, timestamp }` consistently. |
| AD07 | 🟡 Medium | **No `@ApiResponse` decorators anywhere** | 0 hits for `@ApiResponse`/`@ApiBadRequestResponse`/`@ApiNotFoundResponse` across `src/` | OpenAPI shows no 4xx/5xx schemas. Consumers cannot discover error shapes. | Add `@ApiResponse({ status: 400 })`, `404`, `401`, `403`, `429` to controllers. |
| AD08 | 🟡 Medium | **Inconsistent pagination** | Growth returns bare array (`growth.service.ts:119`); Admin uses `page`/`limit`; core CRUD uses `skip`/`take` | Mixed pagination styles across resources. | Standardize on `{ items, total, skip, take }` + `PaginationDto` everywhere. |
| AD09 | 🟡 Medium | **No idempotency** | All POST endpoints (feed-logs, milestones, sleep-logs, etc.) | Two identical POSTs create duplicate records + double-award XP + double-fire badge checks. No `Idempotency-Key` header handling. | Accept `Idempotency-Key` header, store hash in unique column, return cached response on replay. |
| AD10 | 🟡 Medium | **No API versioning** | `main.ts` — no `enableVersioning` call | Every breaking change will break all clients simultaneously. | Add `app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' })`. |
| AD11 | 🔵 Low | **Swagger UI publicly accessible** | `main.ts:68` | `/api/docs` — no guard, no env gate. | Gate behind `NODE_ENV !== 'production'` or basic-auth middleware. |
| AD12 | 🔵 Low | **Inconsistent status codes on POST** | Stripe POSTs use `@HttpCode(200)`; resource creates use Nest default 201 | Same logical operation (create) returns different codes depending on controller. | Standardize: 201 for creation, 200 for actions. |
| AD13 | 🔵 Low | **Photos controller duplicates Media controller** | `photos.controller.ts:7-52` | Full alias "for the Flutter app" — two contracts for same resource. Drift risk. | Pick one path. If alias needed, document and share DTOs. |
| AD14 | 🔵 Low | **`dev-override-trial` is `@Public()`** | `subscriptions.controller.ts:21` | Decorated `@Public()` — only NODE_ENV check protects. | Remove `@Public()`, require admin auth, or delete endpoint. |
| AD15 | 🔵 Low | **No rate-limit headers exposed** | `app.module.ts:40-44` | ThrottlerGuard returns 429 but no `Retry-After`/`X-RateLimit-*` headers. | Configure `addHeaders` in ThrottlerModule options. Document limits in OpenAPI. |
| AD16 | 🔵 Low | **Mixed `@Request() req: any` vs `@CurrentUser('id')`** | baby-mon/milestones/feed-logs use `req: any`; growth/media/admin use `@CurrentUser('id')` | `CurrentUser` decorator exists but inconsistently adopted. | Migrate all controllers to `@CurrentUser('id')` for typed, testable user resolution. |

---

## Route Table (global prefix `/api`)

| Method | Path | Controller | Body DTO? |
|---|---|---|---|
| POST | `/api/auth/register` | auth | ✅ `RegisterDto` |
| POST | `/api/auth/login` | auth | ✅ `LoginDto` |
| POST | `/api/auth/refresh` | auth | ✅ `RefreshTokenDto` |
| POST | `/api/auth/forgot-password` | auth | ✅ `ForgotPasswordDto` |
| POST | `/api/auth/reset-password` | auth | ✅ `ResetPasswordDto` |
| GET | `/api/auth/verify-email` | auth | — |
| GET | `/api/auth/profile` | auth | — |
| POST | `/api/auth/logout` | auth | ✅ `LogoutDto` |
| GET/PATCH/DELETE | `/api/users/me` | users | ✅ DTOs |
| GET/POST | `/api/baby-mons` | baby-mon | ✅ DTOs |
| GET/PATCH/DELETE | `/api/baby-mons/:id` | baby-mon | ✅ DTOs |
| GET | `/api/baby-mons/:id/stage` | baby-mon | — |
| POST/GET | `/api/baby-mons/:babyMonId/milestones` | milestones | ✅ DTOs |
| GET/PATCH/DELETE | `/api/milestones/:id` | milestones | ✅ DTOs |
| POST/GET | `/api/baby-mons/:babyMonId/feed-logs` | feed-logs | ✅ DTOs |
| GET/PATCH/DELETE | `/api/feed-logs/:id` | feed-logs | ✅ DTOs |
| POST/GET | `/api/baby-mons/:babyMonId/sleep-logs` | sleep-logs | ✅ DTOs |
| GET/PATCH/DELETE | `/api/sleep-logs/:id` | sleep-logs | ✅ DTOs |
| POST/GET | `/api/baby-mons/:babyMonId/health-records` | health-records | ✅ DTOs |
| GET/PATCH/DELETE | `/api/health-records/:id` | health-records | ✅ DTOs |
| POST/GET/DELETE | `/api/baby-mons/:babyMonId/allergies` | allergies | ❌ `any` |
| POST/DELETE | `/api/baby-mons/:babyMonId/allergies/:allergyId/events` | allergies | ❌ `any` |
| POST | `/api/baby-mons/:babyMonId/allergies/:allergyId/cure` | allergies | — |
| POST | `/api/baby-mons/:babyMonId/allergies/:allergyId/reactivate` | allergies | — |
| POST/DELETE | `/api/baby-mons/:babyMonId/allergies/events/clear-all` | allergies | — |
| GET/POST/DELETE | `/api/baby-mons/:babyMonId/medical-team` | medical-team | ❌ `any` |
| GET/POST | `/api/baby-mons/:babyMonId/growth` | growth | ❌ inline |
| GET | `/api/baby-mons/:babyMonId/growth/analysis` | growth | — |
| DELETE | `/api/baby-mons/:babyMonId/growth/:id` | growth | — |
| GET/POST | `/api/baby-mons/:babyMonId/media` | media | ❌ `any` |
| POST | `/api/baby-mons/:babyMonId/media/upload` | media | ❌ `any` |
| POST | `/api/baby-mons/:babyMonId/media/presigned-url` | media | ❌ inline |
| DELETE | `/api/baby-mons/:babyMonId/media/:id` | media | — |
| GET/POST | `/api/baby-mons/:babyMonId/photos` | photos | ❌ inline |
| DELETE | `/api/baby-mons/photos/:id` | photos | — |
| GET | `/api/baby-mons/:babyMonId/journal` | journal | — |
| GET | `/api/baby-mons/:babyMonId/journal/proposals` | journal | — |
| POST | `/api/baby-mons/:babyMonId/journal/proposals/:id/approve` | journal | — |
| POST | `/api/baby-mons/:babyMonId/journal/proposals/:id/reject` | journal | — |
| GET | `/api/baby-mons/:babyMonId/badges` | badges | — |
| GET | `/api/badges/definitions` | badges (`@Public`) | — |
| GET | `/api/baby-mons/:babyMonId/evolution` | evolution | — |
| GET | `/api/baby-mons/:babyMonId/evolution/summary` | evolution | — |
| GET | `/api/baby-mons/:babyMonId/export` | export | — |
| GET/POST/DELETE | `/api/linked-accounts` | linked-accounts | ✅ DTOs |
| POST | `/api/linked-accounts/invite` | linked-accounts | ✅ DTOs |
| POST | `/api/linked-accounts/invitations/:id/respond` | linked-accounts | ✅ DTOs |
| POST | `/api/linked-accounts/baby-mon` | linked-accounts | ✅ DTOs |
| POST | `/api/notifications/register-device` | notifications | ❌ inline |
| POST | `/api/notifications/test` | notifications | ❌ inline |
| GET | `/api/subscriptions/current` | subscriptions | — |
| POST | `/api/subscriptions/dev-override-trial` | subscriptions (`@Public`) | ❌ inline |
| POST | `/api/subscriptions/webhook` | stripe | raw (Stripe) |
| POST | `/api/subscriptions/create-checkout-session` | stripe | ❌ inline |
| POST | `/api/subscriptions/create-portal-session` | stripe | — |
| POST | `/api/subscriptions/cancel` | stripe | — |
| GET | `/api/stage-content/baby-mon/:babyMonId` | stage-content | — |
| GET | `/api/admin/users` | admin | ✅ query |
| GET | `/api/admin/users/:id` | admin | — |
| PATCH | `/api/admin/users/:id/status` | admin | ❌ inline |
| PATCH | `/api/admin/users/:id/role` | admin | ❌ inline |
| GET | `/api/admin/audit-logs` | admin | ✅ query |
| GET | `/api/admin/stats` | admin | — |

---

## Things Done Well

1. **Core CRUD is exemplary** — feed-logs, sleep-logs, milestones, health-records, baby-mon share an identical well-typed pattern.
2. **ValidationPipe hardened globally** — `whitelist: true, forbidNonWhitelisted: true, transform: true`.
3. **Consistent pagination on core resources** — `{ items, total, skip, take }` with `PaginationDto` capped at `Max(100)`.
4. **Layered rate limiting** — AUTH (30/min), SENSITIVE (20/min), DEFAULT (100/min) with per-route overrides.
5. **Soft-delete pattern** — Consistent `deletedAt` filtering on read operations.
6. **Edit-window proposal pattern** — Edits after 10 min become `EntryChangeProposal` — thoughtful for co-parenting data integrity.
7. **`@ApiTags` on every controller**, `@ApiBearerAuth` on protected ones, `@ApiOperation` summaries universal.
8. **`PaginationDto`** exists and is reused across core resources.

---

## Action Plan

| # | Action | Effort | Fixes |
|---|---|---|---|
| 1 | Add global `AllExceptionsFilter` standardizing `{ statusCode, error, message, code, requestId, timestamp }`. | M | AD06 |
| 2 | Author DTOs for all `any`/inline bodies (allergies, medical-team, media, admin, growth, notifications, stripe). | M | AD01-AD05 |
| 3 | Standardize pagination: adopt `{ items, total, skip, take }` everywhere. Add `from`/`to`/`sort` query DTOs. | M | AD08 |
| 4 | Add `Idempotency-Key` header support on create endpoints. | L | AD09 |
| 5 | Enable URI versioning (`/api/v1/...`). | S | AD10 |
| 6 | Gate `/api/docs` behind non-prod or basic-auth. Delete or secure `dev-override-trial`. | S | AD11, AD14 |
| 7 | Normalize HTTP status codes (201 create, 200 action, 204/200 delete). | S | AD12 |
| 8 | Add `@ApiResponse` decorators (400/401/403/404/409/429) to controllers. | M | AD07 |
| 9 | Delete `/photos` alias or unify with `/media`. Migrate `@Request() req: any` → `@CurrentUser('id')`. | S | AD13, AD16 |
| 10 | Configure ThrottlerGuard response headers (`Retry-After`, `X-RateLimit-*`). | S | AD15 |
