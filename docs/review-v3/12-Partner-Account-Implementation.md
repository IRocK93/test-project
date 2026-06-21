# Partner Account Implementation — Contract Reconciliation & Lifecycle Design

## Overview

The partner/co-parent account feature spans the NestJS API (`linked-accounts` module) and the Flutter mobile client (`PartnersScreen`). When this audit began, the mobile and API **disagreed on every dimension of the contract** — routes, HTTP verbs, payload field names, status vocabulary, and response shapes. Worse, three logical holes in the lifecycle meant that even if you bridged the contract mismatch, a partner who accepted an invitation would *never actually get access to the baby*.

This document traces the end-to-end redesign: what was broken, the logical flow we implemented, every decision that shaped it, and the four bugs discovered and fixed during verification.

---

## Pre-existing State (What Was There Before)

### Backend — `linked-accounts` module

| Component | What existed |
|-----------|-------------|
| `LinkedAccountsController` | `GET /linked-accounts`, `GET /invitations`, `POST /invite`, `POST /invitations/:id/respond`, `DELETE /:id`, `POST /baby-mons` |
| `BabyMonPartnersController` | `GET /baby-mons/:babyMonId/partners` only |
| `LinkedAccount` schema | `userAId`, `userBId`, `status`, `linkedAt`, `expiresAt` — no `role`, no `babyMonId` |
| `LinkedBabyMon` schema | `userId`, `babymonId`, `access` — no `role`, no status tracking |
| `AccessControlService` | Resolved access via ownership check → `LinkedBabyMon` lookup. Correct for linked users, but the link was never created on accept. |
| `MailService.sendLinkedAccountInvitation()` | Full email template existed — **never called** from any service |
| Tests | None |

### Mobile — partner surface

| Component | What existed |
|-----------|-------------|
| `partners_screen.dart` | Full UI: invite dialog (email + role segment), partners list with status chips, swipe-to-remove, accept/decline popup |
| `api_client.dart` partner methods | `invitePartner`, `getPartners`, `respondToInvitation`, `removePartner` |
| Router | `/partners` route wired into drawer |
| Tests | Integration smoke test, golden tests |
| Error handling | Every catch block showed "Partners feature coming soon" |

### The Contract Mismatch

| Operation | Mobile calls | API exposed |
|-----------|-------------|-------------|
| Invite | `POST /baby-mons/{babyMonId}/partners/invite` `{email, role}` | `POST /linked-accounts/invite` `{partnerEmail}` |
| List | `GET /baby-mons/{babyMonId}/partners` | `GET /baby-mons/{babyMonId}/partners` ✅ |
| Respond | `PATCH /baby-mons/{partnerId}/respond` `{status}` | `POST /linked-accounts/invitations/:id/respond` `{accept}` |
| Remove | `DELETE /baby-mons/{partnerId}` | `DELETE /linked-accounts/:id` |

Additionally:
- Mobile status vocabulary: `ACCEPTED` / `PENDING` / `DECLINED`
- API status vocabulary: `LINKED` / `PENDING` / `REJECTED` / `ACTIVE` / `EXPIRED`
- Mobile response shape expected: `{ id, status, role, user: { id, name, email } }`
- API response shape returned: `{ id, partner: {...}, linkedAt }`
- Mobile sent `role` field — no DB column to store it
- Mobile `DELETE /baby-mons/{partnerId}` **collided** with `DELETE /baby-mons/:id` (delete BabyMon)

### The Logical Holes (Beyond the Contract)

1. **Accept never granted `LinkedBabyMon`.** `respondToInvitation` flipped the `LinkedAccount` to `LINKED` but never created the `LinkedBabyMon` row. The partner was "linked" but had no access to any baby.
2. **No `babyMonId` on the invitation.** You invited someone "for BabyMon X" but that context was lost — nothing remembered which baby to grant access to on accept.
3. **Invitee couldn't discover the invitation in-app.** The `getPartnersForBabyMon` access gate only admitted the owner and already-linked co-parents. A PENDING invitee had no way to reach the partner list to accept.
4. **`DELETE` route collision.** The mobile's `DELETE /baby-mons/{partnerId}` routed to the same path as `DELETE /baby-mons/:id` (delete BabyMon).

