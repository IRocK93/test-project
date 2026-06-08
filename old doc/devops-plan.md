# BabyMon DevOps Plan

## Current State Assessment

### Docker Compose ✅ (Partial)
- Postgres 16-alpine with health check ✅
- Separate test database ✅
- Named volume for persistence ✅
- **MISSING:** No backend service defined (only DB)
- **MISSING:** No `babymon-network` (backend and DB should share a network)
- **MISSING:** No `.env` file management (no env_file directive)

### CI/CD Pipeline ✅ (Incomplete)
- Node 20 + npm cache ✅
- Lint, typecheck, Prisma generate, tests, build ✅
- Docker image build + smoke test ✅
- **MISSING:** No Flutter mobile build
- **MISSING:** No iOS/Android deployment (certificates, signing)
- **MISSING:** No E2E tests in CI
- **MISSING:** No Dependabot for dependency updates
- **MISSING:** No secrets scanning (no gitleaks/trufflehog)

### Backend Scripts ✅ (Good)
- All essential scripts present: build, start:dev, test, lint, typecheck, prisma:*

---

## Issues to Fix

### 1. Docker Compose — Add Backend Service

The backend service is not defined. Add:

```yaml
services:
  postgres:
    # ... existing config ...

  backend:
    build:
      context: ./apps/api
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://babymon:babymon_dev_password@postgres:5432/babymon
      JWT_SECRET: ${JWT_SECRET}
      NODE_ENV: development
    env_file:
      - apps/api/.env
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - babymon-network

  postgres-test:
    # ... existing config ...

networks:
  babymon-network:
    driver: bridge
```

### 2. Backend — Add `start:dev` Database Migration

Add `prisma:migrate` to `start:dev` so the backend auto-migrates on startup:

```json
"start:dev": "npx prisma migrate dev && nest start --watch"
```

### 3. CI — Add Flutter Mobile Build

After `docker-build` job, add:

```yaml
  flutter-build:
    runs-on: ubuntu-latest
    needs: [lint-and-test]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      - run: flutter pub get
        working-directory: ./apps/mobile
      - run: flutter analyze --no-pub
        working-directory: ./apps/mobile
      - run: flutter test
        working-directory: ./apps/mobile
      - run: flutter build apk --debug
        working-directory: ./apps/mobile
```

### 4. CI — Add Dependabot

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/apps/api"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 5. CI — Add Secrets Scanning

```yaml
- name: Run Gitleaks
  uses: gitleaks/gitleaks-action@v2
```

### 6. Mobile — Add pubspec.yaml scripts

Add Flutter-specific scripts to root `package.json` or a `Makefile`:

```
flutter-test:
  cd apps/mobile && flutter test
flutter-analyze:
  cd apps/mobile && flutter analyze
```

---

## Deployment Strategy

### Recommended: Railway + Static +托管

| Component | Deployment | Notes |
|-----------|-----------|-------|
| Backend | Railway | Easy Node.js deployment, Postgres add-on, auto-deploy from GitHub |
| Database | Railway Postgres | Managed PostgreSQL |
| Mobile | TestFlight (iOS) / Play Console (Android) | Manual signing + Fastlane |
| Static Assets | S3/Cloudflare R2 | For media uploads |

### Alternative: Fly.io
- All-in-one: backend + Postgres
- Good free tier

### NOT Recommended for MVP
- AWS ECS/EKS (overkill)
- DigitalOcean App Platform (limited NestJS support)

### Environment Strategy

Create `.env.example` in `apps/api/`:

```
DATABASE_URL=postgresql://babymon:babymon_dev_password@localhost:5432/babymon
JWT_SECRET=change-me-in-production
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d
SENDGRID_API_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=
AWS_REGION=us-east-1
FRONTEND_URL=http://localhost:5173
```

---

## Priority Fixes (in order)

1. **[Backend]** Fix Docker Compose to include backend service
2. **[Backend]** Add `env_file` and network to Docker Compose
3. **[CI]** Add Flutter build job
4. **[CI]** Add Dependabot
5. **[CI]** Add secrets scanning
6. **[CI]** Add E2E tests (Playwright) after Flutter build

---

## Consultation Notes

For the DevOps agent: This plan is ready for execution. The programmer should handle fixes #1-2 (Docker Compose). DevOps handles #3-6 when the mobile app is further along.

Questions that need user input:
1. **Deployment target** — Where should this deploy? (Railway, Fly.io, AWS, other?)
2. **Mobile distribution** — How should the app be distributed? (TestFlight/Play Store for release, but what about internal testing?)
3. **Domain/hosting** — Do you have a domain? Should I set up a subdomain for the API?
