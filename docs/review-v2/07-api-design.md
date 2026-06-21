# S07 — API Design Audit

**Date:** 2026-06-18 | **Overall Severity:** 🟠 High

The API has 80+ endpoints across 25 controllers with good Swagger basics but suffers from **inconsistent REST patterns, missing DTOs on critical endpoints, three incompatible error response shapes, and widespread unbounded list queries**.

---

## Findings

### AD-C01 | 🔴 CRITICAL | Two Endpoints Accept Untyped @Body() — Validation Bypass

**Location:** `photos.controller.ts:22`, `subscriptions.controller.ts:24`

**What:** `PhotosController.uploadPhoto` accepts `@Body() body: { fileName: string; fileType: string; fileData: string }` and `SubscriptionsController.devOverrideTrial` accepts `@Body() body: { userId: string; days: number }`. Both bypass `class-validator` — `forbidNonWhitelisted` is ineffective, arbitrary extra fields pass through.

**Remediation:** Create `UploadPhotoDto` and `DevOverrideTrialDto` with proper `class-validator` decorators. For the dev endpoint, also add `@UseGuards(JwtAuthGuard, RolesGuard)` with `@Roles('ADMIN')`.

---

### AD-C02 | 🔴 CRITICAL | Duplicate Stripe Webhook Routes

**Location:** `stripe-webhook.controller.ts` (POST /webhooks/stripe) and `stripe.controller.ts` (POST /subscriptions/webhook)

**What:** Two webhook endpoints exist. The former is non-functional (returns `{ received: true }` without verification). The latter has full Stripe signature verification and event processing. Ambiguous configuration risk for Stripe dashboard setup.

**Remediation:** Delete `stripe-webhook.controller.ts`.

---

### AD-C03 | 🔴 CRITICAL | 9 List Endpoints Return Unbounded Results

**Location:** AllergiesController, MedicalTeamController, MediaController, PhotosController, GrowthController, CompanionController (advice), LinkedAccountsController (×2), JournalController

**What:** These list endpoints have no pagination. As data grows, they'll return increasingly large payloads with no client-side control.

**Remediation:** Apply `PaginationDto` (skip/take) to all list endpoints. Add pagination response envelope with `total` count.

---

### AD-H01 | 🟠 HIGH | Flat Route Pattern Breaks REST Hierarchy

**Location:** milestones.controller.ts, feed-logs.controller.ts, health-records.controller.ts, sleep-logs.controller.ts

**What:** Create/list use nested routes (`baby-mons/:babyMonId/milestones`) but GET/PATCH/DELETE by ID use flat routes (`/milestones/:id`). The parent-child relationship is lost for single-resource operations.

**Remediation:** Standardize on fully nested routes: `baby-mons/:babyMonId/milestones/:id`.

---

### AD-H02 | 🟠 HIGH | No API Versioning

**Location:** `main.ts:32` — only `app.setGlobalPrefix('api')`

**What:** No `/v1/` prefix. All breaking changes affect every client simultaneously.

**Remediation:** Change to `app.setGlobalPrefix('api/v1')`. Plan v2 strategy.

---

### AD-H03 | 🟠 HIGH | Zero @ApiResponse Decorators in Entire Codebase

**Location:** All 25 controllers

**What:** Swagger shows no response schemas, error status codes, or example responses for any endpoint. API consumers cannot know what to expect.

**Remediation:** Add `@ApiResponse` decorators to all endpoints with status codes and response DTOs.

---

### AD-H04 | 🟠 HIGH | Three Incompatible Error Response Shapes

**Location:** auth.service.ts (Shape A: `{ message, error }`), other services (Shape B: plain string), auth.service.ts getProfile (Shape C: plain string exception within auth service)

**What:** No global error shape. Clients must handle three different response formats.

**Remediation:** Create global exception filter. Standardize on RFC 7807 Problem Details: `{ type, title, status, detail, instance }`.

---

### AD-M01 | 🟡 MEDIUM | Inconsistent Pagination Patterns

**What:** 5 controllers use `PaginationDto` (skip/take), AdminController uses raw `page`/`limit` with no DTO.

**Remediation:** Standardize on `PaginationDto`. Add `total` to response envelope.

---

### AD-M02 | 🟡 MEDIUM | Profile Endpoint Duplication

**Location:** `GET /auth/profile` and `GET /users/me`

**What:** Both return the same user data. Unnecessary duplication.

**Remediation:** Remove `/auth/profile`. Keep `/users/me` as the canonical user profile endpoint.

---

### AD-M03 | 🟡 MEDIUM | 10 Swagger Tags Missing from DocumentBuilder

**Location:** `main.ts:50-65`

**What:** allergies, medical-team, badges, sleep-logs, photos, partners, companion, stage-content, admin, health tags are used on controllers but not registered in DocumentBuilder. Auto-generated without descriptions.

**Remediation:** Register all tags in DocumentBuilder with descriptions.

---

### AD-M04 | 🟡 MEDIUM | Inconsistent Route Naming

**What:** `StageContentController` uses `stage-content/baby-mon/:id` (singular "baby-mon") while every other controller uses `baby-mons` (plural).

**Remediation:** Standardize on plural `baby-mons`.

---

### AD-M05 | 🟡 MEDIUM | Missing Validation Constraints

**What:** `CreateAllergyDto.severity` accepts any string. `CreateGrowthRecordDto.unit` accepts any string.

**Remediation:** Add `@IsIn([...])` or `@IsEnum()` constraints.

---

### AD-M06 | 🟡 MEDIUM | No @ApiBearerAuth on StageContentController

**What:** Uses `JwtAuthGuard` but lacks Swagger auth decorator — Swagger won't show lock icon.

**Remediation:** Add `@ApiBearerAuth()`.

---

### AD-L01 | 🔵 LOW | No @HttpCode(201) on Create Endpoints

**What:** All POST create endpoints rely on NestJS default (201). Implicitly correct but not explicit.

---

### AD-L02 | 🔵 LOW | No @HttpCode(204) on DELETE Endpoints

**What:** Delete operations return 200 with body instead of 204 No Content.

---

### AD-L03 | 🔵 LOW | Full Prisma Models Returned Without Field Selection

**What:** Most services return complete models. While `passwordHash` is excluded in auth/user services, other internal fields may leak in list endpoints.

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 3 |
| 🟠 High | 4 |
| 🟡 Medium | 6 |
| 🔵 Low | 3 |
| **Total** | **16** |