---

## Design Decision: Make the API Match the Mobile Contract

**Rationale**: The mobile is the user-facing surface. The API exists to serve it. Changing the API to match means fewer mobile changes (1 method signature) versus rewriting the mobile client to match the API. Partners are modeled as a **nested resource under BabyMons** because the mobile UI already scopes partner management to a specific baby.

The underlying `LinkedAccount` row remains the canonical record. The BabyMon-nested endpoints are a presentation layer on top of it.

---

## The End-to-End Lifecycle (Designed Flow)

```
┌─────────────────────────────────────────────────────────────────────┐
│ ① INVITE (A → B for BabyMon X)                                      │
│    POST /baby-mons/X/partners/invite  { email, role }                │
│    ──────────────────────────────────────────────────────────────── │
│    • A must own X                                                    │
│    • B must be a registered user (unregistered invites: out of scope)│
│    • B ≠ A                                                           │
│    ──────────────────────────────────────────────────────────────── │
│    → LinkedAccount(A,B, PENDING, role, babyMonId=X)                  │
│    → Email sent to B (fire-and-forget, never fails the request)      │
│    → Returns { id, status:"PENDING", role, user:{B} }                │
│                                                                      │
│    Edge cases handled:                                               │
│    • Already LINKED → idempotent — just ensure LinkedBabyMon(B,X)    │
│    • REJECTED/EXPIRED → reset to PENDING (re-invite)                 │
│    • PENDING already → update role/babyMonId/expiry, resend email    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ ② DISCOVER (B sees invitation)                                       │
│    GET /baby-mons/X/partners                                          │
│    ──────────────────────────────────────────────────────────────── │
│    Access gate admits: owner, LINKED co-parent, OR PENDING invitee   │
│    (REJECTED/EXPIRED invitees are denied — treated as strangers)     │
│    ──────────────────────────────────────────────────────────────── │
│    Returns only rows where the VIEWER is a direct participant        │
│    (prevents B from seeing C — an unrelated partner of A)            │
│    → Returns [{ id, status:"PENDING", role, user:{A} }]             │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ ③ RESPOND (B accepts/declines — only userB)                          │
│    PATCH /baby-mons/{invitationId}/respond  { status }               │
│    ──────────────────────────────────────────────────────────────── │
│    ACCEPTED:                                                         │
│      $transaction {                                                  │
│        upsert LinkedBabyMon(B, X, EDIT)    ← GRANTS ACTUAL ACCESS    │
│        update LinkedAccount → LINKED, linkedAt=now                   │
│      }                                                               │
│    DECLINED:                                                         │
│      update LinkedAccount → REJECTED                                 │
│      (no LinkedBabyMon created, no access granted)                   │
│    ──────────────────────────────────────────────────────────────── │
│    Guards: only userB responds, not already processed, not expired   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ ④ LINKED (both parties manage the partnership)                       │
│    GET /baby-mons/X/partners  →  { status:"ACCEPTED", role, user }   │
│    ──────────────────────────────────────────────────────────────── │
│    B now passes AccessControlService:                                │
│      checkAccess(B, X) → finds LinkedBabyMon(B,X,EDIT) → ALLOWED     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ ⑤ REMOVE (scoped to this baby, not nuclear)                          │
│    DELETE /baby-mons/X/partners/{invitationId}                       │
│    ──────────────────────────────────────────────────────────────── │
│    PENDING → delete the invitation                                   │
│    LINKED  → delete LinkedBabyMon for THIS baby only                 │
│              then count remaining LinkedBabyMon rows for partner:     │
│              • 0 → delete LinkedAccount (cold breakup)               │
│              • >0 → keep LinkedAccount (still co-parents elsewhere)  │
└─────────────────────────────────────────────────────────────────────┘
```

### Status Normalization (DB → Client)

The database stores `LinkedAccountStatus` values. The API normalizes to the mobile vocabulary:

