# BabyMon Backend Architecture Audit — v4

**Date:** 2026-06-22
**Overall Grade: B (82/100)**

---

## 1. Architectural Assessment

The codebase demonstrates competent NestJS practices with clear separation of concerns, good transaction handling, and well-structured DTO validation. The architecture is above average for an early-stage project.

### Natural Layering

Three natural layers exist within the flat 27-module structure:
- **Controllers** → clean delegates, no business logic leakage
- **Services** → domain logic, Prisma queries
- **Infrastructure** → PrismaService (global), mail, S3, notifications

### Strengths
- `PrismaModule` is `@Global()`, avoiding repeated imports
- Controllers consistently delegate to services
- `common/` directory well-organized with subdirectories for decors, filters, guards

### Weaknesses
- No domain-level grouping (e.g., Tracking domain, Gamification domain)
- Flat module registration in `AppModule`

---

## 2. Anti-Patterns Found

| # | Anti-Pattern | Location | Severity |
|---|-------------|----------|----------|
| 1 | Stage calculation triplicated across 3 services | baby-mon, companion, stage-content | HIGH |
| 2 | GlobalExceptionFilter defined but unregistered | `common/filters/`, `main.ts` | HIGH |
| 3 | ConfigService bypass — 5+ services read `process.env` directly | s3, stripe, mail, notifications, tier.guard | HIGH |
| 4 | Service declaration anti-pattern in BabyMonModule | `baby-mon.module.ts:11` | MEDIUM |
| 5 | StageContentService silently swallows all errors | `stage-content.service.ts:143-156` | HIGH |
| 6 | Full DTO duplication (Create/Update) | feed-logs, milestones, health-records | MEDIUM |
| 7 | No response/output DTOs — raw Prisma models returned | All controllers | MEDIUM |
| 8 | `d: any` parameter in MedicalTeamService | `medical-team.service.ts:13` | HIGH |
| 9 | AuthModule static JWT config bypasses ConfigService | `auth.module.ts:13-17` | MEDIUM |
| 10 | XP level-up race condition (no atomic read-modify-write) | `xp.service.ts:110-147` | HIGH |
| 11 | No request ID middleware | Global | MEDIUM |
| 12 | AuditInterceptor unused — well-tested but never applied | `common/interceptors/` | LOW |

---

## 3. History Limit Date Filter — DRY Violation

Identical code duplicated verbatim across 5 services:
```typescript
const historyDays = await this.subscriptionsService.getHistoryLimitDays(userId);
const dateFilter = historyDays
  ? { happenedAt: { gte: new Date(Date.now() - historyDays * 24 * 60 * 60 * 1000) } }
  : {};
```
Should be extracted to a shared helper or Prisma middleware.

---

## 4. Inconsistent Access Control Pattern

Three different patterns coexist:
- `FeedLogsService` / `MilestonesService`: private `verifyAccess()` helper
- `HealthRecordsService`: `this.accessControl.checkAccess()` inline
- `GrowthService`: both `verifyAccess()` and `verifyAccessWithBabyMon()`
- `SleepLogsService`: `this.accessControl.checkAccess()` inline
- `MediaService` / `ExportService`: inline `linkedAccount` check

---

## 5. Refactoring Priority

### P0 — Critical
1. Register GlobalExceptionFilter in `main.ts`
2. Fix StageContentService error swallowing
3. Fix XP level-up race condition with `$transaction`

### P1 — High
4. Extract stage calculation to shared `StageCalculatorService`
5. Extract history date filter to shared helper
6. Convert S3/Mail services to use ConfigService
7. Apply DTO PartialType pattern to all Update DTOs

### P2 — Medium
8. Fix BabyMonModule provider pattern
9. Standardize access control pattern
10. Fix AuthModule to use `JwtModule.registerAsync()`
11. Add request ID middleware
12. Add response DTOs for sensitive endpoints

### P3 — Low
13. Create domain barrel modules (Tracking, Gamification, Social, Infrastructure)
14. Activate or remove AuditInterceptor
15. Add idempotency key support for mutations
16. Define proper DTO for MedicalTeamService
17. Standardize error response shape with `BusinessException` base class
18. Add fire-and-forget error logging
