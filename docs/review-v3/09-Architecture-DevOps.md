# Architecture & DevOps Audit Report

## Grade: C+

## Summary

BabyMon has solid architectural foundations (multi-stage Docker, Joi config validation, Pino logging, health checks, test isolation) but suffers from critical blockers that prevent production readiness. The CI/CD pipeline targets branches that do not exist (`main`/`develop`) while the repository uses `master`, meaning the entire pipeline is silently idle. A severe Prisma version mismatch risks database migration corruption. No monorepo tooling means manual orchestration across three package ecosystems. Deployment is entirely undocumented in code; the deployment doc has an incorrect health-check path that would prevent Railway startup. Combined, these issues reduce a project with otherwise sound patterns to well-below production-readiness.

## Findings

| # | Severity | File/Section | Issue | Impact | Recommendation |
|---|----------|-------------|-------|--------|----------------|
| 1 | **CRITICAL** | `.github/workflows/ci.yml:5` | CI triggers on `branches: [main, develop]` but repository uses `master` (no `main` or `develop` exists) | Pipeline never runs. All testing, linting, and Docker builds are dead code | Rename `master` to `main` OR update CI to target `master` |
| 2 | **CRITICAL** | `apps/api/package.json:38,70` | Prisma client `^5.22.0` vs Prisma CLI `^5.8.0` -- 14 minor versions apart | Migration commands and generated client are incompatible. Silent data corruption possible at `prisma migrate deploy` | Pin both to same version; CI should assert `prisma --version` matches `@prisma/client` |
| 3 | **CRITICAL** | `.github/workflows/ci.yml:274` | Smoke test calls `curl -f http://localhost:3001/health` but global prefix is `api/v1` | Smoke test always fails -- health endpoint is at `/api/v1/health` | Change to `localhost:3001/api/v1/health` |
| 4 | **CRITICAL** | `docs/07-DEPLOYMENT.md:25` | Railway `healthcheckPath` is `/api/health`; actual endpoint is `/api/v1/health` | Railway deploy fails health check, app marked unhealthy | Change to `/api/v1/health` |
| 5 | **HIGH** | Root `package.json` | No monorepo tooling (no Turborepo, Nx, or pnpm workspaces) | No shared cache, no task graph, no scoped CI builds. Backend, Flutter, and `packages/*` run as independent silos | Add Turborepo with `turbo.json`; use `dependsOn` for task orchestration |
| 6 | **HIGH** | `packages/shared/` | Directory exists but is completely empty | No shared types, validation schemas, or utilities between API and mobile. Duplication of DTOs, enums (Gender, StageStartType, FeedingType), API path constants | Move Prisma enums, API response types, validation logic into shared TypeScript package |
| 7 | **HIGH** | `.github/workflows/ci.yml` | No deployment job, no registry push | Docker image is built and discarded. No tag push to GHCR/Docker Hub. No Railway deploy trigger | Add `docker/build-push-action` with `push: true` to GHCR; add Railway deploy step on main branch |
| 8 | **HIGH** | `.github/workflows/ci.yml` | No `npm audit` or `flutter pub outdated` step | Vulnerable dependencies ship silently | Add `npm audit --audit-level=high` to CI; fail on critical/high |
| 9 | **HIGH** | `.github/` | No Dependabot or Renovate config | Dependencies are 12-18 months stale with no automation to update | Add `.github/dependabot.yml` for npm, Docker, and GitHub Actions |
| 10 | **HIGH** | `apps/api/Dockerfile` | Missing `HEALTHCHECK` instruction | Container orchestrator cannot determine container health without external probe | Add `HEALTHCHECK --interval=30s CMD curl -f http://localhost:3000/api/v1/health/live \|\| exit 1` |
| 11 | **HIGH** | `docker-compose.yml:21-38` | Backend service has no `healthcheck` directive | `depends_on` only ensures postgres is healthy; API crashes are undetected | Add healthcheck block curling `/api/v1/health/live` |
| 12 | **HIGH** | `docker-compose.yml:7,29` | Default passwords (`babymon_dev_password`, `test`) committed in plaintext | Anyone with repo access knows local DB credentials; pattern normalizes secrets in source | Remove defaults; require `.env` file with `docker-compose --env-file` |
| 13 | **MEDIUM** | `.env.example:94` | Sentry DSN documented in env but `@sentry/nestjs` is never imported | Error tracking is non-functional despite being in the env template | Install `@sentry/nestjs` and initialize in `main.ts` |
| 14 | **MEDIUM** | `apps/api/src/config/env.validation.ts:78` | `DATABASE_URL` has `Joi.string().optional()` with no URI format check | Malformed DB URL passes startup validation; app crashes at first query | Use `Joi.string().uri({ scheme: 'postgresql' })` and validate early |
| 15 | **MEDIUM** | `apps/api/prisma/schema.prisma` | No connection pool configuration in datasource (no `connection_limit`) | Default connection pool may exhaust under load | Add `connection_limit = env("DATABASE_POOL_SIZE")` to datasource block |
| 16 | **MEDIUM** | `apps/mobile/pubspec.yaml:3` | `publish_to: 'none'` and `version: 1.0.0+1` static | No versioning strategy for releases | Implement version bump via CI semver tag |
| 17 | **MEDIUM** | Repo-wide | No `CHANGELOG.md` | No release notes, breaking change documentation | Adopt Keep a Changelog; auto-generate from conventional commits |
| 18 | **LOW** | `docker-compose.yml` | `restart: unless-stopped` only on backend, not postgres | If postgres crashes, backend keeps running with DB errors | Add `restart: unless-stopped` to postgres services |
| 19 | **LOW** | `apps/api/prisma/schema.prisma` | `passwordHash` is optional on User model | User can be created without any authentication; security gap | Make `passwordHash` required for email-based auth paths |