| DB status | Client status | Reason |
|-----------|--------------|--------|
| `LINKED` | `ACCEPTED` | Primary active state |
| `ACTIVE` | `ACCEPTED` | Legacy — never written, defensive map |
| `PENDING` | `PENDING` | Direct match |
| `REJECTED` | `DECLINED` | Primary declined state |
| `EXPIRED` | `DECLINED` | Never written (TTL is date-based), defensive map |
| *default* | `PENDING` | Defense against unknown values |

### Response Shape

All partner-list endpoints return the normalized mobile shape:
```typescript
{
  id: string,                                    // LinkedAccount id
  status: 'ACCEPTED' | 'PENDING' | 'DECLINED',   // normalized
  role: 'PARENT' | 'GUARDIAN' | 'GRANDPARENT',   // from LinkedAccount.role
  user: { id: string, name: string, email: string }, // the OTHER party
  linkedAt: DateTime | null
}
```

---

## Schema Changes

### `LinkedAccount` — two new columns

```prisma
model LinkedAccount {
  // ... existing fields ...
  role      String?  @default("PARENT")     // free-form, DTO-validated
  babyMonId String?                         // invitation target baby
  // ...
  babyMon BabyMon? @relation("LinkedAccountBabyMon",
    fields: [babyMonId], references: [id], onDelete: SetNull)
  //                                                    ^^^^^^^
  //         SetNull, NOT Cascade — deleting a baby
  //         must not destroy the co-parent relationship
  @@index([babyMonId])
}
```

### `BabyMon` — back-relation

```prisma
model BabyMon {
  // ... existing fields ...
  linkedAccounts LinkedAccount[] @relation("LinkedAccountBabyMon")
}
```

### Migration

```sql
ALTER TABLE "LinkedAccount" ADD COLUMN "role" TEXT NOT NULL DEFAULT 'PARENT';
ALTER TABLE "LinkedAccount" ADD COLUMN "babyMonId" TEXT;
CREATE INDEX "LinkedAccount_babyMonId_idx" ON "LinkedAccount"("babyMonId");
ALTER TABLE "LinkedAccount" ADD CONSTRAINT "LinkedAccount_babyMonId_fkey"
  FOREIGN KEY ("babyMonId") REFERENCES "BabyMon"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
```

---

## Route Architecture

All partner routes live under the `BabyMonPartnersController` with `@Controller('baby-mons')`. The existing `BabyMonController` shares the same base path — route disambiguation relies on segment count and suffix differences.

| Partner route | Collision check with BabyMon CRUD |
|---------------|-----------------------------------|
| `GET :babyMonId/partners` | BabyMon `GET :id` (1 segment) ≠ this (2 segments) ✅ |
| `POST :babyMonId/partners/invite` | BabyMon `POST` (0 segments) ≠ this (2 segments) ✅ |
| `PATCH :partnerId/respond` | BabyMon `PATCH :id` (1 segment) ≠ this (2 segments) ✅ |
| `DELETE :babyMonId/partners/:partnerId` | BabyMon `DELETE :id` (1 segment) ≠ this (3 segments) ✅ |

**Why not a flat `DELETE /baby-mons/:partnerId`?** The mobile originally called `DELETE /baby-mons/{partnerId}` — but this collides with `DELETE /baby-mons/:id` (delete BabyMon) in `BabyMonController`. NestJS would route ambiguously or pick the wrong handler. The nested path `DELETE /baby-mons/:babyMonId/partners/:partnerId` has more segments and cannot be confused with any BabyMon CRUD route.

---

## Bugs Found & Fixed During Verification

After writing the implementation, the end-to-end flow was traced path-by-path through every method. Four logic bugs were discovered during this retrace:

