# S05 — Mobile Architecture Audit

**Date:** 2026-06-18 | **Overall Health Score:** 4.9/10 | **Severity:** 🟠 High

The BabyMon Flutter app (~27 screens, Riverpod + GoRouter) exhibits a **"two-speed codebase"**: the `auth` feature has complete Clean Architecture (domain/data/presentation layers), but **11 other features are flat** — screens directly call the monolithic `ApiClient` (76+ methods, 400+ lines). `setState` dominates state management (60+ calls), with Riverpod used primarily as a DI container. The `companion` feature is architecturally ambitious (on-device LLM) but 100% untested end-to-end.

---

## Findings

### MA-C01 | 🔴 CRITICAL | Monolithic ApiClient — 76 Methods in One Interface

**Location:** `lib/core/data/api_client.dart`

**What:** `ApiClient` mixes 4 distinct concerns: HTTP transport, auth persistence, BabyMonId session state, and ALL feature CRUD (76+ typed methods). Violates Interface Segregation Principle — every screen receives the entire interface.

**Evidence:** 400+ line abstract class with 76+ abstract methods spanning auth, babyMons, milestones, feedLogs, healthRecords, badges, allergies, medicalTeam, evolution, journal, growthRecords, partners, photos, sleepLogs, stageContent, export, subscription.

**Remediation:** Split into per-feature repository interfaces. Keep HTTP transport in a separate `HttpClient` service. Move session state to a dedicated provider.

---

### MA-C02 | 🔴 CRITICAL | 11 Features Have Zero Architecture Layers

**Location:** All features except `auth/`

**What:** Only auth has domain/data/presentation layers with repository interfaces. Every other feature is flat: screens call `ref.read(apiClientProvider)` directly with no repository abstraction, no domain-layer use cases, and no datasource separation.

**Examples:**
- `feeding_screen.dart:79` — `ref.read(apiClientProvider).getFeedLogs(babyMonId!)`
- `health_screen.dart:70` — `ref.read(apiClientProvider).get('/api/baby-mons/$babyMonId/health-records')`
- Even `login_screen.dart:171` bypasses authProvider — `ref.read(apiClientProvider).post(...)`

**Remediation:** Extract repository interfaces for feeding, health, milestones, dashboard first. Create datasources that wrap ApiClient sub-interfaces. Move screen logic to StateNotifiers.

---

### MA-C03 | 🔴 CRITICAL | create_baby_mon_screen.dart — 1,800-Line God Screen

**Location:** `lib/features/onboarding/presentation/screens/create_baby_mon_screen.dart`

**What:** Single widget handles 10+ concerns: form validation, image picker, name generation, API calls, navigation, wizard steps, partner invitation, visual customization, photo review, error handling. Contains 20+ `setState` calls.

**Remediation:** Extract each wizard step into its own widget. Create a `CreateBabyMonNotifier` (StateNotifier). Move validation to domain entities. Move API calls to a `BabyMonRepository`. Break into 6-8 files.

---

### MA-C04 | 🔴 CRITICAL | 5+ Unused Dependencies Bloated in pubspec.yaml

**Location:** `apps/mobile/pubspec.yaml`

**What:** Five packages declared but zero imports anywhere:
- `provider: ^6.1.2` — project uses Riverpod exclusively
- `get_it: ^8.0.3` — zero imports
- `drift: ^2.22.1` — zero imports, no .drift files
- `sqlite3_flutter_libs: ^0.5.24` — companion to unused drift
- `google_fonts: ^6.2.1` — zero imports
- (Possibly) `json_annotation`, `json_serializable`, `build_runner` — zero generated .g.dart files

**Remediation:** Remove all unused dependencies. This reduces APK size, supply chain attack surface, and maintenance burden.

---

### MA-H01 | 🟠 HIGH | Riverpod Used as Service Locator; setState Dominates

**Location:** All screens

**What:** Only 4 StateNotifiers exist across the entire app (auth, visual style, theme mode, model download). Everything else uses `ConsumerStatefulWidget` with `setState`. Riverpod is used exclusively for `ref.read(apiClientProvider)` — equivalent to a service locator.

**Issues:**
- No undo/redo — setState is atomic fire-and-forget
- No optimistic updates — API call, then setState, no rollback
- Screen-local state untestable without widget pumping
- Loading/error states tracked via local boolean flags

