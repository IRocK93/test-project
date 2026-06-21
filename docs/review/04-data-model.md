# 04 — Data Model Audit

**Date:** 2026-06-17
**Severity Score:** 🟠 High (1 Critical, 5 High, 5 Medium, 4 Low)
**Verdict:** Well-structured schema with solid indexing, but ~15 string fields should be Prisma enums and key indexes are missing on high-traffic query paths.

---

## Summary

The BabyMon Prisma schema (21 models) is generally well-structured for an early-stage product: UUID primary keys, consistent timestamp naming, proper indexes on foreign keys and query columns for core entities, and thoughtful soft-delete on mutable models. However, several issues will bite as data volume grows: **~15 `String` fields** that should be Prisma enums, **missing indexes** on `AuditLog`, `Subscription`, `RefreshToken`, and `EntryChangeProposal` query columns, **no `@@unique([userId])` on Subscription** (allowing duplicate active subscriptions), a **critical unused `better-sqlite3` production dependency**, and an **inconsistent delete strategy** (User soft-deletes, BabyMon hard-deletes). The data-access layer is clean — good use of `select`, `include`, and `$transaction` — but create operations in milestones/feed-logs/sleep-logs each perform 3-4 sequential non-transactional writes.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| DM01 | 🔴 Critical | **`better-sqlite3` in production deps — unused** | `apps/api/package.json:35` | `"better-sqlite3": "^12.6.2"` in `dependencies`. No imports in `src/`. Schema declares `datasource db { provider = "postgresql" }`. | Remove from `dependencies` or move to `devDependencies` if used for testing. |
| DM02 | 🔴 Critical | **No unique constraint on Subscription** | `schema.prisma:289-306` | No `@@unique([userId])` — multiple active subscriptions per user possible. Workaround: deterministic IDs (`stripe-${userId}`, `dev-${userId}`) in stripe/subscriptions services. | Add `@@unique([userId])` so only one subscription per user is DB-enforced. |
| DM03 | 🟠 High | **~15 `String` fields should be Prisma enums** | `schema.prisma:15,59,72,90,107-108,112,155,174,193,199,219,248,269,309,328,396,419,453` | `User.role`, `LinkedAccount.status`, `Badge.badgeType`, `Subscription.tier`, `AuditLog.eventType`, `EntryChangeProposal.status`, `GrowthRecord.type`, `Allergy.severity`, `MedicalTeam.specialty`, etc. — all free-form `String`. | Convert to Prisma enums for DB-level validation, client type safety, and auto-complete. |
| DM04 | 🟠 High | **Missing indexes: AuditLog** | `schema.prisma:308-320` | No `@@index` on `createdAt` or `actorUserId`. Query patterns: `admin.service.ts:128` (orderBy createdAt + filter by actorUserId), `journal.service.ts:39` (babymonId + createdAt sort). | Add `@@index([babymonId, createdAt])` and `@@index([actorUserId])`. |
| DM05 | 🟠 High | **Missing indexes: Subscription** | `schema.prisma:289-306` | No `@@index([userId])`. Queried in `subscriptions.service.ts:9` and `stripe.service.ts:52,94,283`. | Add `@@index([userId])` and `@@index([stripeSubscriptionId])`. |
| DM06 | 🟠 High | **Missing indexes: RefreshToken** | `schema.prisma:278-287` | No `@@index([userId])`, no `@@index([expiresAt])`. Deleted by userId at `users.service.ts:76`. | Add `@@index([userId])` and `@@index([expiresAt])`. |
| DM07 | 🟠 High | **Missing index: EntryChangeProposal** | `schema.prisma:322-340` | No index. Queried by `{ babymonId, status: 'PENDING' }` at `journal.service.ts:38`, `journal-proposals.service.ts:30`. | Add `@@index([babymonId, status])`. |
| DM08 | 🟡 Medium | **Inconsistent delete strategy** | `baby-mon.service.ts:148-166` vs `users.service.ts:74-136` | User soft-deletes (sets `deletedAt`). BabyMon hard-deletes with manual cascade. AuditLog FK to BabyMon uses `SET NULL` so logs lose their reference. | Choose one strategy. Recommended: soft-delete everything. Add Prisma soft-delete middleware. |
| DM09 | 🟡 Medium | **Race condition: create ops not transactional** | `milestones.service.ts:27-61`, `feed-logs.service.ts:26-48`, `sleep-logs.service.ts:26-48` | Create → XP increment → badge check → level-up → audit log — 5 sequential writes, none wrapped in `$transaction`. | Wrap in `$transaction` with `tx` threaded through `BadgesService`/`XpService`. |
| DM10 | 🟡 Medium | **`JournalProposal.changes` is `Json` with no validation** | `schema.prisma:384` | `changes Json` — any arbitrary JSON can be inserted. No Zod/Joi validation in service layer. | Add Zod schema validation at DTO/service layer for `{ field, oldValue, newValue }` shape. |
| DM11 | 🟡 Medium | **Missing index: User.deletedAt** | `schema.prisma:22` | `admin.service.ts:162` counts users with `deletedAt: null` — requires full table scan. | Add `@@index([deletedAt])` to User. |
| DM12 | 🟡 Medium | **`EntryChangeProposal.status` string vs `JournalProposal.status` enum** | `schema.prisma:329` vs `:377` | `JournalProposal.status` correctly uses `ProposalStatus` enum. `EntryChangeProposal` uses plain `String` — inconsistency. | Unify: both should use `ProposalStatus` enum. |
| DM13 | 🔵 Low | **`Allergy.triggers` stored as comma-separated String** | `schema.prisma:416` | `triggers String? // comma-separated triggers` — anti-pattern. | Change to `String[]` like `traits` on BabyMon, or junction table for normalized querying. |
| DM14 | 🔵 Low | **`StripeEvent.data` stored as `String` not `Json`** | `schema.prisma:347` | `JSON.stringify(event.data.object)` — stored as text. Cannot query individual fields. | Change to `Json` type for structured storage. |
| DM15 | 🔵 Low | **`payloadJson`/`proposedPayloadJson` stored as `String`** | `schema.prisma:314,331` | Serialized JSON as string — cannot query with Prisma JSON filters. | Change to `Json` type. |
| DM16 | 🔵 Low | **Seed data uses nil UUIDs** | `prisma/seed.ts:6-7` | `SYSTEM_USER_ID = '00000000-0000-0000-0000-000000000001'` — nil UUID space. Extremely unlikely collision but pedantically wrong. | Use UUID v5 with namespace or explicit well-known UUIDs. |

