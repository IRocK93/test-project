# BabyMon Implementation Plan
**Last Updated:** 2026-04-23

## Phase 1: Backend Security & Foundation

| # | Task | Output | Status |
|---|---|---|---|
| 1 | Fix JWT secret fallback | `auth.service.ts` - fail if JWT_SECRET missing in prod | DONE |
| 2 | Create AccessControlService | `common/access-control.service.ts` + types | DONE |
| 2a | Register in BabyMonModule | Added to providers + exports | DONE |
| 2b | Wire services to use AccessControlService | milestones, evolution, feed-logs, health-records, growth | DONE |
| 3 | Add health check endpoint | `/api/health` returns API + DB status | DONE |
| 4 | Add class-validator to DTOs | All DTOs validated — already complete | DONE |
| 5 | Create audit event enum + AuditInterceptor | audit-event.enum.ts + audit.service.ts + interceptor wired | DONE |

## Phase 2: Mobile Core (Flutter)

| # | Task | Output | Status |
|---|---|---|---|
| 6 | Set up Flutter project structure | Clean Architecture folders | DONE |
| 7 | Implement Auth screens | Login + Register with Riverpod, dark theme | DONE |
| 8 | Implement Dashboard screen | Evolution viz, XP bar, badges, today's stats | DONE |
| 9 | Implement Milestones screen | List, create form, delete, category emoji | DONE |
| 10 | Implement Feeding screen | Log feeding, history list, date grouping | DONE |
| 11 | Implement Health screen | Vaccination tracker, visit history, form, list | DONE |
| 12 | Implement Journal screen | Unified feed of all events | DONE |
| 13 | Update Dashboard widgets | Real feeding/health/milestone counts from API | DONE |

## Phase 3: Backend Features

| # | Task | Output | Status |
|---|---|---|---|
| 14 | Integrate Growth module | Growth module fully wired (CRUD + AccessControl) | DONE |
| 15 | Fix badge awarding race condition | Prisma $transaction for atomic badge check | DONE |
| 16 | XP per milestone configurable | xpValue field added to Badge schema | DONE |
| 17 | Co-parent proposals | JournalProposal model + service + controller | DONE |
| 18 | Stripe webhook handler | StripeWebhookController wired to StripeModule | DONE |
| 19 | Data export | JSON + CSV export endpoints for BabyMon data | DONE |

## Phase 4: DevOps & QA

| # | Task | Output | Status |
|---|---|---|---|
| 20 | Add Flutter CI job | `ci.yml` - Flutter analyze + test | DONE |
| 21 | Set up test database in CI | PostgreSQL service + prisma migrate deploy | DONE |
| 22 | Write backend unit tests | Jest tests for key modules | PENDING |
| 23 | Deployment config | Docker prod + deploy docs | PENDING |

---

## Phase 5: App Completion (NEW)

| # | Task | Blocker | Status |
|---|---|---|---|
| 24 | Fix API constants mismatch | `constants.dart` duplicates `api_constants.dart` (line 8-25 vs line 10-46). Auth interceptor uses wrong constant path (`lib/core/constants/constants.dart` vs `lib/core/constants/api_constants.dart`). Auth controller guards missing `@Public()` on 4 endpoints (lines 66, 74, 33-40, 51-57) — `@UseGuards(JwtAuthGuard)` before `@Public()` is ineffective. | 🔴 BLOCKED |
| 25 | Add missing pubspec dependencies | intl, uuid, provider_annotations missing from `pubspec.yaml`. HTTP interceptor needs `dio` package. | 🔴 BLOCKED |
| 26 | Wire main app shell properly | SplashScreen → Login flow with auth state. Need to connect auth provider to app lifecycle. | 🔴 BLOCKED |
| 27 | Add all missing screen widgets | Journal, Milestones, Feeding screens need full implementation. | 🔴 BLOCKED |
| 28 | Create Flutter unit tests | Repository + Provider tests for CI validation. | 🔴 BLOCKED |
| 29 | Add Flutter integration test | End-to-end login → dashboard smoke test. | 🔲 TODO |

---

## Tooling & Environment Requirements (PROPOSAL)

### Installed
- **Node.js v22** — Backend runtime
- **npm** — Dependency management
- **Git** — Version control
- **Python3** — System tools
- **Flutter SDK (partial)** — SDK binaries present, not fully configured

### Missing Tools
| Tool | Dependency For | Install Command |
|---|---|---|
| Java JDK 21 | Flutter Android builds | `apt install openjdk-21-jdk` |
| Android SDK cmdline tools | Flutter Android builds | `sdkmanager --install cmdline-tools` |
| Android emulator | Mobile testing | `sdkmanager --install emulator` |
| adb | Device communication | `apt install adb` |
| Android Studio | Full IDE with UI/designer | Download from developer.android.com/studio |

### Recommended Setup Order
1. **Quick Setup (Recommended)** - Java 21 + Android SDK cmdline tools + emulator (~5 min)
2. **Full IDE (Optional)** - Android Studio with all SDK components (~15 min)
3. **Physical device** - Connect Android device via USB, install just Java + adb

---

## Summary

**Completed:** 19/23 core tasks (83%)
**New issues identified:**
1. Backend auth guard ordering bug in auth.controller.ts — `@Public()` must come after `@UseGuards(JwtAuthGuard)` in NestJS
2. Mobile app code conflicts (API constants, missing dependencies)
3. Rate limits on LLM provider preventing subagent work

**Remaining Effort:**
- Backend: Unit tests (Task 22)
- Mobile: Code completion + fixes (Tasks 24-28)
- DevOps: Docker + CI/CD (Task 23)
- Tooling: Android SDK setup (pending proposal approval)

---

## Where We Are

- **Backend:** Running at localhost:3000, healthy ✅
- **Database:** babymon-db Healthy ✅
- **API Docs:** /api/docs ✅
- **Health:** /api/health ✅
- **Mobile:** Code scaffold exists but has compilation-blocking issues 🔴

---

## Next Steps

1. **Fix mobile build blockers** (Tasks 24-25) - Consolidate constants files (pick one, remove duplicate), add pubspec deps
2. **Fix backend auth guard ordering** - Move `@Public()` decorator after `@UseGuards(JwtAuthGuard)` in auth.controller.ts (lines 66-67, 74-75) — NestJS requires `@Public()` to be last or use separate route groups
3. **Complete mobile screens** (Tasks 26-27) - Wire main app shell, create missing screens
4. **Write Flutter unit tests** (Task 28) - Ensure CI validation works when tools installed
5. **Write backend unit tests** (Task 22) - Once rate limits clear
6. **Create deployment config** (Task 23) - Docker + docs + CI/CD
7. **Android tooling** (pending proposal) - Verify mobile app can build and run
