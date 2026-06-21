# S09 — Testing & QA Audit

**Date:** 2026-06-18 | **Overall Grade:** Backend D / Mobile B+

---

## Backend: SEVERE DEFICIENCY

| Metric | Value |
|---|---|
| Total modules | 28 |
| Modules with tests | 4 (14.3%) |
| Total spec files | 4 |
| Total test cases | 12 |
| Working e2e config | No (config file missing) |

### Specs Found (all shallow)
- `users.service.spec.ts` — 3 tests (getProfile, getUserById only)
- `baby-mon.service.spec.ts` — 3 tests (findAll, calculateCurrentStage only)
- `auth.service.spec.ts` — 3 tests (validateUser only — the least critical method)
- `health.controller.spec.ts` — 3 tests (check, live, ready)

### Critical Untested Paths
**P0:** AccessControlService (0 tests — correlates with 4 IDOR bugs), Stripe webhook (0 tests — billing integrity), BadgesService (0 tests — transaction race conditions), AuthService (0 tests for register/login/refresh/verify/reset — only validateUser tested)
**P1:** Journal proposals approve/reject, TierGuard, SubscriptionsService lifecycle
**P2:** Error handling, exception filter (doesn't exist)

---

## Mobile: MODERATELY STRONG

| Metric | Value |
|---|---|
| Total test files | 62 |
| Unit tests | ~19 files |
| Integration tests | ~16 files |
| Golden tests | ~12 files |
| Widget tests | ~11 files |

### Strengths
- `auth_provider_test.dart` — excellent FakeAuthRepository with error injection and call recording (30+ tests)
- Golden tests cover all 20+ screens at 4 theme combinations + error states + semantics
- Strong error handling unit tests (all DioException types)
- 7 distinct mock implementations (fragmented but comprehensive)

### Weaknesses
- Most "integration" tests are smoke tests (assert `findsWidgets` on Scaffold)
- No true multi-layer integration tests (providers → API → UI)
- No e2e/real-device tests
- No offline/recovery tests
- Companion feature: 0 tests

---

## Findings

### TQ-C01 | 🔴 CRITICAL | AccessControlService — 0% Test Coverage (4 IDOR Bugs Undetected)
### TQ-C02 | 🔴 CRITICAL | test:e2e Script Broken — Config File Missing
### TQ-C03 | 🔴 CRITICAL | AuthService — Only validateUser Tested; Register/Login/Refresh/Verify All Untested
### TQ-H01 | 🟠 HIGH | Stripe Webhook — 0 Tests on Billing Integrity
### TQ-H02 | 🟠 HIGH | BadgesService — 0 Tests on Transaction Race Conditions
### TQ-H03 | 🟠 HIGH | Companion Pipeline — 0 Tests on 20+ Source Files
### TQ-M01 | 🟡 MEDIUM | Mobile "Integration" Tests Are Mostly Smoke Tests
### TQ-M02 | 🟡 MEDIUM | 7 Mock Implementations — Fragmented, No Shared Test Package
### TQ-M03 | 🟡 MEDIUM | No CI Coverage Reporting

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 3 |
| 🟠 High | 3 |
| 🟡 Medium | 3 |
| **Total** | **9** |