## Top 5 Production Blockers

1. **CI branch mismatch (`main` vs `master`)** -- The pipeline is dead. No tests, no lint, no Docker builds execute on push. Fix by aligning CI trigger branches with repository branches.

2. **Prisma version drift (client 5.22 vs CLI 5.8)** -- Running `prisma migrate deploy` with a 14-minor-version difference will produce incompatible migration output. This would corrupt the production database on first deploy.

3. **Health-check URL mismatch** -- The CI smoke test (`/health`) and Railway probe (`/api/health`) both point to wrong path. Global prefix `api/v1` means endpoint is at `/api/v1/health`. Both would fail, blocking deployment and CI validation.

4. **No deployment automation** -- Docker image built and discarded. No push to GHCR/Docker Hub, no Railway deploy trigger, no Google Play upload. Every release requires manual steps.

5. **No dependency vulnerability scanning** -- With Stripe, Firebase Admin, AWS SDK, bcrypt, and JWT in the dependency tree, a single supply-chain vulnerability could compromise payment and auth data. No `npm audit`, no Dependabot, no Snyk.

## Top 3 Infrastructure Wins

1. **Multi-stage Docker with non-root user** -- Builder stage for compilation, production stage with only runtime deps, `USER nestjs` for privilege reduction, comprehensive `.dockerignore`.

2. **Joi environment validation at startup** -- Validates every environment variable with type checking, conditional requirements (JWT_SECRET mandatory in production), and defaults. App refuses to start with invalid config.

3. **Health-check infrastructure** -- Three-tier probes (`/health` for overall status with DB latency, `/health/live` for liveness, `/health/ready` for readiness) follow Kubernetes conventions. Docker-compose healthcheck on postgres uses `pg_isready`. Production-grade -- once URL paths corrected.

## Monorepo Improvement Plan

**Current state:** No monorepo tooling. Three independent ecosystems (npm/TypeScript API, Dart/Flutter mobile, empty `packages/shared`) with no coordination.

**Phase 1 -- Tooling (Week 1):** Install Turborepo, create `turbo.json` with pipeline definitions. Convert to pnpm workspaces.

**Phase 2 -- Shared Code (Week 1-2):** Populate `packages/shared` with TypeScript enums (Prisma), API response type interfaces, API path constants, shared validation schemas.

**Phase 3 -- CI Integration (Week 2):** Turborepo caching in CI. Scope CI jobs to changed packages only.

**Phase 4 -- Versioning (Week 3):** Adopt Changesets for semver. Auto-bump on merge to main.

## Deployment Readiness Score: 4/10

| Category | Score | Notes |
|----------|-------|-------|
| CI triggers | 0/2 | Pipeline targets wrong branches |
| Automated tests | 1/2 | Tests exist and comprehensive, but cannot run |
| Docker build | 1/1 | Multi-stage, non-root, smoke test solid |
| Registry push | 0/1 | No registry push configured |
| Deploy automation | 0/1 | No Railway/Play Store deploy from CI |
| Secrets management | 0.5/1 | GitHub Secrets for Slack only; DB passwords in defaults |
| Health checks | 0.5/1 | Endpoint exists but URL mismatch |
| Monitoring/APM | 0/1 | Pino logging but no Sentry, Crashlytics, alerting |
| Backup strategy | 0/1 | No documented backup/restore procedure |
| IaC | 0/1 | No Terraform, Pulumi, or infrastructure-as-code |

**Total: 4/10 -- Not deployable to production in current state**
