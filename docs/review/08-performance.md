# 08 — Performance Audit

**Date:** 2026-06-17
**Severity Score:** 🔴 Critical (4 Critical, 4 High, 5 Medium, 2 Low)
**Verdict:** Competent engineering with deliberate performance patterns. Critical issues in unbounded queries, missing indexes, and Flutter lazy-rendering.

---

## Summary

The BabyMon codebase shows competent performance engineering: Prisma transactions for cascading deletes, `Promise.all` parallelism in the export and journal services, `DataScreenMixin` cooldown/guard pattern on mobile, and proper `AnimatedBuilder` usage. However, critical structural issues will degrade at scale: **(1) unbounded `findMany`** in journal/export/growth returning entire table contents; **(2) missing database indexes** on AuditLog, Subscription, RefreshToken, and EntryChangeProposal; **(3) `shrinkWrap: true` on `ListView.builder`** in the sleep screen negating lazy loading; **(4) no image resize** before upload or cache; **(5) redundant `addListener`+`setState`** in level-up celebration doubling rebuild costs.

---

## Findings

### Backend

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| P01 | 🔴 Critical | **Unbounded queries return entire tables** | `journal.service.ts:34-38`, `export.service.ts:32-51`, `growth.service.ts:119-122` | `findMany` without `take` on milestones, feedLogs, healthRecords, growthRecords. Export fetches 5 entire tables. | Add `take` or hard cap (500 for journal, 1000 for export). Growth: last 100 records. |
| P02 | 🔴 Critical | **AuditLog missing all indexes** | `schema.prisma:308-320` | No indexes. Queried by `babymonId + createdAt` sort and `actorUserId` in admin. Table scan on every journal query. | Add `@@index([babymonId, createdAt])` and `@@index([actorUserId])`. |
| P03 | 🟠 High | **EntryChangeProposal missing compound index** | `schema.prisma:322-340` | Queried by `{ babymonId, status: 'PENDING' }`. Full scan for pending proposals. | Add `@@index([babymonId, status])`. |
| P04 | 🟠 High | **Subscription + RefreshToken missing indexes** | `schema.prisma:278-306` | Subscription queried by `userId` and `stripeSubscriptionId`. RefreshToken deleted by `userId`. No indexes. | Add `@@index([userId])` to both, `@@index([stripeSubscriptionId])` to Subscription. |
| P05 | 🟡 Medium | **Batch operations: single creates in loop** | `badges.service.ts:197-206` | For-loop `create` + `auditLog.create` sequentially inside transaction. 3+ badges = 6 sequential writes. | Use `createMany({ data: [...] })` in one batch. |
| P06 | 🟡 Medium | **User delete loops per BabyMon** | `users.service.ts:87-114` | Deletes child records per BabyMon in `for` loop instead of batched `deleteMany({ in: ids })`. | Batch with `where: { babymonId: { in: babymonIds } }`. |
| P07 | 🟡 Medium | **Badge check fetches all related records** | `badges.service.ts:148-151` | `include: { badges, milestones, feedLogs, healthRecords }` — loads ALL records for a BabyMon. Grows unbounded. | Use `_count` instead of loading full records. |
| P08 | 🔵 Low | **`findOne` for ownership check is wasteful** | `baby-mon.service.ts:117,149` | `findOne` includes `badges: true` and `_count` — heavy query for a simple ownership check. | Create `verifyOwnership(id, userId)` with `select: { id: true }`. |
| P09 | 🔵 Low | **Journal sends full unbounded entries** | `journal.service.ts:43-53` | All milestones, feedLogs, healthRecords loaded into memory, combined, sorted. No pagination. | Add `take` limits per type or overall pagination. |

