# Delivery Plan A: Access Control Remediation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 4 critical IDOR vulnerabilities and 1 dynamic field injection vector in the NestJS backend

**Architecture:** Standardize all services on `AccessControlService.verifyAccessOrThrow()` — a new method that throws instead of returning boolean. Fix argument order bugs, add missing status filters, and whitelist allowed fields in journal proposal approval.

**Tech Stack:** NestJS, Prisma, TypeScript, Jest

**Related Reports:** S01 (S01-01 through S01-04), S08 (DM-C03), S06 (BA-C02)

---

## Pre-Flight: Add verifyAccessOrThrow to AccessControlService

This single method eliminates the "forgot to check return value" class of bugs across all services.

### Task A-0: Add verifyAccessOrThrow method

**Files:**
- Modify: `apps/api/src/common/access-control.service.ts`
- Modify: `apps/api/src/common/access-control.types.ts`

- [ ] **Step 1: Add AccessLevel import if not already exported**

Check that `AccessLevel` enum is exported from `access-control.types.ts`. If not present, add:

```typescript
export enum AccessLevel {
  VIEW = 'VIEW',
  EDIT = 'EDIT',
}
```

- [ ] **Step 2: Add verifyAccessOrThrow method to AccessControlService**

Open `apps/api/src/common/access-control.service.ts`. After the existing `checkAccess` method, add:

```typescript
/**
 * Verifies access and throws ForbiddenException if denied.
 * Use this for write operations and anywhere access MUST be enforced.
 * 
 * @param userId - The authenticated user's ID
 * @param babyMonId - The BabyMon resource ID
 * @param requiredLevel - Minimum access level required (default EDIT for writes)
 */
async verifyAccessOrThrow(
  userId: string,
  babyMonId: string,
  requiredLevel: AccessLevel = AccessLevel.EDIT,
): Promise<void> {
  const { hasAccess, level } = await this.checkAccess(userId, babyMonId);
  
  if (!hasAccess) {
    throw new ForbiddenException('You do not have access to this BabyMon');
  }
  
  if (requiredLevel === AccessLevel.EDIT && level !== AccessLevel.EDIT) {
    throw new ForbiddenException('You need edit permission to modify this BabyMon');
  }
}
```

- [ ] **Step 3: Verify the import for ForbiddenException exists at the top of the file**

```typescript
import { ForbiddenException } from '@nestjs/common';
```

- [ ] **Step 4: Run the existing tests to ensure no regressions**

```bash
cd apps/api && npx jest --testPathPattern="access-control"
```

Expected: No existing tests found (0 tests for this service — noted in S09). Create test file in Task A-1.

- [ ] **Step 5: Commit**

```bash
git add apps/api/src/common/access-control.service.ts apps/api/src/common/access-control.types.ts
git commit -m "feat(security): add verifyAccessOrThrow to AccessControlService"
```

---

## Fix 1: SleepLogsService — Swapped Arguments (S01-01)

**Bug:** `checkAccess(babymonId, userId)` — arguments are swapped. Return value never checked. Any user accesses any baby's sleep data.

### Task A-1: Fix SleepLogsService access control

**Files:**
- Modify: `apps/api/src/sleep-logs/sleep-logs.service.ts`

- [ ] **Step 1: Add AccessControlService import**

Check that `AccessControlService` is already injected in the constructor. If not:

```typescript
import { AccessControlService } from '../common/access-control.service';
```

And in constructor:
```typescript
constructor(
  private readonly prisma: PrismaService,
  private readonly xpService: XpService,
  private readonly accessControl: AccessControlService, // Add this
) {}
```

- [ ] **Step 2: Fix the findAll method (line ~24)**

Replace the broken call:
```typescript
// OLD (BROKEN):
await this.accessControl.checkAccess(babymonId, userId);

// NEW:
await this.accessControl.verifyAccessOrThrow(userId, babymonId, AccessLevel.VIEW);
```

- [ ] **Step 3: Fix the create method (line ~52)**