**Remediation:** Create StateNotifiers for core features (feeding, health, milestones, dashboard). Use immutable state classes. Expose loading/error states through providers.

---

### MA-H02 | 🟠 HIGH | Companion LLM Pipeline — 100% Untested, Questionable Production Readiness

**Location:** `lib/features/companion/data/llm/` (9+ files)

**What:** Ambitious on-device LLM architecture with `llamadart: ^0.5.1` (pre-1.0 community package), Gemma model download, RAG, chat sessions. But:
- Zero test files for companion feature
- No end-to-end test evidence
- `llamadart` pre-1.0, limited maintenance
- No device capability check — 2B parameter model requires ~500MB+ RAM
- No cloud API fallback

**Remediation:** Add integration tests with mock engine. Gate feature behind device capability check (RAM, storage). Consider cloud API as primary with on-device as optional. Or mark as experimental.

---

### MA-H03 | 🟠 HIGH | health_screen.dart — 725-Line Monolith

**Location:** `lib/features/health/presentation/screens/health_screen.dart`

**What:** Single screen merges health records + allergy events into one list. Contains 3 separate modal bottom sheets (measurement, allergy, event). 8 setState calls. Direct ApiClient calls for 7 different endpoints.

**Remediation:** Split into health_list_screen, measurement_form, allergy_form, event_form. Extract a `HealthNotifier` StateNotifier.

---

### MA-M01 | 🟡 MEDIUM | Duplicate /companion/:babyMonId Route

**Location:** `lib/core/router/app_router.dart:62,68`

**What:** Two identical `GoRoute` entries for the same path. Line-by-line duplicate — merge artifact. GoRouter uses first match; second is dead code.

**Remediation:** Remove the duplicate route.

---

### MA-M02 | 🟡 MEDIUM | 9-Tab IndexedStack Keeps All Tabs in Memory

**Location:** `lib/features/navigation/presentation/screens/main_screen.dart`

**What:** `IndexedStack` with 9 tabs — all tab states live in memory simultaneously. Companion tab with LLM initialization is always alive even when not selected.

**Remediation:** Implement `AutomaticKeepAliveClientMixin` per tab or use `PageView` with limited caching.

---

### MA-M03 | 🟡 MEDIUM | Empty FAB Callbacks on Dashboard

**Location:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart:415,422,429`

**What:** Three `InfoFabAction` entries have `onTap: () {}` — tapping them does nothing.

**Remediation:** Implement or remove the stubbed actions.

---

### MA-M04 | 🟡 MEDIUM | DataScreenMixin Doesn't Integrate with Riverpod

**Location:** `lib/core/mixins/data_screen_mixin.dart`

**What:** Provides loading/no-baby-mon/error/refresh scaffolding but uses local `setState` rather than Riverpod providers. Forces all screens into the same shape.

**Remediation:** Convert to a provider family or generic async value widget.

---

### MA-M05 | 🟡 MEDIUM | No Deep Linking Support

**Location:** `lib/core/router/app_router.dart`

**What:** No `GoRouter.redirect` configuration for universal links or deep links. All navigation relies on in-app state (selectedBabyMonId from secure storage).

**Remediation:** Add deep link handling for sharing milestones, invitations, etc.

---

### MA-M06 | 🟡 MEDIUM | Feature Barrel Files Inconsistent

**Location:** All feature `feature.dart` files

**What:** Auth exports all layers. Dashboard exports only screens. Feeding exports only screens. Health exports entities + screen. Inconsistent public API boundaries.

**Remediation:** Standardize: every barrel exports entities, repository interfaces, providers, and screens.

---

## Architecture Health Scores

| Dimension | Score | Notes |
|---|---|---|
| Layer Separation | 3/10 | Only auth has Clean Architecture |
| State Management | 3/10 | Riverpod used as service locator |
| Code Reusability | 6/10 | Good shared widget library |
| Testability | 4/10 | Entities testable; screens require monolithic mock |
| Dependency Hygiene | 4/10 | 5+ unused packages; ApiClient is god interface |
| Navigation | 6/10 | GoRouter correct but duplicate route |
| Theming | 8/10 | Excellent token system |
| Feature Completeness | 5/10 | Core works; companion/peripheral incomplete |

**Overall: 4.9/10** — Functions as MVP but significant architectural debt.

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 4 |
| 🟠 High | 3 |
| 🟡 Medium | 6 |
| 🔵 Low | 5 |
| **Total** | **18** |
