# 09 — Testing & QA Audit

**Date:** 2026-06-17
**Severity Score:** 🔴 Critical (3 Critical, 5 High, 4 Medium, 3 Low)
**Verdict:** Severely inverted test pyramid. 212 golden PNGs but 0 tests for the authorization gate or Stripe webhook.

---

## Summary

BabyMon's testing landscape is **severely inverted**. The Flutter mobile app has 60+ test files, comprehensive domain entity tests, a strong stub/helper infrastructure, and 212 golden PNG screenshots — but the NestJS backend has only **4 spec files across 27 modules** (14.8%). **23 modules are completely untested**, including the central `AccessControlService` (the authorization gate), the entire Stripe billing module (webhook handler + checkout), all badge/XP logic, and refresh-token rotation. The `test:e2e` script points at a nonexistent directory. Mobile integration tests are smoke-only ("renders without error", no business logic assertions). The three IDOR bugs confirmed by the Security audit (`milestones.create`, `feed-logs.create`, `health-records.verifyAccess`) have zero tests catching them. The golden test suite (212 PNGs) is a maintenance burden — any UI change breaks dozens of images.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| T01 | 🔴 Critical | **IDOR in `milestones.create` — untested** | `milestones.service.ts:17-39` | `create()` checks BabyMon exists but never calls `verifyAccess()`. `findAll()` does call `verifyAccess`. No test catches the missing check. | Add `verifyAccess()` call at start of `create()`. Write test: unauthorized user → 403. |
| T02 | 🔴 Critical | **IDOR in `feed-logs.create` — untested** | `feed-logs.service.ts:17-39` | Identical pattern: existence check only. No `verifyAccess`. No test. | Same fix + test as T01. |
| T03 | 🔴 Critical | **`AccessControlService` — completely untested** | `src/common/access-control.service.ts` | Central authorization gate. Zero tests. Not a single spec verifies: owner gets EDIT, linked co-parent gets VIEW/EDIT, unauthorized gets denied. | Write comprehensive spec for all three access paths + edge cases. |
| T04 | 🟠 High | **Stripe webhook handler — untested** | `src/stripe/stripe-webhook.controller.ts` | Billing integrity depends on this. No tests for signature validation, raw body access, error handling. The handler is a stub that acknowledges webhooks without processing events. | Write spec for webhook signature verification, event dispatch, and error cases. |
| T05 | 🟠 High | **Refresh-token rotation — untested** | `src/auth/auth.service.ts:140-195` | `refreshTokens()`: validates JWT type, checks user, revokes old, issues new pair. Spec only tests `validateUser`. Entire rotation logic untested. | Expand auth spec to cover refresh flow, token revocation, expiry handling. |
| T06 | 🟠 High | **Badge awarding — completely untested** | `src/badges/badges.service.ts` | 30 badge definitions, complex awarding criteria. No tests. Also, `BADGE_DEFINITIONS` table (86 lines) is dead code — award logic hardcoded separately. | Write spec verifying badge triggers with known data. Unify award logic with definitions table. |
| T07 | 🟠 High | **XP service — untested on backend** | `src/xp/xp.service.ts` | `xpForNextLevel()`, `checkAndProcessLevelUp()` untested. Mobile `business_logic_test.dart` tests XP calculation but backend logic is independent. | Write spec for XP thresholds, level-up processing, edge cases. |
| T08 | 🟠 High | **E2E test infrastructure nonexistent** | `apps/api/package.json:13` | `"test:e2e": "jest --config ./test/jest-e2e.json"` — `./test/` directory does not exist. Script fails immediately. | Create `test/` directory with `jest-e2e.json` and a basic health check + auth flow e2e test. |
| T09 | 🟡 Medium | **No jest coverage thresholds** | `apps/api/jest.config.js` | No `coverageThreshold` configured. No enforcement. | Add `coverageThreshold: { statements: 50, branches: 40, functions: 50, lines: 50 }` and ratchet up. |
| T10 | 🟡 Medium | **No Flutter coverage configuration** | `apps/mobile/pubspec.yaml` | No `flutter test --coverage` script. No lcov. No thresholds. | Add coverage script + thresholds. |
| T11 | 🟡 Medium | **Subscription tier gating — untested** | `src/subscriptions/` | No spec file. No tests verify tier-based feature restrictions. | Write spec for `checkWriteAccess` with expired trial, CORE vs AI_COMPANION features. |
| T12 | 🟡 Medium | **Cascade delete behavior — untested** | `baby-mon.service.ts:148-167` | No service-level tests verify cascade deletes work (DB-level cascade exists, but application logic around it is untested). | Write integration test verifying deleting a BabyMon cascades to child records. |
| T13 | 🔵 Low | **212 golden PNGs — maintenance burden** | `test/golden/goldens/` | 80 screen test cases × 4 themes + component/state/error goldens. Any UI visual change requires regenerating up to 212 PNGs. | Consider testing only one theme (dark glass) at golden level. Use widget tests for other themes. |
| T14 | 🔵 Low | **16 screen integration tests are smoke-only** | `test/integration/*_screen_test.dart` | Every test: `pumpWidget()`, `pump()`, `expect(find.byType(Scaffold), findsWidgets)`. No business logic assertions. | Add assertions for: data displayed from stub API, state transitions, loading/error states. |
| T15 | 🔵 Low | **Backend specs test only 6 methods across 4 services** | 4 spec files in `src/` | ~6 tested methods out of ~100+ total. Auth spec tests only `validateUser`. Baby-mon spec tests only `findAll` + `calculateCurrentStage`. | Expand existing specs to cover create, update, delete, error paths. |

