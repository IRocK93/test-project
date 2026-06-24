# BabyMon DevOps & Infrastructure Audit — v4

**Date:** 2026-06-22
**Overall Grade: D+**

---

## Critical Blockers (Unfixed from v3)

### B1. CI Branch Mismatch — Pipeline NEVER Runs
`.github/workflows/ci.yml:5` triggers on `branches: [main, develop]` but repository uses `master`. All 8 CI jobs are dead code.

### B2. Docker & Compose Files Excluded from Git
`.gitignore:16-17` blocks `Dockerfile*` and `docker-compose*.yml` from version control. The Dockerfile and compose file are NOT in git history.

### B3. Prisma Version Drift
Client `^5.22.0` vs CLI `^5.8.0` — 14 minor versions apart. Migration output may be incompatible with generated client.

### B4. CI Script `test:ci` Does Not Exist
CI runs `npm run test:ci` but `package.json` has no such script. Only `test`, `test:cov`, `test:e2e` are defined.

### B5. Lint Errors Pass Silently
CI lint step uses `npm run lint || true` — lint failures never block PRs.

---

## Docker Setup

### Strengths
- True multi-stage build (builder + production)
- Non-root user (`USER nestjs`, uid 1001)
- `npm ci --only=production` keeps image lean
- Comprehensive `.dockerignore`
- PostgreSQL 16 Alpine with named volume persistence
- Test database isolation (separate container on port 5433)
- Health checks using `pg_isready`

### Issues
- No `HEALTHCHECK` instruction in Dockerfile
- Default passwords in compose: `babymon_dev_password`, `test`/`test`
- `restart: unless-stopped` missing on postgres services
- No resource limits (mem_limit, cpus)
- Builder uses `node:20-bookworm` (~1GB) — could use slim variant

---

## Environment Management

### Strengths
- Comprehensive Joi validation covering 20+ variables
- `JWT_SECRET` conditionally required in production (min 32 chars)
- Good defaults for all optional variables

### Issues
- Real email hardcoded in `.env.example:67`: `merghani93@gmail.com`
- `DATABASE_URL` is `Joi.string().optional()` with no URI format validation
- `STRIPE_SECRET_KEY`, `AWS_ACCESS_KEY_ID`, `FIREBASE_CONFIG` are optional — fail at runtime instead of startup
- Three different JWT secret fallbacks across codebase
- `SKIP_TIER_GUARD=true` in `.env.example` normalizes disabling subscription checks

---

## Deployment

- **No `railway.json`** in repository
- **No automated deployment** — everything is manual
- **No Docker registry push** in CI (`push: false`)
- **No Google Play deployment automation**
- **Documentation-Implementation mismatch**: docs say Cloudinary, code uses AWS S3

---

## Observability

### Present
- Pino structured logger with configurable `LOG_LEVEL`
- Three-tier health probes (overall, liveness, readiness)
- Database health verified with `SELECT 1` + latency timing
- Audit interceptor logs every request

### Missing
- **No Sentry or error tracking** — `SENTRY_DSN` is commented out, no `@sentry/nestjs`
- **No log aggregation** — Pino logs to stdout only
- **No Prometheus metrics endpoint**
- **No APM integration**
- **No alerting configuration**
- **No request ID propagation**

---

## Backup & Disaster Recovery: F

- **No automated database backups**
- **No S3 bucket versioning configured**
- **No cross-region replication**
- **No disaster recovery runbook**
- **No recovery testing**
- **No documented RTO/RPO**
- `AUDIT_RETENTION_DAYS=2555` defined but no cleanup cron job

---

## Recommendations

### Immediate (Week 1)
1. Fix `.gitignore` — unblock Dockerfile and compose
2. Fix CI branch triggers to `master`
3. Pin Prisma versions to `5.22.0`
4. Add `test:ci` script to package.json
5. Remove `|| true` from CI lint step

### High Priority (Week 1-2)
6. Add Dependabot config
7. Add `npm audit` to CI with failure on high/critical
8. Add HEALTHCHECK to Dockerfile
9. Remove hardcoded JWT secret fallback
10. Remove personal email from env files
11. Add Docker registry push to CI

### Medium Priority (Week 2-4)
12. Install `@sentry/nestjs` for production error tracking
13. Create `railway.json` at repo root
14. Add database backup script (scheduled pg_dump)
15. Enable S3 bucket versioning
16. Add Helmet middleware
17. Resolve Cloudinary-vs-S3 documentation discrepancy