| # | Where | Bug | Fix |
|---|-------|-----|-----|
| 1 | `getPartnersForBabyMon` access gate | **REJECTED/EXPIRED invitees could pass the gate.** The gate queried for any `LinkedAccount` with the matching `babyMonId` regardless of status. A rejected invitee would pass the gate (then see an empty list, but shouldn't be admitted at all). | Added `status: { in: ['LINKED', 'PENDING'] }` to the gate query. REJECTED and EXPIRED invitees are now treated as strangers (`ForbiddenException`). |
| 2 | `removeLink` for LINKED accounts | **Deleting the `LinkedAccount` destroyed the co-parent relationship even when other shared babies remained.** If Alice and Bob co-parent Baby X and Baby Y, and Alice removes Bob from Baby X, the current logic deleted the entire `LinkedAccount` — orphaning Bob's `LinkedBabyMon` for Y and breaking access checks. | After revoking `LinkedBabyMon` for this baby, count remaining `LinkedBabyMon` rows for the partner. Only delete `LinkedAccount` if count is 0. Otherwise keep the relationship alive and return `"Partner access revoked for this baby"`. |
| 3 | Schema `babyMon` relation | **`onDelete: Cascade` on `LinkedAccount.babyMon`.** If the owner deletes a BabyMon, the cascade would delete the `LinkedAccount` — destroying the co-parent relationship for all other shared babies. | Changed to `onDelete: SetNull`. Deleting a baby nullifies the `babyMonId` on the `LinkedAccount` but leaves the co‑parent relationship intact. The `LinkedBabyMon` cascade (separate FK) properly removes the per-baby access. |
| 4 | `getPartnersForBabyMon` query scope | **Returned ALL `LinkedAccount` rows for the baby, even ones the viewer wasn't party to.** If Alice invited Bob AND Carol for Baby X, Bob's partner list would include Carol's row — but `toPartnerDto` would map the "partner" incorrectly (falling through to `row.userA` = Alice, showing a duplicate of the owner). | Restructured the query to `AND: [{ OR: [{ userAId: userId }, { userBId: userId }] }, { status in ... }]`. Each viewer only sees rows they are a direct participant in. Bob sees only his own link (Alice). He does not see Carol. |

---

## File Inventory

### Changed (8 files)

| File | Change summary |
|------|---------------|
| `apps/api/prisma/schema.prisma` | `role` + `babyMonId` (FK SetNull) on `LinkedAccount`, back-relation on `BabyMon` |
| `apps/api/src/linked-accounts/dto/linked-accounts.dto.ts` | `partnerEmail`→`email`, `accept:bool`→`status:'ACCEPTED'\|'DECLINED'`, `role` enum, exported type constants |
| `apps/api/src/linked-accounts/linked-accounts.service.ts` | Full lifecycle rewrite: invite with role+babyMonId+email, respond with transaction access grant, remove with remaining-baby count check, caller-relative partner listing with privacy filter, status normalization layer |
| `apps/api/src/linked-accounts/linked-accounts.controller.ts` | BabyMon-nested partner routes (`:babyMonId/partners`, `:babyMonId/partners/invite`, `:partnerId/respond`, `:babyMonId/partners/:partnerId`) — no collision with BabyMon CRUD |
| `apps/api/src/linked-accounts/linked-accounts.module.ts` | Imported `MailModule` (was missing) |
| `apps/mobile/lib/core/data/api_client.dart` | `removePartner(babyMonId, partnerId)` — two args, non-colliding nested path |
| `apps/mobile/lib/features/settings/presentation/screens/partners_screen.dart` | Replaced 3× "Partners feature coming soon" with `extractErrorMessage(e)`; passes `_babyMonId` to `removePartner` |
| `apps/mobile/lib/core/testing/stub_api_client.dart` | Signature sync (2-arg `removePartner`) |

### New (2 files)

| File | Contents |
|------|----------|
| `apps/api/prisma/migrations/20260621000000_add_partner_role_and_babymon/migration.sql` | ALTER TABLE + FK + index for `role` and `babyMonId` |
| `apps/api/src/linked-accounts/linked-accounts.service.spec.ts` | 19 unit tests covering invite×6, respond×5, remove×4, normalization×4 |

### Pre-existing mobile files that already matched (no change needed)

| File | Reason |
|------|--------|
| `apps/mobile/test/mocks/api_mock.dart` | Already had 2-arg `removePartner` signatures |

---

## Test Coverage

**19 unit tests** for `LinkedAccountsService` — jest mock pattern matching `auth.service.spec.ts` and `baby-mon.service.spec.ts`:

| Group | Tests | Coverage |
|-------|-------|----------|
| `invitePartner` | 6 | Fresh invite, non-registered (NotFound), non-owner (Forbidden), self-invite (BadRequest), already-linked idempotent, rejected→reset |
| `respondToInvitation` | 5 | Accept grants+flips, Forbidden if not userB, already processed (BadRequest), expired (BadRequest), decline marks REJECTED |
| `removeLink` | 4 | Delete PENDING, revoke LINKED + delete account when 0 remaining, revoke LINKED + keep account when N remaining, Forbidden if not party |
| `getPartnersForBabyMon` | 4 | DB LINKED→ACCEPTED and PENDING→PENDING mapping, invitee access during PENDING, stranger denied, REJECTED invitee denied by gate |

```
PASS src/linked-accounts/linked-accounts.service.spec.ts
  LinkedAccountsService
    invitePartner
      ✓ creates PENDING with role + babyMonId
      ✓ throws NotFound for non-registered invitee
      ✓ throws Forbidden if caller is not the owner
      ✓ throws BadRequest on self-invite
      ✓ is idempotent when already LINKED — just grants baby access
      ✓ resets a REJECTED invitation to PENDING
      ✓ sends invitation email fire-and-forget
    respondToInvitation
      ✓ on ACCEPT: grants LinkedBabyMon + flips to LINKED (atomic)
      ✓ throws Forbidden if responder is not userB
      ✓ throws BadRequest if already processed
      ✓ throws BadRequest if expired
      ✓ DECLINE marks REJECTED without granting access
    removeLink
      ✓ deletes PENDING invitation outright
      ✓ revokes LinkedBabyMon access and deletes link when no other babies remain
      ✓ keeps LinkedAccount when partner still shares other babies
      ✓ throws Forbidden if caller not in the link
    getPartnersForBabyMon
      ✓ maps DB LINKED → ACCEPTED and PENDING → PENDING
      ✓ lets an invitee view the partner roster while PENDING
      ✓ denies a stranger
Tests: 19 passed, 19 total
```

---

## Key Design Decisions

| Decision | Rationale |
|----------|----------|
| **API matches mobile contract** | Mobile is the user-facing surface; fewer changes there (1 method signature vs rewriting the entire mobile client) |
| **Partners nested under BabyMons** | Matches how the mobile UI models it (you invite a partner *for* a specific baby) |
| **`role` as free-form String, not DB enum** | Adding roles doesn't require migration; DTO validates the set |
| **`babyMonId` stored on `LinkedAccount`** | Needed during PENDING phase so accept knows which baby to grant access to |
| **`babyMonId` has `onDelete: SetNull`** | Deleting a baby must not destroy the co-parent relationship |
| **Transaction on accept** | Never create `LinkedAccount=LINKED` without corresponding `LinkedBabyMon` — prevents "linked but locked out" state |
| **Fire-and-forget email** | `sendLinkedAccountInvitation` is `.catch()`'d so a SendGrid outage doesn't block the invite API |
| **Caller-relative partner listing** | `toPartnerDto` always shows the OTHER party relative to the viewer — works symmetrically for both inviter and invitee |
| **LinkedAccount survives multi-baby removal** | Count remaining `LinkedBabyMon` rows before deleting the account — prevents accidentally destroying a co-parent relationship |
| **Privacy: viewer-must-be-participant filter** | A co-parent can only see partners they are directly linked to, not other co-parents of the same baby |

---

## Out of Scope (Declared)

| Item | Rationale |
|------|----------|
| Inviting non-registered users | Requires email-based provisional accounts + token endpoint — deferred to v2 |
| Web app (`apps/web`) | No web client exists in the repository |
| Access-level management UI | Existing `LinkedBabyMon.access` (READ/EDIT/ADMIN) is stored but not surfaced in the mobile UI — deferred |
| `GET /linked-accounts/invitations` mobile wiring | The API endpoint exists for admin/non-mobile use but there's no mobile screen for the invitee's "incoming invitations" inbox — the invitee discovers via `getPartnersForBabyMon` which now admits PENDING invitees |
