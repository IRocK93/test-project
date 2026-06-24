# Issues 2, 18-19: Database Indexes, Android Build, Dependencies

**Date:** 2026-06-23 | **Priority:** CRITICAL (signing) / MEDIUM (indexes/deps)

---

## Issue 2: Release APK Signed with Debug Keystore

**File:** `apps/mobile/android/app/build.gradle.kts`, lines 34-40

```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")   // ← DEBUG KEY
}
```

**Risk:** CRITICAL — Google Play rejects APKs signed with debug certs. App is impersonatable (debug keystore is public).

**Additional issue:** Application ID is `com.example.baby_mon` — the `com.example.*` prefix is a reserved placeholder.

### Remediation

1. **Generate production keystore:**
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `android/key.properties`** (never commit to git):
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **Update `build.gradle.kts`** — add `signingConfigs { create("release") { ... } }` and reference from release build type.

4. **Change `applicationId`** to a real domain (e.g., `com.babymon.app`). ⚠️ Must match Firebase project and Play Console — changing it after initial Play release creates a separate app.

---

## Issue 18: 11 Missing Database Indexes

**File:** `apps/api/prisma/schema.prisma`

| # | Model | Missing Index | Query Impact |
|---|-------|--------------|-------------|
| 1 | `User` | `@@index([role])` | Admin lookups sequential scan |
| 2 | `Subscription` | `@@index([stripeCustomerId])` | Stripe webhook lookups |
| 3 | `Subscription` | `@@index([stripeSubscriptionId])` | Stripe webhook lookups |
| 4 | `Media` | `@@index([s3Key])` | S3 object lookups/deletions |
| 5 | `Device` | `@@index([platform])` | Push notification dispatch |
| 6 | `Milestone` | `@@index([syncStatus])` | Offline sync engine |
| 7 | `FeedLog` | `@@index([syncStatus])` | Offline sync engine |
| 8 | `HealthRecord` | `@@index([syncStatus])` | Offline sync engine |
| 9 | `SleepLog` | `@@index([syncStatus])` | Offline sync engine |
| 10 | `AuditLog` | `@@index([babymonId, createdAt])` | Timeline/activity views |
| 11 | `AllergyEvent` | `@@index([userId])` | Per-user event queries |

After adding to schema, run:
```bash
npx prisma migrate dev --name add_production_indexes
```

### Also: BabyMon.gender and stageStartType Are Free-Text, Not Enums

Both fields are `String` while the schema already uses enums extensively (`GrowthType`, `MilestoneDomain`, `SubscriptionTier`, `AdviceCategory`). Free-text allows inconsistent values like "male"/"Male"/"MALE". Should define `Gender` and `StageStartType` enums.

---

## Issue 19: better-sqlite3 in Production Dependencies

**File:** `apps/api/package.json`, line 43

```json
"better-sqlite3": "^12.6.2"
```

**Finding:** Zero imports or references in the entire codebase. The app uses PostgreSQL (per Prisma schema), not SQLite. `better-sqlite3` is a SQLite native addon — completely unused.

**Impact:** Adds native compilation overhead (node-gyp, C++ toolchain) on every deployment. Unnecessary install size (~500KB). False-positive vulnerability alerts in `npm audit`.

**Fix:**
```bash
npm uninstall better-sqlite3
```
