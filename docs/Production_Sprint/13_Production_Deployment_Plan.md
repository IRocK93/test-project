# Production Deployment Plan

## Document Cross-Reference
This plan consolidates items from:
- `03_Backend_ConfigService_Migration.md` — 3 items, all unfixed → incorporated in Phase 6b
- `06_Database_Android_Build.md` — 5 items, all unfixed → incorporated in Phase 6c

> **⚠️ Last validated against code: 2026-07-04.** Four "CRITICAL" bugs previously listed in Phase 6b/6c (Auth ConfigService keys, process.env direct access, Release keystore build script, Application ID) were re-verified against the current code and are no longer concerns. They have been removed and replaced with the actual pre-launch work that remains. See Phase 6b/6c below for the updated list.

## Quick Status

| # | Item | Priority | Doc Source | Phase |
|---|------|----------|------------|-------|
| 1 | Migration baseline verified | ✅ DONE | New | — |
| 2 | Model URLs from server | Planned | New | 2 |
| 3 | Database hosting | Planned | New | 1 |
| 4 | API hosting | Planned | New | 2 |
| 5 | Generate production keystore | ❌ CRITICAL | — | 6c |
| 6 | Set up Neon cloud database | ❌ CRITICAL | — | 6b |
| 7 | Set remaining env vars in Railway | ❌ HIGH | — | 6b |
| 8 | Build signed AAB | ❌ CRITICAL | — | 6c |
| 9 | Submit to Google Play | ❌ CRITICAL | — | 6c |
| 10 | AppConfig missing keys | ✅ DONE (2026-07-04) | 03 | 6b |
| 11 | Graceful server restart | Planned | New | — |
| 12 | Error monitoring | Planned | New | 4 |
| 13 | ResponseCache hardening | Planned | New | 5 |
| 14 | SHA256 verification | Planned | New | 6 |
| 15 | ApiClient.dio exposure | Planned | New | 7 |
| 16 | 11 missing DB indexes | ❌ MEDIUM | 06 | 6c |
| 17 | better-sqlite3 unused | ✅ DONE (2026-07-04) | 06 | 6c |
| 18 | Gender/Stage enums | ✅ DONE (2026-07-04) | 06 | 6c |
| 19 | Flutter app deployment | Planned | New | 6 |

---

## Phase 1: Database Hosting

### Option A: Neon (serverless PostgreSQL) — RECOMMENDED
- **Cost:** Free tier (0.5 GB storage, 1 project) → $19/mo (10 GB)
- **Why:** Built for serverless, branching (dev/staging/prod), connection pooling included, no maintenance
- **Setup:**
  1. Create Neon project at neon.tech
  2. Create `dev` and `prod` branches
  3. Run `prisma migrate deploy` against each branch
  4. Set `DATABASE_URL` in environment (direct connection for Prisma) and `DIRECT_URL` (pooled connection for app)
  5. Add `?pgbouncer=true` to pooled connection URL for Prisma compatibility

### Option B: Railway
- **Cost:** $5/mo starter
- **Why:** Simple, batteries-included, good for solo devs
- **Setup:** Similar — create PostgreSQL service, get connection string, run migrations

### Option C: Supabase
- **Cost:** Free tier (500 MB database) → $25/mo
- **Why:** Includes auth, storage, realtime — but you already have your own auth system
- **Setup:** More complex — additional services you may not need

### Decision: Neon for database, Railway as backup plan

---

## Phase 2: API Server Hosting

### Option A: Railway — RECOMMENDED
- **Deploy:** Connect GitHub repo → Railway auto-builds from Dockerfile
- **Cost:** $5/mo minimum
- **Setup:**
  1. Push Dockerfile to repo (already exists at `apps/api/Dockerfile`)
  2. Railway detects Node.js/NestJS project
  3. Set environment variables in Railway dashboard (DATABASE_URL, JWT_SECRET, etc.)
  4. Add `start:prod` script: `prisma migrate deploy && node dist/src/main`
  5. Enable automatic deployments from `master` branch

### Option B: Fly.io
- **Deploy:** `fly launch` from CLI
- **Cost:** Free tier (3 VMs) → pay-as-you-go
- **Setup:** Similar Docker-based deployment

