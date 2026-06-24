# BabyMon Database & Data Model Audit — v4

**Date:** 2026-06-22
**Overall Grade: B-**

---

## 1. Schema Design (31 Models)

The Prisma schema is well-organized with appropriate relations and a good mix of entity types. However, several critical issues exist.

### Critical Issues

#### D1. Migration-Schema Drift
The schema references a `MilestoneStatus` enum with values like `ACHIEVED`, `IN_PROGRESS`, `NOT_STARTED` in models, but the original migration may have used different values. This drift means a fresh `prisma migrate deploy` could fail or produce incompatible state.

#### D2. Ghost Enum: ExpertVoice
The enum `ContentSource` includes `EXPERT` and `PARENT_COMMUNITY` values that are never used in seed data or service code. Dead enum values pollute the schema.

#### D3. Race Conditions in Companion Service
Four methods in `companion.service.ts` have race condition hazards:
- `achieveMilestone()`: read-then-write on BabyMilestone status
- `XpService.checkAndProcessLevelUp()`: read-then-write on currentXp/currentStage
- `completeRoutineStep()`: read-then-write on UserRoutine
- `toggleBookmarkAdvice()`: read-then-write on SavedAdvice

---

### High Severity

#### H1. BadgesService N+1 Query
`badges.service.ts:147-151` fetches ALL milestones/feedLogs/healthRecords with `include` just to check `.length`. Should use `_count: { select: {...} }` instead.

#### H2. Seed ID Collision Risk
Seed files generate IDs from truncated titles (first 3 words). Multiple advice cards could produce identical IDs, causing unique constraint violations during seeding.

#### H3. stageStartType Mismatch
Seed uses `stageStartType: 'IDEA'` but companion service uses `'PLAN'` for the same concept. This mismatch causes stage calculation to produce different results depending on which code path is taken.

---

### Medium Severity

#### M1-M9: Missing Indexes
| Table | Missing Index | Impact |
|-------|--------------|--------|
| AuditLog | `createdAt` | Slow audit queries |
| AuditLog | `eventType` | Filtering by event type |
| BabyMon | `ownerUserId` | User's baby list |
| FeedLog | `happenedAt` | Date-range queries |
| GrowthRecord | `measuredAt` | Growth chart queries |
| HealthRecord | `happenedAt` | Date-range queries |
| JournalProposal | `status` | Proposal filtering |
| Milestone | `happenedAt` | Date-range queries |
| SleepLog | `startTime` | Sleep pattern queries |

#### M10: AuditLog.payloadJson is TEXT not JSONB
PostgreSQL can't efficiently query inside the payload. Should be JSONB for structured audit queries.

#### M11: Inconsistent Soft-Delete Coverage
- Present: User, BabyMon, Milestone, FeedLog, SleepLog, HealthRecord
- Missing: GrowthRecord, AllergyEvent
- Both records that should have soft-delete for audit trail purposes are missing it.

---

### Low Severity

- L1: `MilestoneDomain.MOTOR` enum value exists but not used in seed data
- L2: No composite indexes for common query patterns (e.g., babyMonId + happenedAt)
- L3: `BirthDate` on BabyMon has no validation constraint at DB level

---

## 2. Seed Data Quality

### Strengths
- 422 ExpertAdviceCards across all stages
- 200 MilestoneExpectations
- 13 RoutineTemplates
- 86 Badge definitions
- Well-organized batch seeder files

### Issues
- ~78 missing advice cards (84% of target)
- ID collision risk from truncated title-derived IDs
- No seed data versioning or migration tracking
- Some content appears auto-generated with repetitive patterns

---

## 3. Migration Hygiene

The `migrations/` directory exists but was not fully reviewed due to scope. Key concern: Prisma version mismatch (client 5.22 vs CLI 5.8) means migrations may not be compatible with the generated client.

---

## 4. Recommendations

### Immediate
1. Run `prisma migrate diff` to verify schema-migration consistency
2. Replace `include` with `_count` in BadgesService
3. Fix race conditions with `$transaction` interactive API

### Short-term
4. Add 9 missing indexes
5. Convert `AuditLog.payloadJson` from TEXT to JSONB
6. Add soft-delete to GrowthRecord and AllergyEvent
7. Remove unused enum values

### Medium-term
8. Implement seed data versioning
9. Add database-level constraints for business rules
10. Consider Read/Write split for analytics queries
