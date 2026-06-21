# API & Data Architecture Audit Report

## Grade: B-

## Summary

The BabyMon API is a NestJS application with 26 modules, a 31-model Prisma schema, and a clear domain-driven structure. The foundation is solid: proper API versioning (`/api/v1`), a global exception filter with Prisma error mapping, correlation ID middleware, structured logging via pino, and health check endpoints. However, the codebase exhibits material inconsistencies in pagination, soft-delete policy, response envelope format, and subscription tier enforcement. Two overlapping proposal systems (`EntryChangeProposal` and `JournalProposal`) create confusion. Swagger documentation lacks `@ApiResponse` annotations entirely. Several critical indexes and foreign-key relations are missing from the schema. The stage calculation logic is sound, and the auth service demonstrates mature patterns. Overall, the architecture is functional but would benefit from a consistency pass and hardening in specific areas before production deployment.

## Findings

| # | Severity | File:Line | Issue | Impact | Recommendation |
|---|----------|-----------|-------|--------|----------------|
| 1 | **CRITICAL** | `subscriptions.service.ts:56-83` | `checkWriteAccess()` is defined but never called from any write controller endpoint. Subscription tier enforcement is entirely absent at the API boundary. | Any user, even after trial expiration, can create/update/delete resources without a paid subscription. | Add a `SubscriptionGuard` or call `checkWriteAccess()` at the top of every POST/PATCH/DELETE handler. |
| 2 | **CRITICAL** | `schema.prisma:363-374` | `JournalProposal` model has `proposedById` field (string) with no `@relation` to the `User` model. | Orphaned records, no referential integrity, no way to eagerly load the proposer's name. | Add `proposer User @relation(fields: [proposedById], references: [id])` and a `@@index([proposedById])`. |
| 3 | **HIGH** | `schema.prisma:571-581` | `SavedAdvice` model has `babyMonId` (string) with no relation to `BabyMon`. | Referential integrity gap; cascade deletes on BabyMon will leave dangling SavedAdvice rows. | Add `babyMon BabyMon @relation(...)`. |
| 4 | **HIGH** | `journal-proposals.service.ts:60-115` | `approveProposal()` applies entry update and proposal status change in **two separate non-transactional calls**. | If entry update succeeds but proposal status update fails, database enters inconsistent state. | Wrap in `this.prisma.$transaction([...])`. |
| 5 | **HIGH** | `journal.service.ts:64-107` | `respondToProposal()` has the same transaction risk: applies payload changes and updates proposal status without transaction boundary. | Same race condition / partial-failure risk. | Wrap both operations in `$transaction`. |
| 6 | **HIGH** | `baby-mon.service.ts:154-189` | `delete()` performs **hard delete** on BabyMon and children, despite `BabyMon` model having a `deletedAt` column. | Contradicts soft-delete pattern used for `User`, `Milestone`, `FeedLog`. GDPR / audit trail lost. | Use soft-delete (`deletedAt: new Date()`) for BabyMon, propagate to children. Reserve hard delete for cleanup job. |
| 7 | **HIGH** | `schema.prisma:284-300` | `Subscription` model has no index on `userId`, yet every subscription query filters by `userId`. | Full table scan on every subscription lookup. | Add `@@index([userId])`. |
| 8 | **HIGH** | `schema.prisma:315-332` | `EntryChangeProposal` has no indexes at all. Queries filter by `babymonId`, `proposerUserId`, and `status`. | Every proposal lookup performs full table scan. | Add `@@index([babymonId])`, `@@index([proposerUserId])`, `@@index([status])`. |
| 9 | **MEDIUM** | `schema.prisma:274-282` | `RefreshToken` has no index on `userId`. | Slower token lookups under load. | Add `@@index([userId])`. |
| 10 | **MEDIUM** | `schema.prisma:302-313` | `AuditLog` has no index on `babymonId` or `actorUserId`. | Slower audit queries, especially for admins. | Add `@@index([babymonId])` and `@@index([actorUserId])`. |
| 11 | **MEDIUM** | `baby-mon.service.ts:79-97` | `findAll()` accepts raw `skip` and `take` parameters instead of using shared `PaginationDto`. | Inconsistent pagination API. | Refactor to accept `PaginationDto`. |
| 12 | **MEDIUM** | `global-exception.filter.ts:24-39` | `PrismaClientValidationError` and `PrismaClientInitializationError` are not handled -- they fall through to generic 500. | In production, validation errors leak internal details to clients. | Add explicit catch blocks for validation errors (400) and initialization errors (503). |
| 13 | **MEDIUM** | `auth.service.ts:140-147` | `catch` block in `register()` catches **all errors** and rethrows as `InternalServerErrorException`. | Masks real bugs; a `TypeError` becomes generic "Failed to create account" instead of 500 stack trace. | Only catch `PrismaClientKnownRequestError`, rethrow everything else. |
| 14 | **MEDIUM** | All controllers | Zero uses of `@ApiResponse()` / `@ApiCreatedResponse()` decorators across entire codebase. | Swagger UI shows no response shapes or example payloads. | Add `@ApiResponse` decorators to all controller methods. |
| 15 | **LOW** | `baby-mon.service.ts:222-237` | Month calculation uses `30 * 86400000` ms (fixed 30-day months). | Stage transitions may be off by 1-3 days on month boundaries. | Use proper calendar-month calculation. |
| 16 | **LOW** | `PaginationDto` | `PaginationDto` includes a rogue `type?: string` field belonging to journal queries, not generic pagination. | Leaks domain-specific concerns into shared DTO. | Remove `type` from `PaginationDto`. |
| 17 | **LOW** | `export/export.service.ts:31-52` | Export data missing: `sleepLogs`, `allergies`, `allergyEvents`, `media` metadata, `linkedAccounts`, `subscription` info. | Incomplete GDPR data export (~40% of data not exportable). | Add all missing entity types to export payload. |