---

## Things Done Well

1. **UUID primary keys everywhere** — correct for distributed systems, avoids enumeration attacks.
2. **Consistent timestamp pattern** — `createdAt @default(now())`, `updatedAt @updatedAt` on mutable entities.
3. **Comprehensive indexing on FK columns** — `@@index([babymonId])`, `@@index([userId])`, `@@index([happenedAt])` on all log-type models.
4. **Good use of `select`** — services like `milestones.service.ts:76-79` use `select: { id, name }` to limit returned data.
5. **Pagination implemented** — `findAll()` methods accept `skip`/`take` with `count()` for total. PaginationDto caps limit at 100.
6. **Transaction usage on critical paths** — user registration, password reset, BabyMon deletion, badge awarding with race-condition protection.
7. **Junction tables done properly** — `LinkedAccount` and `LinkedBabyMon` with `@@unique` on the pair, proper `onDelete: Cascade`.
8. **Seed data uses `upsert`** — idempotent, safe to re-run.
9. **`ProposalStatus` enum exists** on JournalProposal — proves the pattern works.
10. **Non-blocking audit logging** — `AuditService` catches errors so audit failures don't crash user requests.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | Remove `better-sqlite3` from production deps. | S |
| 2 | Add `@@unique([userId])` on Subscription. | S |
| 3 | Add missing indexes: AuditLog (2), Subscription (2), RefreshToken (2), EntryChangeProposal (1), User.deletedAt (1). | S |
| 4 | Convert ~15 String fields to Prisma enums (migration per model group). | M |
| 5 | Fix cascade delete: set `AuditLog.babymonId → onDelete: SetNull`, let FK cascade handle the rest. Delete redundant manual loops. | M |
| 6 | Decide soft-delete strategy; add Prisma middleware for `deletedAt` filtering. | M |
| 7 | Wrap create ops in `$transaction` (milestones, feed-logs, sleep-logs). | M |
| 8 | Standardize `babymonId` vs `babyMonId` naming across schema. | M |
| 9 | Add Zod validation for `JournalProposal.changes`. | S |
| 10 | Change `StripeEvent.data`, `payloadJson`, `proposedPayloadJson` to `Json` type. | S |
| 11 | Unify EntryChangeProposal.status to use `ProposalStatus` enum. | S |
| 12 | Fix `Allergy.triggers` to `String[]`. | S |
| 13 | Squash migrations before production (3 → 1). | M |
