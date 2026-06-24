# 10 — Database Migration Strategy & Schema Drift Resolution

**Date:** 2026-06-24  
**Updated:** 2026-06-25  
**Status:** Resolved — with corrected guidance

---

## Problem

Over multiple development sessions, the Prisma schema accumulated changes never captured in migration files. This resulted in **schema drift** — the database had columns, tables, enums, and indexes not present in any migration.

### Drift examples

| Model | Missing from migrations |
|-------|------------------------|
| `User` | `phone`, `tosAcceptedAt`, `tosVersion`, `privacyAcceptedAt`, `privacyVersion`, `consentDataAt`, `notificationsEnabled`, `pushMilestones`, `pushBadges`, `pushGrowth`, `pushProposals`, `quietHoursStart`, `quietHoursEnd` |
| `BabyMon` | `gestationalAgeAtBirth`, `dueDate`, `isGraduated`, `graduatedAt`, `siblingGroupId`, `traitsUpdatedAt` |
| Multiple | Enum changes, new tables (`SleepLog`, `Allergy`, `MedicalTeam`, `DailyActivity`), index changes |

---

## What went wrong (2026-06-25)

`prisma db push --accept-data-loss` was used twice:
1. To resolve accumulated schema drift
2. To add PromoCode models

Each run dropped every foreign key constraint in the database. The database remained structurally valid for basic CRUD but post-create operations (audit logs, XP, badges) failed with Prisma errors, returning "A database error occurred" to the frontend. Users saw errors, retried, and created duplicate entries.

**`prisma db push` is never safe to use on an existing database.** It will drop constraints, alter enums, and modify column types without regard for existing data integrity.

---

## Correct approach for schema changes

### Adding new tables/models (the PromoCode case)

```
npx prisma migrate dev --name add_promo_codes
```

This generates a clean, reviewable migration SQL file that only adds the new tables. No existing objects are touched. Then deploy with `prisma migrate deploy`.

### Resolving schema drift (the accumulated drift case)

Do NOT use `prisma db push`. Instead, baseline the schema into a single clean migration from a fresh database:

```
# 1. Create a fresh PostgreSQL database
createdb babymon_fresh

# 2. Generate baseline migration from the fresh DB
DATABASE_URL="postgresql://babymon@127.0.0.1:5432/babymon_fresh" \
  npx prisma migrate dev --name baseline

# 3. This creates one migration file with the full DDL including all constraints
# 4. Delete all old migrations
# 5. Test on a staging DB
# 6. Deploy with prisma migrate deploy
```

After baselining, every future schema change goes through `prisma migrate dev` as incremental migrations.

### ⚠️ Never use these commands

| Command | Why it's dangerous |
|---------|-------------------|
| `prisma db push` | Drops foreign keys, constraints, and indexes without warning |
| `prisma db push --accept-data-loss` | Same as above, but also silently drops enums and alters columns |
| Manual migration SQL | Easy to miss constraints and indexes. Always use `prisma migrate dev` |

---

## Current state

- **7 clean migrations** in `prisma/migrations/`
- Database was fully reset (`migrate reset --skip-seed` → `db seed`) to restore integrity
- PromoCode + PromoRedemption models exist in schema but NOT in a migration file
- **Next step before production:** run `prisma migrate dev --name add_promo_codes` to capture them properly

---

## Related: Routine Sync Protocol Fix

### Problem
Activity names in routine templates were not unique. "Feed." appeared at both 10:30 AM and 2:00 PM. The sync protocol used activity names as identifiers, causing the `activityToKey` reverse map to be lossy for duplicates.

### Fix
- **Seed data:** Made all activity names unique within each template (e.g., `"Feed. — mid-morning"`). All 17 templates verified clean.
- **Sync protocol:** Sends the full merged list of completed activities (not just pending deltas).
- **Frontend guards:** Orphaned pending IDs filtered and persisted to SharedPreferences.

---

## Related: BabyMon Card Contact Number Crash

### Problem
Editing the BabyMon card's contact number crashed. `getProfile` excluded `phone` from its select, so the field always returned `null` after reload. `updateBabyMon` silently dropped `gender`.

### Fix
| File | Change |
|------|--------|
| `apps/api/src/users/users.service.ts` | `getProfile` select now includes `phone: true` |
| `apps/api/src/baby-mon/baby-mon.service.ts` | `update` data now includes `gender: dto.gender` |

---

## Git Commits

- `894647d` — fix: comprehensive UI/UX and sync bug fixes
- `2c3c357` — chore: clean migrations — remove half-baked manual migration
- `40e398c` — feat: promo code system for premium access