## Top 5 Architectural Risks

1. **Subscription tier enforcement is a no-op.** `checkWriteAccess()` exists and is well-written, but no controller calls it. The entire monetization model depends on this guard.
2. **Dual proposal systems create confusion and inconsistency.** `EntryChangeProposal` and `JournalProposal` overlap in purpose but differ in schema, state machine rules, and service logic.
3. **Missing indexes on high-traffic lookup columns.** `Subscription.userId`, `EntryChangeProposal.babymonId`, `JournalProposal.proposedById`, `AuditLog.babymonId`, `RefreshToken.userId` all lack indexes.
4. **Inconsistent soft-delete policy.** Some entities hard-delete, others soft-delete. No declared policy; choice appears arbitrary per service.
5. **Missing transaction boundaries in proposal resolution.** Both `approveProposal()` and `respondToProposal()` mutate the entry and update the proposal status in separate Prisma calls.

## Top 3 Strengths

1. **Authentication service is robust.** Registration with age gating (18-120), consent validation, email verification, password reset with full token rotation, social login with trial provisioning, bcrypt cost 12, transactional user+subscription creation.
2. **Global exception filter with Prisma mapping.** Catches all exceptions, maps Prisma codes to HTTP statuses (P2002->409, P2025->404, P2003->400), consistent JSON envelope.
3. **Health check endpoints are comprehensive.** Three endpoints: full status with DB latency, lightweight liveness for Kubernetes, readiness with DB check. Production-grade.

## Module Dependency Analysis

Star topology with `PrismaModule` and `ConfigModule` at center. No circular imports detected. `BadgesModule` and `EvolutionModule` are tightly coupled and could merge. `StripeModule` and `SubscriptionsModule` violate single-writer principle. `JournalModule` owns two overlapping concerns that should be separate services.

## Schema Design Review

Well-normalized. N+1 avoidance via `Promise.all` and `include`. Index coverage is the primary gap -- 8 critical indexes missing. Two referential integrity gaps: `JournalProposal.proposedById` and `SavedAdvice.babyMonId` lack `@relation` directives.

## Business Logic Assessment

**BabyMon Stage Calculation:** Sound for all three `stageStartType` values (CONCEIVED, BORN, IDEA). Uses medically standard conception derivation from LMP + 14 days. Month cutoff uses fixed 30-day math which could be more precise.

**Journal Proposal State Machine:** Two separate state machines. `JournalProposal` properly guards against re-resolution. `respondToProposal()` lacks the re-resolution guard.

**Subscription Tier Enforcement:** `SubscriptionsService` correctly computes trial status, active subscription status, and days remaining. But `checkWriteAccess()` is never called from any controller.