Replace:
```typescript
// OLD (BROKEN):
await this.accessControl.checkAccess(babymonId, userId);

// NEW:
await this.accessControl.verifyAccessOrThrow(userId, babymonId, AccessLevel.EDIT);
```

- [ ] **Step 4: Fix the findOne method (line ~84)**

Replace:
```typescript
// OLD (BROKEN):
await this.accessControl.checkAccess(babymonId, userId);

// NEW:
await this.accessControl.verifyAccessOrThrow(userId, babymonId, AccessLevel.VIEW);
```

- [ ] **Step 5: Fix the update method (line ~98)**

Replace:
```typescript
// OLD (BROKEN):
await this.accessControl.checkAccess(babymonId, userId);

// NEW:
await this.accessControl.verifyAccessOrThrow(userId, babymonId, AccessLevel.EDIT);
```

- [ ] **Step 6: Fix the delete method (line ~122)**

Replace:
```typescript
// OLD (BROKEN):
await this.accessControl.checkAccess(babymonId, userId);

// NEW:
await this.accessControl.verifyAccessOrThrow(userId, babymonId, AccessLevel.EDIT);
```

- [ ] **Step 7: Import AccessLevel**

At the top of the file, add:
```typescript
import { AccessLevel } from '../common/access-control.types';
```

- [ ] **Step 8: Verify the file compiles**

```bash
cd apps/api && npx tsc --noEmit
```

Expected: No TypeScript errors related to sleep-logs.service.ts

- [ ] **Step 9: Commit**

```bash
git add apps/api/src/sleep-logs/sleep-logs.service.ts
git commit -m "fix(security): fix swapped access control arguments in SleepLogsService

Arguments were passed as (babymonId, userId) instead of (userId, babymonId).
Return value was never checked, making access control a no-op.
Now uses verifyAccessOrThrow which throws ForbiddenException on denial."
```

---

## Fix 2: JournalService — Missing LINKED Status Filter (S01-02)

**Bug:** `checkAccess` queries `linkedAccount` without filtering `status: 'LINKED'`. Any invitation record (PENDING/REJECTED/expired) grants permanent journal access.

### Task A-2: Fix JournalService access control

**Files:**
- Modify: `apps/api/src/journal/journal.service.ts`

- [ ] **Step 1: Locate the checkAccess or similar access verification method**

Find the method that queries `linkedAccount.findFirst`. It should be near lines 17-21.

- [ ] **Step 2: Add status: 'LINKED' to both OR conditions**

Replace:
```typescript
const linked = await this.prisma.linkedAccount.findFirst({
  where: {
    OR: [
      { userAId: userId, userBId: babyMon.ownerUserId },
      { userBId: userId, userAId: babyMon.ownerUserId },
    ],
  },
});
```

With:
```typescript
const linked = await this.prisma.linkedAccount.findFirst({
  where: {
    OR: [
      { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
      { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
    ],
  },
});
```

- [ ] **Step 3: Verify TypeScript compilation**

```bash
cd apps/api && npx tsc --noEmit
```

Expected: No TypeScript errors.

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/journal/journal.service.ts
git commit -m "fix(security): add status LINKED filter to journal access check