---

## Coverage Map

### Backend — 27 modules, 4 with specs (14.8%)

```
✅ auth*        (only validateUser tested)
✅ baby-mon*    (only findAll + calculateCurrentStage)
✅ health       (3/3 endpoints)
✅ users*       (only getProfile + getUserById)
❌ admin, allergies, badges, common, evolution, export, feed-logs,
   growth, health-records, journal, linked-accounts, mail, media,
   medical-team, milestones, notifications, prisma, s3, sleep-logs,
   stage-content, stripe, subscriptions, xp
```

### Mobile — strong but inverted
```
Golden tests:    212 PNGs, 7 test files, 12 screens
Integration:     16 screen tests (smoke-only)
Unit tests:      17 files (entity, provider, biz logic, utils)
E2E:             0 (no integration_test/ directory)
```

---

## Things Done Well

1. **Mobile domain entity tests** (`domain_entities_test.dart`) — Comprehensive. 1222 lines. Every entity with `fromJson`/`toJson` round-trips, computed properties, edge cases (nulls, non-numeric values). Gold standard.
2. **Business logic unit tests** (`business_logic_test.dart`) — Good isolation of pure functions. XP progress, cooldown, journal grouping with edge cases. Right pattern.
3. **Auth provider tests** (`auth_provider_test.dart`) — Well-structured `FakeAuthRepository` pattern. Covers social login flows with success and cancellation paths. Tests `isLoading` state transitions.
4. **Test helper infrastructure** — `StubApiClient`, `TestApiClient`, `FakeAuthNotifier`, `goldenApp()`, platform mocks. Building blocks for meaningful tests exist.
5. **Theme migration test** (`theme_providers_test.dart`) — Tests old→new preference key migration. Awareness of backward compatibility testing.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | **FIX IDOR BUGS** then write regression tests. | S |
| 2 | Write `AccessControlService` spec — owner, linked VIEW/EDIT, denied. | S |
| 3 | Expand `auth.service.spec.ts` — register, login, refresh rotation, logout, password reset. | M |
| 4 | Write `stripe-webhook.controller.spec.ts` — signature validation, raw body, error handling. | M |
| 5 | Write `badges.service.spec.ts` — test badge triggers with known data. | M |
| 6 | Write `xp.service.spec.ts` — thresholds, level-up processing. | M |
| 7 | Create `test/` directory + `jest-e2e.json` + basic e2e smoke test (health → register → login). | M |
| 8 | Add jest coverage thresholds. | S |
| 9 | Elevate mobile integration tests: add business logic assertions. | L |
| 10 | Add `integration_test/` directory with device-level tests (login flow, create BabyMon). | L |
| 11 | Add Flutter coverage (`flutter test --coverage` + lcov). | M |
| 12 | Reduce golden tests: keep dark glass only, test other themes via widget tests. | M |
| 13 | Write service-level specs for remaining 18 untested modules (prioritize: subscriptions, journal, sleep-logs, growth). | L |
