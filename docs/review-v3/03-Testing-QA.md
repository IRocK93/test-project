# Testing & QA Audit Report

## Backend Grade: D+ | Mobile Grade: B

## Summary

Backend testing has improved from 4 specs (v1 audit) to 6 specs covering 6 of 28 modules (21.4%) -- a marginal gain. The 22 untested modules include the entire authorization gate (AccessControlService), billing pipeline (Stripe), gamification engine (Badges/XP), and all 8 tracking services. Mobile testing is significantly healthier with ~66 test files spanning golden (visual regression), widget, unit, and integration categories, backed by a reasonable mock infrastructure. However, CI is completely disabled on push due to a branch-name mismatch (`main` in workflow vs `master` in git), zero coverage gates exist on either platform, and the `update-goldens` job will never fire. The testing posture is passable for pre-production demos but inadequate for a system handling children's health data and payment processing.

---

## Backend Test Coverage Analysis

| # | Module | Tested? | Test Count | Quality Assessment |
|---|---|---|---|---|
| 1 | auth | YES | 3 | Subpar -- only `validateUser` tested; register, login, refresh, reset-password, delete-account absent |
| 2 | baby-mon | YES | 3 | Basic -- `findAll` and `calculateCurrentStage` tested; create, update, delete, findByUser not covered |
| 3 | users | YES | 3 | Minimal -- `getProfile` and `getUserById` tested; updateProfile, deleteAccount, changePassword absent |
| 4 | health | YES | 3 | Adequate -- `/health`, `/live`, `/ready` probes verified |
| 5 | audit.interceptor | YES | 6 | Good -- 6 tests covering event routing, anonymous skip, GET exclusion, edge cases |
| 6 | global-exception.filter | YES | 9 | Strong -- covers HttpException, Prisma errors, null handling, response shape |
| 7 | access-control | NO | 0 | **CRITICAL GAP** -- the authorization gate for all entity operations |
| 8 | stripe | NO | 0 | **CRITICAL GAP** -- webhook handling, payment intents, subscription lifecycle |
| 9 | badges | NO | 0 | **CRITICAL GAP** -- badge definitions, awarding logic, milestone checks |
| 10 | xp | NO | 0 | **CRITICAL GAP** -- XP calculation and level progression |
| 11 | subscriptions | NO | 0 | Stripe checkout/portal session creation, tier management |
| 12 | journal | NO | 0 | Journal CRUD, proposal logic, linked-account access |
| 13 | milestones | NO | 0 | IDOR was in this module (v1 finding), still untested |
| 14 | feed-logs | NO | 0 | IDOR was in this module (v1 finding), still untested |
| 15 | sleep-logs | NO | 0 | Access-control arg swap (v2 finding) fixed but untested |
| 16 | health-records | NO | 0 | verifyAccess ignore bug (v1 finding), still untested |
| 17 | growth | NO | 0 | WHO percentile calculation, chart data |
| 18 | allergies | NO | 0 | Allergy tracking CRUD |
| 19 | medical-team | NO | 0 | Medical team management |
| 20 | media | NO | 0 | Photo upload, S3 presigned URLs |
| 21 | linked-accounts | NO | 0 | Co-parent linking, VIEW/EDIT permissions |
| 22 | notifications | NO | 0 | Push notification dispatch |
| 23 | companion | NO | 0 | LLM chat, RAG, token counting, safety classifier |
| 24 | evolution | NO | 0 | Stage progression |
| 25 | stage-content | NO | 0 | Stage-keyed content delivery |
| 26 | admin | NO | 0 | Admin dashboard, user management |
| 27 | export | NO | 0 | PDF export, data packaging |
| 28 | mail | NO | 0 | SendGrid integration |
| -- | s3 | NO | 0 | S3 upload/delete operations |

**Totals:** 6 of 28 modules tested (21.4%). 27 individual tests. The 6 tested modules are all "infrastructure" or "surface" layers -- not a single business-logic service has test coverage.

---

## Mobile Test Coverage Analysis

| Category | File Count | Quality Assessment |
|---|---|---|
| Golden (visual regression) | ~14 files | **Strong.** Components, screens, states, error states, premium widgets, and semantics all captured in 4 theme combinations. CI runs golden tests in 3 parallel jobs. |
| Unit | ~15 files | **Good.** Entity serialization, provider state transitions, theme toggling, API client, error handler, retry interceptor. |
| Widget | ~12 files | **Adequate.** ThemeButton, auth form validation, feeding screen widgets, animated entries, scale-press, premium empty states. Quality varies -- some smoke-level only. |
| Integration | ~17 files | **Adequate but incomplete.** Screens tested: splash, onboarding, auth, dashboard, create-baby-mon, feeding, journal, health, album, milestones, partners, settings, subscriptions. **Missing:** No e2e test with real API backend. No companion chat flow test. No payment/subscription flow test. |
| Misc (smoke/flow) | ~8 files | **Placeholder quality.** `widget_test.dart` contains `expect(true, isTrue)` -- default Flutter template test never replaced. |