Previously any LinkedAccount record (including PENDING/REJECTED) granted
permanent journal access. Now only LINKED status confers access."
```

---

## Fix 3: AllergiesService — Zero Access Control (S01-03)

**Bug:** Not a single method calls AccessControlService. The `_userId` parameter is prefixed with underscore (unused). Any authenticated user accesses any baby's allergies.

### Task A-3: Add access control to AllergiesService

**Files:**
- Modify: `apps/api/src/allergies/allergies.service.ts`

- [ ] **Step 1: Inject AccessControlService**

In the constructor, add:
```typescript
constructor(
  private readonly prisma: PrismaService,
  private readonly accessControl: AccessControlService,
) {}
```

- [ ] **Step 2: Add imports**

At the top of the file:
```typescript
import { AccessControlService } from '../common/access-control.service';
import { AccessLevel } from '../common/access-control.types';
```

- [ ] **Step 3: Add access check to findAll**

Find the `findAll(babyMonId: string, _userId: string)` method. Replace `_userId: string` with `userId: string` and add:
```typescript
async findAll(babyMonId: string, userId: string) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.VIEW);
  return this.prisma.allergy.findMany({
    where: { babyMonId, deletedAt: null },
    include: { events: { where: { deletedAt: null } } },
  });
}
```

- [ ] **Step 4: Add access check to create**

Find the `create` method. Add at the top:
```typescript
async create(babyMonId: string, userId: string, dto: CreateAllergyDto) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.EDIT);
  // ... rest of existing method
}
```

- [ ] **Step 5: Add access check to addEvent**

```typescript
async addEvent(babyMonId: string, allergyId: string, userId: string, dto: CreateAllergyEventDto) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.EDIT);
  // ... rest of existing method
}
```

- [ ] **Step 6: Add access check to deleteEvent, cure, reactivate, delete, clearAll, clearAllEvents**

Apply the same pattern to all remaining methods that accept `babyMonId`:
```typescript
await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.EDIT);
```

For read-only operations (if any exist without write semantics), use `AccessLevel.VIEW`.

- [ ] **Step 7: Verify controller passes userId**

Check `apps/api/src/allergies/allergies.controller.ts`. Ensure every method extracts `userId` from `req.user.id` and passes it to the service methods. If any method uses `_userId` pattern, update it to pass the actual user ID.

- [ ] **Step 8: Verify TypeScript compilation**

```bash
cd apps/api && npx tsc --noEmit
```

Expected: No TypeScript errors.

- [ ] **Step 9: Commit**

```bash
git add apps/api/src/allergies/
git commit -m "fix(security): add access control to AllergiesService

Previously zero methods verified user access. Any authenticated user
could read, create, delete, cure, and reactivate allergies for any
BabyMon. Now uses verifyAccessOrThrow on every method."
```

---

## Fix 4: MedicalTeamService — Zero Access Control (S01-04)

**Bug:** Same pattern as allergies. No access verification on any method.

### Task A-4: Add access control to MedicalTeamService

**Files:**
- Modify: `apps/api/src/medical-team/medical-team.service.ts`

- [ ] **Step 1: Inject AccessControlService**

```typescript
constructor(
  private readonly prisma: PrismaService,
  private readonly accessControl: AccessControlService,
) {}
```

- [ ] **Step 2: Add imports**

```typescript
import { AccessControlService } from '../common/access-control.service';
import { AccessLevel } from '../common/access-control.types';
```

- [ ] **Step 3: Add access check to findAll**

```typescript
async findAll(babyMonId: string, userId: string) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.VIEW);
  return this.prisma.medicalTeam.findMany({
    where: { babyMonId, deletedAt: null },
  });
}
```

- [ ] **Step 4: Add access check to create**

```typescript
async create(babyMonId: string, userId: string, dto: CreateMedicalTeamMemberDto) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.EDIT);
  // ... rest of existing method
}
```

- [ ] **Step 5: Add access check to remove**

```typescript
async remove(babyMonId: string, memberId: string, userId: string) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.EDIT);
  // ... rest of existing method
}
```

- [ ] **Step 6: Verify controller passes userId**

Check `apps/api/src/medical-team/medical-team.controller.ts` ensures `userId` is extracted and passed.

- [ ] **Step 7: Verify TypeScript compilation**

```bash
cd apps/api && npx tsc --noEmit
```

- [ ] **Step 8: Commit**

```bash
git add apps/api/src/medical-team/
git commit -m "fix(security): add access control to MedicalTeamService"
```

---

## Fix 5: JournalProposal Field Injection (DM-C03)

**Bug:** `approveProposal()` loops over `Object.entries(changes)` and writes `updateData[field] = change.newValue` to ANY field on the target model — including `deletedAt`, `babymonId`, `authorUserId`. A malicious co-parent can escalate privileges or corrupt data.

### Task A-5: Add field whitelist to JournalProposal approval

**Files:**
- Modify: `apps/api/src/journal/journal-proposals.service.ts`

- [ ] **Step 1: Define allowed fields per entry type**

In `journal-proposals.service.ts`, add a constant near the top of the file (after imports, before the class):

```typescript
const ALLOWED_PROPOSAL_FIELDS: Record<string, readonly string[]> = {
  MILESTONE: ['title', 'notes', 'happenedAt'] as const,
  FEED_LOG: ['type', 'amount', 'unit', 'notes', 'happenedAt'] as const,
  HEALTH_RECORD: ['category', 'title', 'notes', 'happenedAt'] as const,
};
```

- [ ] **Step 2: Add field validation to approveProposal**

Locate the `approveProposal` method. Before the `for (const [field, change] of Object.entries(changes))` loop, add validation:

```typescript
const allowedFields = ALLOWED_PROPOSAL_FIELDS[proposal.entryType];
if (!allowedFields) {
  throw new BadRequestException(`Unknown entry type: ${proposal.entryType}`);
}

