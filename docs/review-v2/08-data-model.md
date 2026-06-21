# S08 — Data Model Audit

**Date:** 2026-06-18 | **Overall Severity:** 🟠 High

The Prisma schema has 30 well-structured models but suffers from **String fields where enums belong (20+ fields), critical missing indexes on high-traffic query paths, inconsistent soft-delete patterns, and a head circumference percentile calculation bug using wrong WHO standards**.

---

## Findings

### DM-C01 | 🔴 CRITICAL | Head Circumference Uses WRONG WHO Standards

**Location:** `growth.service.ts:143,235`

**What:** `WHO_STANDARDS` contains only weight and height data. When `type === 'HEAD_CIRCUMFERENCE'`, the code falls through to use `WHO_STANDARDS[gender].weight` — calculating head circumference percentiles against weight standards. Produces completely invalid results.

**Remediation:** Add head circumference WHO standards data. Or throw a clear error if head circumference percentile is requested but standards not available.

---

### DM-C02 | 🔴 CRITICAL | JournalProposal FK Schema vs Migration Mismatch

**Location:** `schema.prisma:408` (onDelete: Cascade) vs migration `20260602161431` line 189 (ON DELETE RESTRICT)

**What:** Schema says Cascade, but the actual database has RESTRICT constraint. Deleting a BabyMon with JournalProposals will fail at the database level.

**Remediation:** Run `prisma migrate dev` to generate a migration changing RESTRICT to CASCADE. Verify alignment.

---

### DM-C03 | 🔴 CRITICAL | JournalProposal.changes — Dynamic Field Injection Vector

**Location:** `journal-proposals.service.ts:49-75`

**What:** `approveProposal()` loops over `Object.entries(changes)` and writes `updateData[field] = change.newValue` — allowing writes to ANY field on the target model including `deletedAt`, `babymonId`, `authorUserId`. No whitelist of allowed fields.

**Remediation:** Add a strict whitelist of allowed fields per entity type. Reject proposals that modify protected fields.

---

### DM-C04 | 🔴 CRITICAL | S3 Photos Orphaned on Account Deletion

**Location:** `users.service.ts:74-136`, `baby-mon.service.ts:148-167`

**What:** Media DB records are cascade-deleted, but `S3Service.deleteFile()` is never called. Children's photos remain in S3 accessible via URL indefinitely.

**Remediation:** Fetch s3Keys before deleting Media records. Call `S3Service.deleteFile()` for each. Add dead-letter queue for failures.

---

### DM-H01 | 🟠 HIGH | Missing Composite Index — RefreshToken (token, userId, revokedAt)

**Location:** `auth.service.ts:164`

**What:** The most frequently executed auth query has no covering composite index.

**Remediation:** Add `@@index([token, userId, revokedAt])`.

---

### DM-H02 | 🟠 HIGH | Missing Index — Subscription (userId, isActive)

**Location:** `subscriptions.service.ts:10`

**What:** Checked on every write operation. No composite index.

**Remediation:** Add `@@index([userId, isActive])`.

---

### DM-H03 | 🟠 HIGH | JournalProposal Has Zero Indexes

**Location:** `schema.prisma` — JournalProposal model

**What:** `getPendingProposals()` queries `(babymonId, status)` with full table scan.

**Remediation:** Add `@@index([babymonId, status])`.

---

### DM-H04 | 🟠 HIGH | EntryChangeProposal.status is String, Not Existing Enum

**What:** `ProposalStatus` enum exists and is used by `JournalProposal.status`, but `EntryChangeProposal.status` is typed `String` despite having the same values (PENDING/APPROVED/REJECTED).

**Remediation:** Change to `ProposalStatus @default(PENDING)`.

---

### DM-H05 | 🟠 HIGH | Missing deletedAt Indexes on Allergy and MedicalTeam

**What:** Every query filters `deletedAt: null` but no index exists.

**Remediation:** Add `@@index([deletedAt])` to both models.

---

### DM-H06 | 🟠 HIGH | Soft-Delete + Unique Constraint Conflict on Allergy

