# BabyMon Consultant Recommendations

**Date:** April 23, 2026
**Author:** Consultant Subagent

---

## 1. SEQUENCE: Optimal Implementation Order

### Recommendation: **Hybrid Approach — Sequential Foundation, Then Parallel**

**Phase 1: Fix Foundation (Sequential)**
Fix Docker Compose + backend security FIRST. This is not optional — it's a prerequisite for everything else.

**Phase 2: Parallelize (Backend + Mobile simultaneously)**
Once the foundation is stable, backend features and mobile scaffold can run in parallel — they touch different codebases.

**Phase 3: Integration + Polish**
Connect mobile to backend, add offline sync, run E2E tests.

### Rationale:
- Backend at 60-70% means it's close but not shippable yet — security issues could derail everything
- Mobile is bare scaffolding — significant setup work can happen independently
- Docker Compose fix takes ~1 hour and unblocks local development for all agents

---

## 2. PARALLELIZATION: Concrete Execution Order

### Bucket 1: Foundation (MUST be sequential)
| Task | Owner | Reason |
|------|-------|--------|
| Fix docker-compose.yml (add backend service, network, env_file) | Programmer | Prerequisite for local dev |
| Fix JWT secret fallback (auth.service.ts) | Programmer | Security blocker |
| Add backend health check endpoint | Programmer | Required for container orchestration |

### Bucket 2: Parallel Work — Backend Features + Mobile Scaffold
| Backend Tasks | Mobile Tasks |
|---------------|---------------|
| Fix duplicated AccessControl → shared AccessControlService | Set up Clean Architecture folder structure |
| Fix AuditLog interceptor → actually write to table | Build API client with Dio + interceptors |
| Complete remaining backend features (subscriptions stub, stage-content) | Set up Riverpod providers (auth, babyMon, milestones) |
| Add input validation DTOs (class-validator decorators) | Define local DB schema (Drift tables) |
| Fix race condition in badge awarding (transactions) | Build static UI screens (onboarding, dashboard skeleton) |

### Bucket 3: Integration (Sequential, after Bucket 2)
| Task | Owner |
|------|-------|
| Connect mobile to backend API | Mobile-dev |
| Implement offline sync queue | Mobile-dev |
| E2E tests with Playwright | Programmer |
| Add Flutter CI job | DevOps |

### Execution Order:
```
1. [Programmer] Fix docker-compose.yml
2. [Programmer] Fix JWT secret fallback
3. [Programmer] Add health check endpoint
         ↓
4. [PARALLEL]
   - [Programmer] Backend security fixes (AccessControl, AuditLog)
   - [Mobile-dev] Mobile Clean Architecture setup
         ↓
5. [PARALLEL]
   - [Programmer] Backend feature completion
   - [Mobile-dev] Mobile providers + API client
         ↓
6. [Mobile-dev] Mobile UI screens
7. [Mobile-dev] Offline sync implementation
8. [Programmer] E2E tests
```

---

## 3. CRITICAL PATH: Tasks That Block Everything

### Top 5 Blockers (delay these = delay all subsequent work):

**1. Docker Compose Backend Service Definition**
- Without this, backend cannot run via `docker-compose up`
- All local development and testing is blocked
- Fix: Add `backend` service with Dockerfile, ports, env_file, network

**2. JWT Secret Fallback Fix**
- Security vulnerability — if JWT_SECRET env var is missing in production, app silently uses a hardcoded fallback
- Attack vector: extract tokens signed with known secret
- Fix: Throw error in production if JWT_SECRET is missing

**3. Backend Health Check Endpoint**
- Docker smoke test `curl http://localhost:3001/health` will fail without this
- Container orchestration (ECS, Railway, K8s) requires health checks for load balancing
- Fix: Add `/health` endpoint returning `{ status: 'ok' }`

**4. Mobile API Client (Dio + Interceptors)**
- Mobile cannot communicate with backend without this
- All mobile features depend on API connectivity
- Fix: Implement `DioClient` with auth interceptor, retry logic, token refresh

**5. Mobile Authentication State Management**
- All write operations require valid JWT
- If auth state is broken, the entire app is non-functional
- Fix: Implement `authProvider` with login/logout/refresh-token logic

### What Unlocks the Most Subsequent Work:
**Docker Compose fix** unlocks everything — it's the gateway to local dev, testing, and deployment.

---

## 4. TECHNICAL DEBT: Fix Before or After MVP?

### Decision: **Fix BEFORE continuing — critical issues only**

