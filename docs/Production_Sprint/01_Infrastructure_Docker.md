# Issue 1-4: Infrastructure & Docker

**Date:** 2026-06-23 | **Priority:** CRITICAL/HIGH

---

## Issue 1: Postgres Port 5432 Exposed to 0.0.0.0

**File:** `docker-compose.yml`, lines 9-10

```yaml
ports:
  - "5432:5432"
```

**Risk:** HIGH — Database reachable from all network interfaces with a weak default password (`babymon_dev_password`) committed to source control.

**Is the port mapping needed?** No. The backend connects via internal Docker network using hostname `postgres`. External access is only for dev tooling.

**Fix:**
```yaml
ports:
  - "127.0.0.1:5432:5432"   # bind to localhost only
```
Same for test DB (line 48): `"127.0.0.1:5433:5432"`

---

## Issue 2: Docker CMD Path Wrong

**File:** `apps/api/Dockerfile`, line 44

```dockerfile
CMD ["node", "dist/src/main"]    # WRONG
```

**Risk:** CRITICAL — Container crashes on startup. `tsconfig.json` has `"outDir": "./dist"` with inferred rootDir `src/`, so `src/main.ts` compiles to `dist/main.js`, NOT `dist/src/main.js`. The app's own `package.json` uses `"start:prod": "node dist/main"`.

**Fix:**
```dockerfile
CMD ["node", "dist/main"]
```

---

## Issue 3: NODE_ENV Hardcoded to development

**File:** `docker-compose.yml`, line 30

```yaml
environment:
  NODE_ENV: development    # hardcoded, overrides .env
```

**Risk:** HIGH — Even if `.env` sets `NODE_ENV=production`, Docker Compose's `environment` takes precedence. Production deployment runs with dev security posture (relaxed Helmet, no JWT secret enforcement, stack traces leaked).

**Fix:**
```yaml
environment:
  NODE_ENV: ${NODE_ENV:-development}
```

---

## Issue 4: dev-secret-change-me Placeholder

**File:** `apps/api/src/config/configuration.ts`, line 78

```typescript
fallbackDevSecret: process.env.JWT_DEV_SECRET || 'dev-secret-change-me',
```

**Risk:** LOW (dead code). `fallbackDevSecret` is defined in `AppConfig` and the factory but **never consumed** by any service. The actual JWT secret comes from `getJwtSecret()` in `jwt-config.ts`. However, it creates confusion and a false sense that a fallback secret exists.

**Fix:** Remove `fallbackDevSecret` from both the `AppConfig` interface and the `configuration()` factory.