const disallowedFields = Object.keys(changes).filter(
  (field) => !allowedFields.includes(field)
);

if (disallowedFields.length > 0) {
  throw new BadRequestException(
    `Cannot modify protected fields: ${disallowedFields.join(', ')}`
  );
}
```

- [ ] **Step 3: Verify the import for BadRequestException exists**

```typescript
import { BadRequestException, /* other imports */ } from '@nestjs/common';
```

- [ ] **Step 4: Verify TypeScript compilation**

```bash
cd apps/api && npx tsc --noEmit
```

Expected: No TypeScript errors.

- [ ] **Step 5: Commit**

```bash
git add apps/api/src/journal/journal-proposals.service.ts
git commit -m "fix(security): whitelist allowed fields in JournalProposal approval

Previously approveProposal() allowed writing to ANY field on the target
model (including deletedAt, babymonId, authorUserId). Now validates
each field against a whitelist per entry type, rejecting protected
fields with BadRequestException."
```

---

## Verification: End-to-End Access Control Audit

### Task A-6: Audit remaining services for access control gaps

**Files:**
- Read: `apps/api/src/export/export.service.ts`
- Read: `apps/api/src/media/media.service.ts`
- Read: `apps/api/src/journal/journal-proposals.service.ts` (getPendingProposals)
- Read: `apps/api/src/linked-accounts/linked-accounts.service.ts`

- [ ] **Step 1: Audit ExportService**

Check that `exportBabyMon`, `exportJson`, `exportCsv` all verify access before exporting data. If any method accesses `babyMonId` without calling `verifyAccessOrThrow`, add the call.

- [ ] **Step 2: Audit MediaService**

Check that `getMediaForBabyMon`, `uploadMedia`, `deleteMedia` all verify access. Note: `deleteMedia` may already check ownership — verify it uses `verifyAccessOrThrow` consistently.

- [ ] **Step 3: Audit JournalProposalsService.getPendingProposals**

Add access verification:
```typescript
async getPendingProposals(babyMonId: string, userId: string) {
  await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.VIEW);
  return this.prisma.journalProposal.findMany({
    where: { babymonId, status: 'PENDING' },
  });
}
```

- [ ] **Step 4: Ensure controller passes userId**

Check `journal.controller.ts` — the `getProposals` handler must pass `userId` to `getPendingProposals`.

- [ ] **Step 5: Audit LinkedAccountsService**

Check that `linkBabyMonToUser` verifies the requesting user owns the BabyMon before linking. Add:
```typescript
await this.accessControl.verifyAccessOrThrow(userId, babyMonId, AccessLevel.EDIT);
```

- [ ] **Step 6: Verify compilation and commit**

```bash
cd apps/api && npx tsc --noEmit
git add apps/api/src/
git commit -m "fix(security): audit and fix remaining access control gaps"
```

---

## Completing Delivery Plan A

After all tasks are complete, run the full backend test suite:

```bash
cd apps/api && npm test
cd apps/api && npm run test:e2e  # after fixing config
```

All existing tests must pass. New access control logic will throw `ForbiddenException` for unauthorized access — verify that existing integration tests use an authorized user context.

**Estimated time:** 1 day for a developer familiar with the codebase.