| Issue | Fix Before MVP? | Reason |
|-------|-----------------|--------|
| JWT secret fallback | **YES** | Production security vulnerability. Could be exploited before launch. |
| AuditLog not writing | **YES** | Compliance/tracking requirement. If users demand audit trails, you can't add retroactively. |
| Duplicated AccessControl | **DEFER** | Maintenance issue, not a blocker. Can refactor post-MVP. |
| XP hardcoded in service | **DEFER** | Feature flexibility issue. Works for MVP, refactor later. |
| Race condition in badges | **DEFER** | Low probability of occurrence. Add transactions post-MVP if needed. |
| Missing input validation | **YES** | Security issue. DTOs should validate before hitting database. |

### Principle:
- **Security and functional correctness → Fix NOW**
- **Code quality and maintainability → Defer to post-MVP**
- **"It works" features → Defer to post-MVP**

---

## 5. MOBILE vs BACKEND: High-Value Work Without Completed Backend

### What Mobile Can Do NOW (no backend required):

| Task | Value | Notes |
|------|-------|-------|
| **Clean Architecture folder structure** | High | Foundation for all future work. Defines domain/data/presentation separation. |
| **Drift local database schema** | High | Define tables for milestones, feed_logs, health_records, sync_queue. Works offline. |
| **Dio API client with interceptors** | High | Can point to mock server or local backend once Docker is ready. |
| **Riverpod providers (auth, babyMon)** | High | State management foundation. Can mock data for UI development. |
| **Static UI screens (onboarding, settings)** | Medium | Screens that don't require API. Can be built with placeholder data. |
| **Dashboard UI skeleton** | Medium | Build the visual structure (XP bar, badges, stage visualization) with mock data. |
| **Bottom navigation + routing** | Medium | App shell is always needed regardless of backend state. |

### What Mobile Should WAIT On:
- Real API integration (depends on backend endpoints being stable)
- Offline sync (depends on local DB schema being defined)
- E2E tests (depends on backend being runnable)

---

## 6. BEST NEXT MOVE

### Single Next Action:

**[Programmer] Fix docker-compose.yml to add backend service**

```
File: /mnt/d/Claude Workspace/Projects/00. Test Project/docker-compose.yml

Changes needed:
1. Add backend service with:
   - build: ./apps/api
   - ports: "3000:3000"
   - environment: DATABASE_URL, JWT_SECRET, NODE_ENV
   - env_file: apps/api/.env (create if missing)
   - depends_on: postgres (condition: service_healthy)
   - restart: unless-stopped
   - networks: babymon-network

2. Add babymon-network driver: bridge

3. Ensure postgres service is on babymon-network
```

This is a ~1-hour fix that unblocks everything: local dev, testing, and CI smoke tests.

### Next 3 Actions After That:

**Action 2: [Programmer] Fix JWT secret fallback in auth.service.ts**

```typescript
// In auth.service.ts, replace the dangerous fallback:
const safeJwtSecret = jwtSecret || 'babymon-jwt-secret-do-not-use-in-production';

// With:
if (!jwtSecret && process.env.NODE_ENV === 'production') {
  throw new Error('JWT_SECRET environment variable is required in production');
}
const safeJwtSecret = jwtSecret || 'dev-only-secret';
```

**Action 3: [Mobile-dev] Set up Mobile Clean Architecture folder structure**

Create the directory structure:
```
apps/mobile/lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── providers/
    ├── screens/
    ├── widgets/
    └── router/
```

**Action 4: [Programmer] Add backend health check endpoint**

```typescript
// In src/main.ts or a health controller:
@Get('health')
getHealth() {
  return { status: 'ok', timestamp: new Date().toISOString() };
}
```

Then update CI smoke test to verify this endpoint passes.

---

## Summary Table

| Priority | Task | Owner | Blocks |
|----------|------|-------|--------|
| 1 | Fix docker-compose.yml | Programmer | Everything |
| 2 | Fix JWT secret fallback | Programmer | Security |
| 3 | Health check endpoint | Programmer | CI/Deploy |
| 4 | Mobile CA structure | Mobile-dev | Mobile dev |
| 5 | Mobile API client | Mobile-dev | Integration |
| 6 | Backend features | Programmer | Feature parity |
| 7 | Offline sync | Mobile-dev | Offline MVP |

---

## Recommendation: Don't Wait for Perfection

**Ship timeline insight:** With this plan, you can have a runnable MVP in 2-3 weeks:
- Week 1: Fix foundation (Docker, JWT) + Mobile structure
- Week 2: Backend features + Mobile API integration
- Week 3: Offline sync + E2E tests + polish

The 60-70% backend completion is close — focus on stabilizing what exists before adding new features.