### Option C: Render
- **Deploy:** Web service from GitHub
- **Cost:** Free tier (sleeps after inactivity) → $7/mo (always-on)

### Decision: Railway for simplicity, Render for budget

---

## Phase 3: Backend Pre-Launch Checklist

### Security
- [ ] Rotate all secrets (JWT_SECRET, SENDGRID_API_KEY, etc.) — never use dev secrets in prod
- [ ] Enable rate limiting (already configured — verify limits are production-appropriate)
- [ ] Add Helmet CSP headers (already configured in main.ts — verify)
- [ ] Enable CORS for production domains only (not `*`)
- [ ] Add `trust proxy` for Railway/Render (they sit behind a proxy)

### Database
- [ ] Run `prisma migrate deploy` against production database
- [ ] Verify migration applied correctly: `prisma migrate status`
- [ ] Set up automated database backups (Neon includes this; for Railway, use `pg_dump` cron)
- [ ] Test restore from backup

### Monitoring
- [ ] Set up Sentry for error tracking (NestJS + Flutter)
- [ ] Set up UptimeRobot or similar for health checks
- [ ] Add a `/health` endpoint that checks DB connectivity
- [ ] Configure log drain to a service (Papertrail, Logtail, or Datadog free tier)

### CI/CD
- [ ] GitHub Actions: run tests on PR
- [ ] GitHub Actions: run `prisma migrate status` to detect drift
- [ ] Railway auto-deploy: only from `master`, manual for staging
- [ ] Add smoke tests post-deploy (hit `/health` endpoint)

---

## Phase 4: Database Migration Strategy for Production

### Current state
- We have one squashed baseline migration (`0001_initial_baseline`) that matches the live DB exactly
- Old individual migration folders are deleted (correct — they were half-baked)

### Going forward
1. **Never use `prisma db push` in production** — it bypasses migration history and can cause data loss
2. **Make schema changes via `prisma migrate dev --create-only`** — generates a new migration SQL file
3. **Review the generated SQL** before committing — Prisma sometimes does destructive operations (DROP/RENAME)
4. **Apply in production via `prisma migrate deploy`** — part of the `start:prod` script
5. **Add `prisma migrate status` to CI** — blocks deploy if there are unapplied migrations

### Migration file management
```
prisma/migrations/
  0001_initial_baseline/     # Baseline (current state)
    migration.sql
  0002_add_feature_x/        # Future migrations
    migration.sql
  migration_lock.toml        # Tracked in git — do not delete
```

### Rollback strategy
- Prisma does not support automatic rollbacks
- For breaking changes, create a reverse migration file manually
- Test all migrations against a staging database before production
- Keep database backups (Neon branches or `pg_dump`) before each migration

---

## Phase 5: Environment Configuration

### Files needed
- `.env.production` — production secrets (NOT committed to git)
- `.env.staging` — staging secrets
- `.env.example` — template for new developers (committed)

### Secrets management
- Dev: `.env` file (gitignored)
- Production: Railway/Render dashboard environment variables
- CI: GitHub Secrets

### Required environment variables for production

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/babymon
DIRECT_URL=postgresql://user:pass@host:5432/babymon?pgbouncer=true

# Auth
JWT_SECRET=<random-64-char-string>
JWT_REFRESH_SECRET=<different-random-64-char-string>

# Email
SENDGRID_API_KEY=<key>
MAIL_FROM=noreply@babymon.app

# Storage (optional — for media uploads)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
S3_BUCKET=
S3_REGION=

# Companion (model download proxy)
COMPANION_MODEL_URL=https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf?download=true

# Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=100
```

---

## Phase 6: Flutter App Deployment

### Android
- Build: `flutter build apk --release` or `flutter build appbundle --release`
- Sign with production keystore (generate via `keytool`, store in CI secrets)
- Publish on Google Play Console ($25 one-time fee)
- Update `version` in `pubspec.yaml` for each release

### iOS (future)
- Requires Apple Developer account ($99/year)
- Build: `flutter build ipa --release`
- Publish via App Store Connect

### OTA updates
- Consider Shorebird for instant Dart code updates (no store review needed for Dart changes)

---

## Phase 6b: Backend Pre-Launch Work

> **Note:** The two CRITICAL/HIGH bugs previously listed here (Auth ConfigService keys, process.env direct access) have been removed — they are no longer concerns. `apps/api/src/auth/auth.service.ts` already uses the correct `ConfigService` keys (`trialDays`, `jwt.refreshExpiresInDays`, `nodeEnv`), and the only `process.env` references are in `configuration.ts` (the loader itself) and `main.ts` (startup-only Sentry init). AppConfig missing keys is also DONE — see below.

### AppConfig missing keys — ✅ DONE (2026-07-04)
**File:** `apps/api/src/config/configuration.ts`
All 6 keys are already present in the `AppConfig` interface and the default values function in `configuration.ts`: `sentry.dsn`, `crypto.key`, `dataRetention.days`, `dev.bypassTierGuard`, `database.url`, `jwt.refreshExpiresInDays`.
**How it was done:** All 6 keys are declared in the `AppConfig` interface and populated from `process.env` in the default-export function. The `database.url` and `jwt.refreshExpiresInDays` keys are nested (`database: { url }` and `jwt: { refreshExpiresInDays }`) rather than flat — a flat-key grep was the false-negative in the original audit.

### Set up Neon cloud database — CRITICAL
**Status:** Not done. The current `DATABASE_URL` in Railway points to a local Docker container, not a cloud database.
**What's needed:**
1. Sign up at https://neon.tech (free tier: 0.5 GB storage, 1 project)
2. Create a `babymon` project with a `prod` branch
3. Get the `DATABASE_URL` (direct connection for Prisma) and `DIRECT_URL` (pooled connection, with `?pgbouncer=true` appended)
4. Run `prisma migrate deploy` against the production database (use the script `npm run prisma:migrate:prod` in `apps/api/`)
5. Add `DATABASE_URL` and `DIRECT_URL` to Railway's Variables tab, replacing the local Docker URL currently in use
6. Restart the Railway `babymon-api-production` service

### Set remaining env vars in Railway — HIGH
**Status:** Partially done. `DATABASE_URL` and `JWT_SECRET` are confirmed set. The full set still needs verification.
**What's needed:** Open the Railway service → Variables tab, and confirm every env var from Phase 5 is set. Priority ones to verify:
- `DATABASE_URL` (set, but should point to Neon — see above)
- `JWT_SECRET` (set ✓)
- `JWT_REFRESH_EXPIRES_IN_DAYS` (defaults to 7 if missing)
- `TRIAL_DAYS` (defaults to 14 if missing)
- `SENDGRID_API_KEY` (only required if email verification is enabled at launch)
- `STRIPE_SECRET_KEY` (only required if subscriptions are live at launch)
- `SENTRY_DSN` (optional, for error monitoring)
- `CORS_ORIGINS` (set to production domains only, not `*`)
- `NODE_ENV` (must be `production`)

---

## Phase 6c: Mobile App Pre-Launch Work

> **Note:** The two CRITICAL bugs previously listed here (Release keystore build script, Application ID) have been verified against the current code and are no longer concerns. `apps/mobile/android/app/build.gradle.kts` already correctly loads `key.properties` and creates a `release` signing config when present (lines 10-17, 47-65), and `applicationId` is already `com.babymon.app` (line 36). These have been removed from this plan.

> Of the three sub-sections below, **Unused Dependency** and **Free-Text Gender/Stage** are now ✅ DONE (re-validated 2026-07-04). Only **Missing Database Indexes** remains as a real follow-up.

### Unused Dependency — ✅ DONE (2026-07-04)
**File:** `apps/api/package.json`
`better-sqlite3` was removed; it had zero imports in the codebase and was adding native compilation overhead on every deploy.
**How it was done:** The `better-sqlite3` dependency was removed from `apps/api/package.json` (no longer in the dependencies block). Source code has zero imports. Only stale local artifacts remain: a single reference in `package-lock.json` (regenerate the lockfile to clean) and a folder in `node_modules/` (local-only, doesn't affect production builds).

### Missing Database Indexes — MEDIUM
11 indexes were missing from `prisma/schema.prisma`. See `06_Database_Android_Build.md` for full list. Key ones:
- `User.role`, `Subscription.stripeCustomerId`, `Subscription.stripeSubscriptionId`, `Media.s3Key`
- `syncStatus` on Milestone, FeedLog, HealthRecord, SleepLog (offline sync engine)
**Fix:** Add to schema, run `prisma migrate dev --name add_production_indexes` (last validated 2026-07-04 — several indexes were added in recent commits; re-verify against `schema.prisma` before launch).

### Free-Text Gender/Stage — ✅ DONE (2026-07-04)
`BabyMon.gender` and `BabyMon.stageStartType` are now typed as the `Gender` and `StageStartType` Prisma enums, preventing inconsistent string values like "male" / "Male" / "MALE".
**How it was done:** Both `enum Gender { ... }` and `enum StageStartType { ... }` are defined in `apps/api/prisma/schema.prisma` (lines 145 and 153). The `BabyMon` model uses these enums for the `gender` and `stageStartType` fields (line 365 for `stageStartType`).

### Generate production keystore — CRITICAL
**Status:** Not done. No `.jks` or `.keystore` file exists anywhere in the repo or on the local filesystem.
**What's needed:**
1. On a local machine (outside the repo), run `keytool -genkey -v -keystore babymon-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Save the keystore in a safe location OUTSIDE the repo (e.g., `~/keystores/` or a password manager)
3. **This file is irreplaceable.** Losing it means the Play Store listing can never be updated. Treat it like a birth certificate.
4. Store the keystore + password in GitHub Actions secrets (4 secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`)
5. Create a local `apps/mobile/android/key.properties` (gitignored) referencing the keystore for local builds

### Build signed AAB — CRITICAL
**Status:** Not done.
**What's needed:**
1. Once the keystore is generated, run `flutter build appbundle --release` locally to verify the build succeeds
2. Add an `android-release-build` job to `.github/workflows/ci.yml` that:
   - Decodes the base64 keystore from the `ANDROID_KEYSTORE_BASE64` secret
   - Writes `key.properties` from the 4 secrets
   - Runs `flutter build appbundle --release --dart-define=API_BASE_URL=https://babymon-api-production.up.railway.app`
3. Upload the resulting AAB as a CI artifact (`apps/mobile/build/app/outputs/bundle/release/app-release.aab`)

### Submit to Google Play — CRITICAL
**Status:** Not done.
**What's needed:**
1. Pay the $25 one-time Google Play Console registration fee
2. Create the Play Console app listing (name, short/full description, screenshots, feature graphic, privacy policy URL)
3. **Privacy policy URL** — the existing `legal-pages` service on Railway (`https://babymon-production.up.railway.app/privacy`) already hosts this. Use that URL directly, no need to re-host.
4. Upload the signed AAB to the Internal Testing track first (faster review than Production)
5. Once verified, promote to Production
6. Future updates must be signed with the same keystore generated above

---

## Phase 7: Launch Checklist (Runbook)

---

## Phase 7: Launch Checklist (Runbook)

1. [ ] Production database provisioned (Neon)
2. [ ] Migrations applied to production DB
3. [ ] API server deployed (Railway)
4. [ ] Environment variables set in production
5. [ ] `/health` endpoint returns 200
6. [ ] `api/models/companion-llm/manifest` returns valid model list
7. [ ] Auth flow tested (register → login → JWT → refresh)
8. [ ] `flutter build appbundle --release` succeeds
9. [ ] App signed with production keystore
10. [ ] Submitted to Google Play Console
11. [ ] Sentry/error monitoring confirmed receiving events
12. [ ] Database backups confirmed automated
13. [ ] Uptime monitoring configured
14. [ ] Rate limiting verified at expected thresholds

---

## Estimated Costs (Monthly)

| Service | Tier | Cost |
|---------|------|------|
| Neon (database) | Free / Launch | $0–19 |
| Railway (API) | Hobby | $5 |
| Google Play | One-time | $25 |
| Sentry | Free | $0 |
| UptimeRobot | Free | $0 |
| HuggingFace | Free | $0 |
| **Total** | | **$5–24/mo** |

---

## Timeline

| Phase | Effort | Priority |
|-------|--------|----------|
| 1. Database hosting | 1 day | Critical |
| 2. API hosting | 1 day | Critical |
| 3. Security/checklist | 2 days | Critical |
| 4. Migration strategy | Already done | Done |
| 5. Env config | 1 day | High |
| 6. App deployment | 2 days | High |
| 7. Launch runbook | 1 day | High |
