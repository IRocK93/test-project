# S16 — DevOps & DX Audit

**Date:** 2026-06-18 | **Overall:** B — Well-structured with sharp edges

---

## Key Findings

### DX-C01 | 🔴 CRITICAL | AuditInterceptor Defined But NEVER Registered
The entire audit trail pipeline (18 event types across auth, CRUD, subscriptions) is dead code. No `APP_INTERCEPTOR` registration in `app.module.ts`. Zero audit events ever written to the database.

### DX-H01 | 🟠 HIGH | Invalid npm ci Flag in Dockerfile
`npm ci --only=production=false` is non-standard syntax. Flag is effectively ignored (happens to work).

### DX-H02 | 🟠 HIGH | Hardcoded Windows Paths in Dev Onboarding Docs
`00-README-FIRST.md` uses `C:\Android\Sdk\emulator` and `d:\Claude Workspace\...` — breaks for macOS/Linux devs.

### DX-H03 | 🟠 HIGH | No Flutter Build Verification in CI
CI tests code quality but never verifies the mobile app compiles into an APK/IPA.

### DX-M01 | 🟡 MEDIUM | RATE_LIMIT_TTL Unit Mismatch
`.env.example` says 60 (seconds), code expects 60000 (milliseconds).

### DX-M02 | 🟡 MEDIUM | Sentry DSN Documented But Not Wired
No `@sentry/nestjs` imported. Error tracking is non-operational.

### DX-M03 | 🟡 MEDIUM | Duplicate seed:companion Script Key
### DX-M04 | 🟡 MEDIUM | No Pre-Commit Hooks
No husky, lefthook, or lint-staged.

### DX-M05 | 🟡 MEDIUM | No Request/Correlation ID
Debugging across services requires timestamp correlation.

## Strengths
- ✅ Multi-stage Docker with non-root user
- ✅ Comprehensive CI: lint, test, golden tests, Slack notifications
- ✅ Docker smoke test validates /health endpoint
- ✅ PostgreSQL service container with health checks
- ✅ Pino structured logging configured
- ✅ 40+ documentation files
- ✅ Kubernetes-style liveness/readiness probes
- ✅ Seed scripts use upsert for idempotency

## Previously Fixed (from prior audit)
- ✅ `|| true` masking on lint — removed
- ✅ `test:ci` script — now exists
- ✅ `.gitignore` blocking Docker files — fixed
- ✅ README.md — restored

## Summary Statistics
| Severity | Count |
|---|---|
| 🔴 Critical | 1 |
| 🟠 High | 3 |
| 🟡 Medium | 5 |
| **Total** | **9** |