**What:** `@@unique([babyMonId, name])` blocks re-creating an allergy after soft-deleting the old one because `deletedAt` is not part of the unique constraint.

**Remediation:** Use partial unique index: `CREATE UNIQUE INDEX ON "Allergy" (babyMonId, name) WHERE "deletedAt" IS NULL`.

---

### DM-H07 | 🟠 HIGH | Audit Trail Destroyed on Account Deletion

**What:** `users.deleteAccount()` hard-deletes `AuditLog` records before soft-deleting user. Destroys forensic evidence when it's most needed.

**Remediation:** Never delete audit logs. Anonymize with pseudonymous identifiers.

---

### DM-H08 | 🟠 HIGH | GrowthRecord.value Uses Float Instead of Decimal

**What:** `Float` (DOUBLE PRECISION) can introduce rounding errors in medical measurements. WHO percentile calculations multiply/divide these values.

**Remediation:** Change to `Decimal(7,2)` for precision.

---

### DM-H09 | 🟠 HIGH | AdminService Bypasses deletedAt Filter

**What:** `AdminService.getAllUsers()` and `getUserById()` do not filter `deletedAt`. Admin can view/manipulate soft-deleted users.

**Remediation:** Add `deletedAt: null` filter. Or add separate "view deleted users" admin permission.

---

### DM-M01 | 🟡 MEDIUM | 20+ String Fields That Should Be Enums

Key offenders: `User.role`, `Device.platform`, `LinkedAccount.status`, `Subscription.tier`, `BabyMon.gender`, `BabyMon.stageStartType`, `FeedLog.type`, `HealthRecord.category`, `SleepLog.type`, `GrowthRecord.type/unit`, `Allergy.severity/status/treatment`, `AuditLog.eventType`, `EntryChangeProposal.status/entryType/proposalType`, `JournalProposal.entryType`, `StripeEvent.type`.

All have finite known value sets validated at application layer but no DB-level constraint.

**Remediation:** Create PostgreSQL ENUMs for all finite-value String fields. Use `@map` to preserve column names.

---

### DM-M02 | 🟡 MEDIUM | 14 Models Missing updatedAt

**What:** GrowthRecord, Media, AuditLog, AllergyEvent, EntryChangeProposal, JournalProposal, StripeEvent and 7 others have `createdAt` but no `updatedAt`.

**Remediation:** Add `updatedAt` to mutable models. Not needed for immutable audit/event models.

---

### DM-M03 | 🟡 MEDIUM | syncStatus Dead Code — 4 Models, 4 Wasted Columns

**What:** `syncStatus` on Milestone, FeedLog, HealthRecord, SleepLog is always "SYNCED" and never read.

**Remediation:** Remove the columns or implement actual offline sync.

---

### DM-M04 | 🟡 MEDIUM | Simplified WHO Percentile Calculation

**What:** Uses linear approximation around P50. Real WHO percentiles use LMS parameters (Lambda-Mu-Sigma) accounting for distribution skewness.

**Remediation:** Implement LMS-based percentile calculation. At minimum, label results as "estimates" in UI.

---

### DM-M05 | 🟡 MEDIUM | Missing Indexes on User (verificationToken, role, isActive)

**What:** Admin queries and email verification scan without index support.

**Remediation:** Add indexes based on query patterns.

---

### DM-M06 | 🟡 MEDIUM | GrowthRecord Loses Original Input Unit

**What:** If user enters inches, only converted cm is stored. Original unit context is lost.

**Remediation:** Store both `inputUnit` and standardized `unit`.

---

### DM-M07 | 🟡 MEDIUM | LinkedBabyMon.access Accepts 'ADMIN' But Never Handled

**What:** DTO allows 'ADMIN', schema stores it, but `access-control.service.ts` only checks 'EDIT'. Value stored but never interpreted.

**Remediation:** Either implement ADMIN access level or remove from DTO and schema default.

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 4 |
| 🟠 High | 9 |
| 🟡 Medium | 7 |
| 🔵 Low | 5 |
| **Total** | **25** |
