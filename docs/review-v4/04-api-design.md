# BabyMon API Design Audit — v4

**Date:** 2026-06-22
**Overall Grade: C+ (78/100)**

---

## 1. REST Conventions

### URL Structure: B- (72/100)

**Strengths:**
- Clean kebab-case resource names
- Global `/api` prefix correctly applied
- Plural noun convention mostly respected

**Critical Issues:**
1. **Mixed nesting strategies** — Three different routing patterns coexist:
   - Fully nested: `baby-mons/:babyMonId/growth`
   - Mixed flat/nested: list at `baby-mons/:babyMonId/milestones` but single at `/milestones/:id`
   - Flat: `/linked-accounts`, `/badges/definitions`
2. **Flat single-resource routes break hierarchy** — `GET /milestones/:id` loses parent-child context
3. **Duplicate photo/media routes** — Two controllers serving the same resource at different paths
4. **Non-standard nesting direction** — `stage-content/:babyMonId` inverts expected hierarchy

### HTTP Method Usage: A (93/100)
- POST for creation/actions, GET for reads, PATCH for partial updates, DELETE for deletions — all correct
- Custom actions use POST on sub-resources

### Status Codes: B (80/100)
- Inconsistent creation status codes (Stripe uses explicit `@HttpCode(200)`, core CRUD relies on default 201)
- Deletes return three different response patterns
- No 202 Accepted for async operations

### Idempotency: F (20/100)
- **No `Idempotency-Key` header support anywhere**
- Duplicate POST will create duplicate records, double-award XP, double-fire badge checks

---

## 2. Pagination

### Score: C (65/100)

A shared `PaginationDto` exists with `skip`/`take`, but adoption is inconsistent:

| Status | Endpoints |
|--------|-----------|
| **Paginated with envelope** | baby-mons, milestones, feed-logs, health-records, sleep-logs, companion/advice |
| **Paginated but wrong pattern** | admin (uses `page`/`limit` instead of `skip`/`take`) |
| **Unpaginated (risk of unbounded results)** | allergies, medical-team, media, photos, growth, journal, linked-accounts, evolution, badges, notifications |

**9 list endpoints return unbounded results** with no pagination at all.

---

## 3. Filtering & Sorting: D (55/100)

Filtering is nearly nonexistent. Sorting is entirely absent.

Missing capabilities:
- No date range filtering on any endpoint
- No sorting parameters anywhere
- No search (text search on titles, notes)
- No multi-value filtering
- No field selection / sparse fieldsets

---

## 4. DTO Design: B (78/100)

### Validation Pipe — Excellent
```typescript
new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
  enableImplicitConversion: true,
})
```

### Critical DTO Gaps
| Issue | Location |
|-------|----------|
| `@Body() body: any` bypassing validation | allergies, medical-team, media, photos controllers |
| Inline body types (TypeScript-only, erased at runtime) | photos, subscriptions dev-override, admin status/role |
| No output/response DTOs | All controllers return raw Prisma objects |

---

## 5. API Versioning: F (30/100)

No `app.enableVersioning()` call. No version segment in URLs. Any breaking change impacts all clients simultaneously.

---

## 6. Swagger/OpenAPI: C (63/100)

**Zero `@ApiResponse` decorators** across the entire codebase. Consumers cannot discover error shapes, response schemas, or example payloads from the OpenAPI spec. Swagger UI at `/api/docs` is publicly accessible with no auth guard.

---

## 7. Client-Side Discrepancies

| Issue | Severity |
|-------|----------|
| Client calls `respondToProposal` with `{ accept, reason }` but backend has separate approve/reject endpoints | HIGH |
| Client calls `updateGrowthRecord` at `PATCH /growth/:id` but backend has no PATCH endpoint | CRITICAL |
| Client references OAuth endpoints that don't exist on backend | MEDIUM |

---

## 8. Top 3 Quick Wins

1. Add `@ApiResponse` decorators to all endpoints
2. Apply `PaginationDto` to the 9 unbounded list endpoints
3. Migrate remaining `@Body() body: any` endpoints to typed DTOs

## 9. Top 3 Architectural Fixes

1. Standardize all routes to fully nested pattern: `baby-mons/:babyMonId/resource/:id`
2. Enable API versioning
3. Delete stale `StripeWebhookController`, consolidate photos into media controller
