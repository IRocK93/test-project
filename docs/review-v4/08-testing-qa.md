# BabyMon Testing & QA Audit — v4

**Date:** 2026-06-22
**Overall Grade: D+**

---

## Score Breakdown

| Area | Grade | Summary |
|------|-------|---------|
| Backend Testing | D- | 10 of 29 modules tested; zero e2e tests; no coverage thresholds |
| Mobile Testing | B- | 61+ test files; excellent golden test coverage |
| CI/CD Pipeline | C+ | Well-structured parallel jobs; missing coverage gates |
| Test Strategy | D | No test pyramid balance; critical paths largely untested |

---

## 1. Backend Testing

### Coverage: 10/29 modules tested, 19 with zero tests

**Tested modules (decent quality):**
- `linked-accounts` — 15 tests (gold standard, full lifecycle)
- `xp` — 15 tests (pure functions + level-up logic)
- `subscriptions` — 8 tests (tier-state matrix)
- `badges` — 6 tests (award/duplicate/edge logic)
- `access-control` — 7 tests
- `global-exception-filter` — 9 tests
- `audit.interceptor` — 6 tests
- Plus basic coverage in auth, users, baby-mon, health, stripe (mostly placeholder)

**Untested modules (zero coverage):**
`admin`, `allergies`, `audit.service`, `companion`, `evolution`, `export`, `feed-logs`, `growth`, `health-records`, `journal`, `journal-proposals`, `mail`, `media`, `medical-team`, `milestones`, `notifications`, `prisma`, `s3`, `sleep-logs`, `stage-content`

### Critical Issues
- `stripe.service.spec.ts` includes `expect(true).toBe(true)` — no-op placeholder
- CI calls `npm run test:ci` but package.json has no such script
- Zero integration tests with real database
- Zero e2e tests despite `jest-e2e.json` config existing
- No coverage thresholds configured

---

## 2. Mobile Testing

### Coverage: ~61 test files

| Category | Count | Quality |
|----------|-------|---------|
| Unit tests | ~20 | Good to Excellent |
| Widget tests | ~12 | Decent |
| Integration/screen tests | ~16 | Moderate (mostly smoke) |
| Golden tests | ~8 | Excellent (112 test cases) |
| Flow integration tests | ~2 | Good |
| E2E tests | 1 | Basic (6 test cases) |

### Highlights
- `auth_provider_test.dart` — strongest test file in the entire project (full AuthNotifier lifecycle, configurable fakes, 3 social login providers)
- Golden tests cover 17 screen types across 4 theme combinations
- Business logic tests cover XP calculation, date grouping, cooldown logic
- CI uploads golden failure diffs as artifacts

### Gaps
- No interaction tests for Settings, Subscription, Milestones, Health, Sleep, Growth, Album, Partners screens
- No offline/network error tests
- No rapid double-tap tests
- `integration_test/app_test.dart` only has 6 cases, no CRUD operations

---

## 3. CI Pipeline Issues

| # | Issue | Severity |
|---|-------|----------|
| 1 | CI triggers on `main`/`develop` but repo uses `master` — pipeline NEVER runs | CRITICAL |
| 2 | `npm run test:ci` called but script doesn't exist in package.json | CRITICAL |
| 3 | Lint failures suppressed with `|| true` | HIGH |
| 4 | No coverage collection or thresholds | HIGH |
| 5 | No Flutter build verification (`flutter build apk` never tested) | HIGH |
| 6 | No mobile integration_test execution in CI | HIGH |
| 7 | `expect(true).toBe(true)` placeholder assertion | HIGH |

---

## 4. Critical Path Coverage

| Path | Backend Tests | Mobile Tests | Risk |
|------|--------------|--------------|------|
| User registration | None | Widget | HIGH |
| Email/password login | Minimal | Widget + integration | HIGH |
| Social login | None | Unit (provider only) | HIGH |
| Token refresh | None | None | HIGH |
| Create BabyMon | None | Integration (nav only) | HIGH |
| Milestones CRUD | None | Integration (render only) | HIGH |
| Feed logs CRUD | None | Integration (render only) | HIGH |
| Journal proposals | None | None | HIGH |
| Stripe webhooks | Placeholder | N/A | HIGH |
| Media/S3 uploads | None | None | HIGH |
| Subscriptions | Good | Integration (render only) | LOW |
| Badges | Good | Integration (render only) | LOW |
| XP/Leveling | Good | Unit (business logic) | LOW |
| Linked accounts | Excellent | Integration (render) | LOW |

---

## 5. Top 10 Missing Tests

1. `milestones.service.spec.ts` — CRUD for core domain entity
2. `feed-logs.service.spec.ts` — CRUD + validation
3. `auth.service.e2e-spec.ts` — Full auth flow against real PostgreSQL
4. `journal-proposals.service.spec.ts` — Proposal lifecycle
5. `stripe.webhook.e2e-spec.ts` — Webhook handling with mocked signatures
6. `baby-mon.service.spec.ts` (expanded) — CRUD + stage edge cases
7. `s3.service.spec.ts` — File upload success/failure/validation
8. `mail.service.spec.ts` — Template rendering + SendGrid integration
9. `create_baby_mon_flow_test.dart` — Full Flutter Create BabyMon flow
10. `subscription_flow_test.dart` — Purchase flow with mocked Stripe

---

## 6. Quick Wins

1. Fix `test:ci` script: add `"test:ci": "jest --ci --forceExit --coverage"` to package.json
2. Remove `expect(true).toBe(true)` from stripe.service.spec.ts
3. Make lint blocking: remove `|| true` from CI
4. Add coverage thresholds: start at 30% branches, 40% lines
5. Write `milestones.service.spec.ts` — most business-critical untested module