### Flutter

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| P10 | 🔴 Critical | **`shrinkWrap: true` negates lazy loading in sleep list** | `sleep_screen.dart:348` | `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` forces all items to render immediately. | Remove `shrinkWrap`. Use `SliverList` inside `CustomScrollView`. |
| P11 | 🔴 Critical | **No image resize before upload** | `media.controller.ts:22-40`, `photo_grid.dart:39-44` | Backend accepts base64 up to 50MB — full camera photos stored to S3. Client displays full-res via `CachedNetworkImage` without `memCacheWidth`/`memCacheHeight`. | Server: resize to max 2048px before S3. Client: add `memCacheWidth: 300` to grid, `1200` to viewer. |
| P12 | 🟠 High | **Redundant `addListener`+`setState` in level-up animation** | `level_up_celebration.dart:140-153` | `_controller.addListener` calls `setState` every frame for 3.5s. Outer `AnimatedBuilder` on line 206 already handles rebuilds. | Remove `addListener`. Compute boolean flags from `_controller.value` directly in `AnimatedBuilder` builder. |
| P13 | 🟠 High | **Dashboard fetches serialized on first load** | `dashboard_screen.dart:168-175` | `Future.wait` parallelizes 5 fetches but `_loadCosmeticData` runs sequentially after render. Adds 300-500ms latency before badges appear. | Merge badge/definitions into main `Future.wait`. Load stage content lazily. |
| P14 | 🟡 Medium | **Hardcoded 2-second splash delay** | `splash_screen.dart:64` | `Future.delayed(const Duration(seconds: 2))` always blocks even when auth resolves in <200ms. | Use `Future.wait([authCheck, Future.delayed(800ms)])` for minimum, not forced delay. |
| P15 | 🟡 Medium | **`GridView.builder` with `shrinkWrap` in photo grid** | `photo_grid.dart:94-95` | Same anti-pattern as P10. All photos built eagerly. | Use `SliverGrid` inside `CustomScrollView`. |
| P16 | 🔵 Low | **`BackdropFilter` in growth chart** | `growth_chart_screen.dart:488` | `BackdropFilter` during scroll may cause jank. | Verify it's not on scroll path. Consider pre-computed gradient instead. |
| P17 | 🔵 Low | **`Opacity` widget in splash animation hot paths** | `splash_screen.dart:141,176,188` | `Opacity` causes subtree to paint to separate layer. Acceptable for short splash but use `FadeTransition`. | Use `FadeTransition` for cheaper compositing. |

---

## Things Done Well

1. **Prisma transactions for complex mutations** — `$transaction` with parallel `deleteMany` calls in BabyMon cascade.
2. **`DataScreenMixin` cooldown and re-entrancy guards** — prevents duplicate API calls from rapid provider notifications.
3. **Good indexes on hot query paths** — `BabyMon.ownerUserId`, `Milestone.babymonId+happenedAt`, `FeedLog.babymonId+happenedAt`, `LinkedAccount` compound unique + status index.
4. **Parallel data fetching** — `Promise.all` in `export.service.ts:31-52` and `journal.service.ts:34-40`.
5. **Animation respects reduced motion** — `level_up_celebration.dart`, `splash_screen.dart`, `premium_background.dart` all check `MediaQuery.disableAnimations`.
6. **Soft-delete pattern** — `deletedAt: null` filters throughout queries.
7. **`HapticFeedback` on level-up** — `level_up_celebration.dart:136` adds tactile feedback.
8. **API payload select minimal** — `select: { id: true, name: true }` on author/user relations.
9. **Pino structured logger** — production-grade structured logging via `nestjs-pino`.
10. **Schema has `onDelete: Cascade` on 42 relations** — DB-level enforcement.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | Add missing indexes to AuditLog ×2, Subscription ×2, RefreshToken ×2, EntryChangeProposal. | S |
| 2 | Add `take` limits to unbounded queries (journal, export, growth, media). | S |
| 3 | Remove `shrinkWrap: true` from sleep screen `ListView.builder` and photo `GridView.builder`. | S |
| 4 | Add `memCacheWidth`/`memCacheHeight` to `CachedNetworkImage` in photo grid + viewer. | S |
| 5 | Add server-side image resize (max 2048px) in `media.service.ts`. | M |
| 6 | Remove redundant `addListener`+`setState` from `level_up_celebration.dart`. | M |
| 7 | Merge badge/definitions fetches into main `Future.wait` in dashboard. | S |
| 8 | Replace `include` with `_count` in `badges.service.ts:148`. | S |
| 9 | Create lightweight `verifyOwnership` in `baby-mon.service.ts`. | S |
| 10 | Reduce splash screen delay to 800ms minimum. | S |
| 11 | Use `createMany` in `badges.service.ts` instead of loop. | S |
| 12 | Batch BabyMon deletion in `users.service.ts` using `in` clauses. | S |
| 13 | Audit `BackdropFilter` in growth chart for scroll-path placement. | L |
| 14 | Replace `Opacity` widgets with `FadeTransition` in splash screen. | S |
