# Production Deployment Plan

## Document Cross-Reference
This plan consolidates items from:
- `03_Backend_ConfigService_Migration.md` — 3 items, all unfixed → incorporated in Phase 6b
- `06_Database_Android_Build.md` — 5 items, all unfixed → incorporated in Phase 6c

## Quick Status

| # | Item | Priority | Doc Source | Phase |
|---|------|----------|------------|-------|
| 1 | Migration baseline verified | ✅ DONE | New | — |
| 2 | Model URLs from server | Planned | New | 2 |
| 3 | Database hosting | Planned | New | 1 |
| 4 | API hosting | Planned | New | 2 |
| 5 | Release keystore | ❌ CRITICAL | 06 | 6c |
| 6 | Application ID | ❌ CRITICAL | 06 | 6c |
| 7 | Auth ConfigService keys | ❌ CRITICAL | 03 | 6b |
| 8 | process.env direct access | ❌ HIGH | 03 | 6b |
| 9 | AppConfig missing keys | ❌ HIGH | 03 | 6b |
| 10 | Graceful server restart | Planned | New | — |
| 11 | Error monitoring | Planned | New | 4 |
| 12 | ResponseCache hardening | Planned | New | 5 |
| 13 | SHA256 verification | Planned | New | 6 |
| 14 | ApiClient.dio exposure | Planned | New | 7 |
| 15 | 11 missing DB indexes | ❌ MEDIUM | 06 | 6c |
| 16 | better-sqlite3 unused | ❌ MEDIUM | 06 | 6c |
| 17 | Gender/Stage enums | ❌ LOW | 06 | 6c |
| 18 | Flutter app deployment | Planned | New | 6 |

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

## Phase 6b: Pre-Launch Technical Debt (from 03_Backend_ConfigService_Migration.md)

### Auth Service ConfigService Keys — CRITICAL
**File:** `apps/api/src/auth/auth.service.ts`
Lines 59, 310, 448 use wrong key names:
- `configService.get('TRIAL_DAYS')` → should be `configService.get('trialDays')` (UPPER_SNAKE_CASE keys return `undefined` in NestJS ConfigService)
- `configService.get('JWT_REFRESH_EXPIRES_IN')` → should be `configService.get('jwt.refreshExpiresInDays')`
**Impact:** Trial period always defaults to 14 days. JWT refresh expiry always is 7 days. Env vars silently ignored.

### process.env Direct Access — HIGH
13 files bypass ConfigService and read `process.env` directly:
- `stripe/` (2 files), `crypto.service.ts`, `prisma.service.ts`, `main.ts`, `mail/`, `notifications/`, `s3/`, `app.module.ts`, `data-retention/`, `tier.guard.ts`, `subscriptions/` (2 files)
**Fix:** Each injects `ConfigService` and uses `configService.get<Type>('camelCase.key')`

### Missing AppConfig Keys — HIGH
6 keys needed in `configuration.ts` interface and defaults:
`sentry.dsn`, `crypto.key`, `dataRetention.days`, `dev.bypassTierGuard`, `database.url`, `jwt.refreshExpiresInDays`

---

## Phase 6c: Pre-Launch Technical Debt (from 06_Database_Android_Build.md)

### Release Keystore — CRITICAL
**File:** `apps/mobile/android/app/build.gradle.kts`
Release build type uses `signingConfig = signingConfigs.getByName("debug")` — Google Play rejects APKs signed with debug certs.
**Fix:**
1. Generate upload keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties` (gitignored) with storePassword, keyPassword, keyAlias, storeFile
3. Update `build.gradle.kts` with `signingConfigs { create("release") { ... } }`

### Application ID — CRITICAL (before Play Store submission)
**File:** `apps/mobile/android/app/build.gradle.kts`
Current: `com.example.baby_mon` — `com.example.*` is a reserved placeholder that Play Console rejects.
**Fix:** Change to `com.babymon.app` (or your actual domain). Must match Firebase project. ⚠️ Changing after initial Play release creates a separate app listing.

### Unused Dependency — MEDIUM
**File:** `apps/api/package.json`
`better-sqlite3` has zero imports in the codebase. Adds native compilation overhead on every deploy.
**Fix:** `npm uninstall better-sqlite3`

### Missing Database Indexes — MEDIUM
11 indexes missing from `prisma/schema.prisma`. See `06_Database_Android_Build.md` for full list. Key ones:
- `User.role`, `Subscription.stripeCustomerId`, `Subscription.stripeSubscriptionId`, `Media.s3Key`
- `syncStatus` on Milestone, FeedLog, HealthRecord, SleepLog (offline sync engine)
**Fix:** Add to schema, run `prisma migrate dev --name add_production_indexes`

### Free-Text Gender/Stage — LOW
`BabyMon.gender` and `BabyMon.stageStartType` are plain Strings. Should be enums to prevent inconsistent values ("male"/"Male"/"MALE").
**Fix:** Define `Gender` and `StageStartType` enums in Prisma schema, add migration.

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
