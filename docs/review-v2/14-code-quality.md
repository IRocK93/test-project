# S14 — Code Quality & Idioms Audit

**Date:** 2026-06-18 | **Overall Grade:** B (Backend) / B- (Mobile)

---

## Key Findings

### CQ-C01 | 🔴 CRITICAL | Module-Level process.env Evaluation
`auth.service.ts:10-14` and `jwt.strategy.ts:6-10` evaluate `process.env` at import time — before `dotenv` may have loaded. Two different JWT fallback secrets.

### CQ-C02 | 🔴 CRITICAL | 23 Empty Catch Blocks in Mobile
Dashboard alone has 11 `catch (_) {}` blocks. Data failures are completely invisible to users.

### CQ-C03 | 🔴 CRITICAL | 55+ `any` Types in Backend
29+ controller methods type `req` as `any`. `journal-proposals.service.ts` builds Prisma updates with `const updateData: any = {}` — completely untyped database writes.

### CQ-H01 | 🟠 HIGH | console.error Bypasses Pino Logger
`auth.service.ts:85` — lone `console.error` despite `nestjs-pino` configured globally.

### CQ-H02 | 🟠 HIGH | DRY — Duplicated access control patterns
3 different access check implementations across services. 10-minute window logic duplicated in milestones.service.ts.

### CQ-H03 | 🟠 HIGH | dashboard_screen.dart — 1,063 Lines
Too many responsibilities: data fetching, tile reordering, edit form, share, celebrations, 11 empty catch blocks.

### CQ-M01 | 🟡 MEDIUM | 30+ Entity-Specific CRUD Methods Mirror Generic Methods in ApiClient
Two code paths to call the same API.

### CQ-M02 | 🟡 MEDIUM | Dashboard Stores Domain Data as Map<String, dynamic>
No typed domain models for evolution data, badges, or stage content.

## Strengths
- ✅ Proper NestJS constructor-based DI throughout
- ✅ `PrismaService` correctly implements `OnModuleInit`/`OnModuleDestroy`
- ✅ `const` constructors used pervasively in Flutter (1,145+ occurrences)
- ✅ No `BuildContext` stored as class fields
- ✅ Zero TODO/FIXME comments in backend source
- ✅ Commented-out code is minimal
- ✅ Consistent naming conventions across modules

## Summary Statistics
| Severity | Count |
|---|---|
| 🔴 Critical | 3 |
| 🟠 High | 3 |
| 🟡 Medium | 2 |
| **Total** | **8** |