**Mobile totals:** ~66 Dart test files. No mockito/codegen -- mocks are hand-rolled inline.

---

## CI/CD Issues

| # | Severity | Issue | Impact | Fix |
|---|----------|-------|--------|-----|
| 1 | **CRITICAL** | **Branch name mismatch.** CI triggers on `push: branches: [main, develop]` but repository only has `master`. | CI **never runs on push**. PR checks only fire if target is `main` (which doesn't exist). Entire CI pipeline is effectively disabled. | Change `branches: [main, develop]` to `branches: [master]` or rename branch to `main`. |
| 2 | **CRITICAL** | **`update-goldens` job will never fire.** Condition is `github.ref == 'refs/heads/main'` -- neither event type nor ref can match. | Golden baselines frozen. When CI is fixed, every golden test will fail because no baselines were committed. | Fix branch name AND ensure baselines pre-generated before enabling. |
| 3 | **HIGH** | **No coverage gates.** Jest has no `coverageThreshold`. Flutter has no coverage collection in CI. | Coverage can regress silently. | Add `coverageThreshold` to jest.config.js (start at 30%). Add `flutter test --coverage` to CI. |
| 4 | **HIGH** | **No Flutter dependency caching.** CI installs deps fresh every run. | Adds ~8-12 minutes wasted across 4 Flutter jobs per CI run. | Add `cache: flutter` to flutter-action or use `actions/cache`. |
| 5 | **MEDIUM** | **No test retry/flaky handling.** No `retry` logic, no `continue-on-error`. | Single CI flake blocks merges. Golden tests inherently flaky. | Add `--retry=2` for non-golden tests. |
| 6 | **MEDIUM** | **PR trigger targets nonexistent `main`.** `pull_request: branches: [main]` won't fire since only `master` exists. | No CI on PRs at all. | Change to `branches: [master]`. |
| 7 | **LOW** | **Docker build serializes on tests.** `docker-build` `needs: lint-and-test` adds unnecessary serialization. | Docker build waits for full test suite. | Remove dependency or keep for smoke-test value. |
| 8 | **LOW** | **PostgreSQL version hardcoded.** `postgres:15-alpine` with no matrix. | No early warning of version incompatibility. | Add matrix for postgres:15 and postgres:16. |

---

## Top 5 Testing Gaps

1. **AccessControlService -- ZERO tests.** Single-point gatekeeper for all entity-level authorization. Three IDOR vulnerabilities found in v1 precisely because this layer was untested. **Risk: Unauthorized data access across all user accounts.**

2. **Stripe/webhook pipeline -- ZERO tests.** Subscription creation, webhook signature verification, idempotency, tier provisioning all untested. **Risk: Billing integrity failure, revenue loss, or fraud.**

3. **BadgesService + XP service -- ZERO tests.** 48 badge definitions, XP accumulation curves, level-up thresholds untested. **Risk: Gamification delivers wrong rewards, core product promise broken.**

4. **All 8 tracking services -- ZERO tests each.** Sleep-logs, feed-logs, health-records, growth, milestones, allergies, media, journal. Sites of 3 IDOR bugs in v1. **Risk: Data corruption, unauthorized writes, calculation errors.**

5. **Companion/LLM pipeline -- ZERO tests.** Safety classifier, TF-IDF RAG, token counting, typed llamadart wrapper all untested. **Risk: Unsafe AI responses served to parents, regulatory liability.**

---

## Backend Priority Test Plan (5 Modules to Test First)

### 1. AccessControlService (`src/common/access-control.service.ts`)
**Why first:** Every other service depends on this for authorization.
- `verifyAccessOrThrow()` -- authorized passes, unauthorized throws 403, deleted BabyMon returns 404
- `verifyLinkedAccess()` -- LINKED co-parent with VIEW sees data, EDIT can modify
- Edge cases: deleted user, deleted baby-mon, wrong permission level

### 2. StripeService + Stripe Webhook (`src/stripe/stripe.service.ts`)
**Why second:** Billing integrity. If Stripe is broken, entire business model collapses.
- Webhook signature verification (valid passes, tampered rejected, replay rejected)
- `StripeEvent` idempotency table
- Checkout session creation for each tier
- Subscription lifecycle: created -> active -> past_due -> canceled -> deleted

### 3. BabyMonService (`src/baby-mon/baby-mon.service.ts`)
**Why third:** Core entity. Every tracking service routes through BabyMon.
- CRUD operations with access control
- `calculateCurrentStage()` -- pregnancy stages, newborn, infant, toddler
- Stage boundary conditions
- Deletion cascades

### 4. BadgesService + XPService
**Why fourth:** Product differentiator. Gamification is core engagement loop.
- All 48 badge definitions have triggerable conditions
- Badge idempotency (no duplicates)
- XP calculation and level-up thresholds
- Edge cases: maximum level, negative XP impossible

### 5. SleepLogsService + FeedLogsService
**Why fifth:** Sites of known IDOR bugs. Testing alongside AccessControlService proves fixes.
- CRUD with access control integration
- Audit logging on every mutation
- Badge/XP integration triggers
- Input validation and pagination
