# Architecture Refinement Plan

**Scope:** BabyMon Flutter mobile app (`apps/mobile/`)
**Audience:** Any developer, no prior project knowledge assumed
**Status:** Proposed
**Date:** 2026-06-16

---

## 1. Project Architecture — Current State

The app started with an intention of Clean Architecture (feature-first with `domain/`, `data/`, `presentation/` layers per feature). In practice, only the `auth` feature implements this fully. The other 10 features collapsed into a screen-centric pattern: screens call a monolithic API client directly, passing raw JSON maps around.

### Two Coexisting Codebases

The app has **two parallel screen directories** from a prior partial migration:

| Directory | Purpose | Status |
|---|---|---|
| `lib/features/*/presentation/screens/` | Newer feature-based screens | Active (auth, dashboard, feeding, etc.) |
| `lib/presentation/screens/main/*/` | Older presentation-layer screens | Stale — some still referenced by router |

The `features/` screens are the current source of truth. The `presentation/screens/` directory should be treated as dead code to be removed.

### High-Level Architecture Diagram

```
lib/
├── core/                          ← Shared infrastructure
│   ├── data/
│   │   ├── api_client.dart        ← Monolithic Dio client (447 lines, 76 methods)
│   │   └── retry_interceptor.dart
│   ├── providers.dart             ← Riverpod providers
│   ├── mixins/data_screen_mixin.dart  ← CRUD boilerplate mixin
│   ├── widgets/                   ← 37 shared UI widgets
│   ├── theme/                     ← App theme, design tokens, colors
│   ├── utils/                     ← JSON helpers, error handler, validators
│   ├── constants/                 ← API endpoints, colors, strings
│   └── services/                  ← Google/Apple/Facebook sign-in
│
├── domain/                        ← Empty — no files
│
├── features/
│   ├── auth/                      ← ONLY feature with full Clean Architecture layering
│   │   ├── domain/entities/user.dart
│   │   ├── domain/repositories/auth_repository.dart
│   │   ├── data/datasources/auth_remote_datasource.dart
│   │   ├── data/repositories/auth_repository_impl.dart
│   │   └── presentation/ (providers, screens, widgets)
│   │
│   └── [10 other features]        ← FLAT: no domain/ or data/ layer
│       └── presentation/
│           ├── screens/           ← 500–1700+ lines each
│           └── widgets/
│
├── presentation/                  ← Dead code from old architecture
│   └── screens/main/              ← Stale duplicate screens
│
└── main.dart / app.dart / router/
```

---

## 2. Issue-by-Issue Breakdown

### Issue 1: Monolithic ApiClient

| Attribute | Current Value |
|---|---|
| File | `lib/core/data/api_client.dart` |
| Lines | 447 |
| HTTP methods | 76 (71 domain-specific + 5 generic) |
| Files that use it directly | 14 screens + 1 mixin |

**What's wrong:** Every screen in the app obtains `ApiClient` via `ref.read(apiClientProvider)` and calls methods directly. There is no per-feature service layer. Changes to the API client (e.g., adding auth headers, changing error handling) affect all 15 consumers simultaneously. Testing a screen requires mocking the entire 76-method ApiClient instead of a focused 6-method service.

**Why it happened:** The `auth` feature has a proper `AuthRemoteDatasource` → `AuthRepository` pipeline, but this pattern was never extended to other features. New features were built directly against Dio.

**How to fix (step by step):**

1. Create `lib/features/{feature}/data/services/{feature}_service.dart` — a class that takes `Dio` (or `ApiClient`) as a constructor dependency and exposes only the methods that feature needs
2. Create a Riverpod provider for each service in the feature's `presentation/providers/` directory
3. Update each screen to `ref.read({feature}ServiceProvider)` instead of `ref.read(apiClientProvider)`
4. Delete unused methods from `ApiClient` as they become unused

**Example — Feeding service:**

```dart
// lib/features/feeding/data/services/feeding_service.dart
class FeedingService {
  final ApiClient _client;
  FeedingService(this._client);

  Future<Map<String, dynamic>> createFeedLog(Map<String, dynamic> data) =>
      _client.post('/feed-logs', data: data);

  Future<List<dynamic>> getFeedLogs({DateTime? date}) =>
      _client.get('/feed-logs', queryParameters: date != null ? {'date': date.toIso8601String().split('T').first} : null);

  Future<void> deleteFeedLog(String id) =>
      _client.delete('/feed-logs/$id');
}
```

```dart
// lib/features/feeding/presentation/providers/feeding_provider.dart
final feedingServiceProvider = Provider<FeedingService>((ref) {
  return FeedingService(ref.read(apiClientProvider));
});
```

**Files to touch:** `api_client.dart` + all 15 consuming files
**Risk:** Low — pure extraction. No behavior change.

---

### Issue 2: Missing Domain Entities

| Attribute | Current Value |
|---|---|
| Features with entities | 1 of 11 (auth: `User`) |
| Data type used everywhere else | `Map<String, dynamic>` |
| Occurrences of `Map<String, dynamic>` across features | ~61+ |

**What's wrong:** Screen code accesses fields by string keys: `data['name']`, `parseString(data['stage'])`, `parseJsonMap(raw['evolution'])`. There is zero compile-time safety. Renaming a field on the API requires hunting through all string references. IDE features (autocomplete, refactoring, find references) do not work.

**Why it happened:** The project started without domain entities and never introduced them. JSON utility functions (`parseString`, `parseJsonMap`, `parseItems`) made raw-map access convenient enough to never feel painful.

**How to fix (step by step):**

1. Create `lib/features/{feature}/domain/entities/` files — immutable Dart classes with named constructors and `fromJson`/`toJson`
2. Replace `Map<String, dynamic>` parameter types in screens and services with the entity type
3. Update all field access from `data['name']` to `entity.name`

**Example — Feeding entity:**

```dart
// lib/features/feeding/domain/entities/feed_log.dart
class FeedLog {
  final String id;
  final String babyMonId;
  final String type; // BREASTFEEDING, FORMULA, SOLID, EXPRESSED
  final double? amountMl;
  final String? notes;
  final DateTime timestamp;

  const FeedLog({
    required this.id,
    required this.babyMonId,
    required this.type,
    this.amountMl,
    this.notes,
    required this.timestamp,
  });

  factory FeedLog.fromJson(Map<String, dynamic> json) => FeedLog(
    id: json['id'] as String,
    babyMonId: json['babyMonId'] as String,
    type: json['type'] as String,
    amountMl: (json['amountMl'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'babyMonId': babyMonId,
    'type': type,
    'amountMl': amountMl,
    'notes': notes,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

**Priority order** (do in this sequence):
1. `FeedLog` (feeding)
2. `Milestone` (milestones)
3. `HealthRecord` (health)
4. `SleepLog` (sleep)
5. `GrowthRecord` (growth chart)
6. `JournalEntry` (journal)
7. `BabyMonSummary` / `DashboardData` (dashboard)
8. `Partner` (partners)
9. `Photo` / `AlbumEntry` (album)
10. `StageContent` (dashboard)

**Files to touch:** 10 new entity files + all consuming screens
**Risk:** Low-medium. Mechanical work but many files change. Do one feature at a time.

---

### Issue 3: No Feature-Specific Repositories (outside auth)

| Attribute | Current Value |
|---|---|
| Features with `data/repositories/` | 1 of 11 (auth) |
| Features with `domain/repositories/` | 1 of 11 (auth) |

**What's wrong:** Without a repository interface, the data source is hard-wired to `ApiClient` → Dio → REST API. There is no seam for:
- Swapping to a different backend (GraphQL, Firebase, local-first)
- Unit testing with a fake/mock repository
- Adding caching or offline support later

**Why it happened:** Same root cause as Issue 1 — the auth pattern was never extended.

**How to fix (step by step):**

Repositories are only useful **after** entities exist. The order is: entities → services → repositories. If you create repositories without entities, they just wrap raw Maps.

1. Create `lib/features/{feature}/domain/repositories/{feature}_repository.dart` — abstract class with method signatures
2. Create `lib/features/{feature}/data/repositories/{feature}_repository_impl.dart` — implementation that calls the service
3. Create a Riverpod provider for each repository
4. Update screens to use the repository provider instead of the service provider

**Example:**

```dart
// lib/features/feeding/domain/repositories/feeding_repository.dart
abstract class FeedingRepository {
  Future<FeedLog> createFeedLog(FeedLog log);
  Future<List<FeedLog>> getFeedLogs({DateTime? date});
  Future<void> deleteFeedLog(String id);
}
```

```dart
// lib/features/feeding/data/repositories/feeding_repository_impl.dart
class FeedingRepositoryImpl implements FeedingRepository {
  final FeedingService _service;
  FeedingRepositoryImpl(this._service);

  @override
  Future<FeedLog> createFeedLog(FeedLog log) async {
    final result = await _service.createFeedLog(log.toJson());
    return FeedLog.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<List<FeedLog>> getFeedLogs({DateTime? date}) async {
    final results = await _service.getFeedLogs(date: date);
    return (results as List)
        .map((e) => FeedLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteFeedLog(String id) => _service.deleteFeedLog(id);
}
```

**Files to touch:** 2 files per feature (interface + impl) + update screen providers
**Risk:** Low. Additive — no existing code breaks.

---

### Issue 4: Blanket Missing `freezed` (Actually: Missing Code Generation)

| Attribute | Current Value |
|---|---|
| `json_serializable` in `pubspec.yaml` | Yes (unused, in dev_dependencies) |
| `freezed` in `pubspec.yaml` | No |
| Any generated `.g.dart` or `.freezed.dart` | No |
| `build_runner` in `pubspec.yaml` | Yes (unused, in dev_dependencies) |
| Annotation usage | Zero outside `@immutable` |

**What's wrong:** The project already depends on `json_serializable` and `build_runner` but never uses them. `freezed` is recommended as the standard way to generate immutable data classes with `fromJson`/`toJson`, `copyWith`, equality, and `toString` — but it's not yet a dependency.

**Why it happened:** Serialization was done manually (the `user.dart` `fromJson`/`toJson` approach) or via the `json_utils.dart` helper functions. The dev dependencies were added ahead of adoption that never happened.

**How to fix (step by step):**

1. **Only after creating entities** — add `freezed` and `freezed_annotation` to `pubspec.yaml` dependencies
2. Annotate entity classes with `@freezed` and `@JsonSerializable`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Remove manual `fromJson`/`toJson` and `json_utils.dart` helpers over time

**Example:**

```yaml
# pubspec.yaml additions
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  freezed: ^2.4.6
  json_serializable: ^6.7.1  # already present
  build_runner: ^2.4.7       # already present
```

```dart
// lib/features/feeding/domain/entities/feed_log.dart (after freezed)
import 'package:freezed_annotation/freezed_annotation.dart';
part 'feed_log.freezed.dart';
part 'feed_log.g.dart';

@freezed
class FeedLog with _$FeedLog {
  const factory FeedLog({
    required String id,
    required String babyMonId,
    required String type,
    double? amountMl,
    String? notes,
    required DateTime timestamp,
  }) = _FeedLog;

  factory FeedLog.fromJson(Map<String, dynamic> json) => _$FeedLogFromJson(json);
}
```

**Files to touch:** All entity files after creation
**Risk:** Low. `build_runner` is already configured. Generated files go in `.gitignore`-compatible paths.

---

### Issue 5: Massive Screen Files

| Screen | Lines | What makes it large |
|---|---|---|
| `create_baby_mon_screen.dart` | 1,732 | 5-step wizard, animations, sound, form logic |
| `dashboard_screen.dart` | 1,719 | 8 API calls, badges, evolution, growth, stage content, XP |
| `main_screen.dart` | 969 | Nav shell + BabyMon selector + drawer + cross-tab signals |
| `settings_screen.dart` | 778 | Profile + preferences + account + danger zone + partners |
| `health_screen.dart` | 744 | Growth nav + sleep nav + allergies + event recording + filtering |
| `feeding_screen.dart` | 727 | Chart + list + add form + dismissible + date grouping |
| `journal_screen.dart` | 638 | Type filtering + proposals + cards + cross-filter refresh |
| `growth_chart_screen.dart` | 600 | Chart + zoom + record list + add form |
| `subscription_screen.dart` | 581 | Plan comparison + upgrade + trial countdown |
| `login_screen.dart` | 451 | Form + social login + forgot password + biometric |

12 of 19 screens exceed 300 lines. The top 3 are extreme.

**What's wrong:** A single file handles UI layout, business logic, data fetching, state management, navigation, form validation, animations, and error handling. This makes files hard to:
- Read and understand (even the author loses context after 500 lines)
- Test (widget tests need to mock everything)
- Modify (a change to business logic risks breaking layout)
- Share (no reuse of the wizard step pattern, the badge grid pattern, etc.)

**Why it happened:** The app grew feature-by-feature without establishing a widget extraction threshold. The `DataScreenMixin` was an attempt to reduce duplication but it doesn't reduce screen size.

**How to fix (step by step):**

General rule: **If a screen file exceeds 400 lines, extract.**

For each screen, identify extractable sections:

1. **Dashboard (1,719 lines):**
   - Extract `StageHeroCard` (stage content, name, level badge)
   - Extract `QuickStatsRow` (4 stat cards)
   - Extract `XpProgressBar` (XP bar with milestones)
   - Extract `GrowthSparkline` (mini chart preview)
   - Extract `BadgeShowcase` (badge grid with categories)
   - Extract `DashboardTile` (single reorderable tile wrapper)
   - Move badge/evolution/computation logic into a `DashboardHelpers` utility class

2. **CreateBabyMon (1,732 lines):**
   - Extract each step as a separate widget file: `SplashStep`, `NameStep`, `StageStep`, `SpiritStep`, `ReviewStep`
   - Extract `MjText` widget for MJ voice narration
   - Extract `CeremonialTextField` for the naming input
   - Extract `GenderOrb` for gender selection
   - Extract `FlavorChip` for trait selection with flavor text

3. **MainScreen (969 lines):**
   - Extract `FloatingPillNav` widget
   - Extract `AppDrawer` widget
   - Extract `BabyMonSelector` widget
   - Extract `NotificationWidget` / notification logic

4. **Settings (778 lines):**
   - Extract `ProfileSection` widget
   - Extract `PreferencesSection` widget
   - Extract `AccountSection` widget (with delete/logout)

5. **Health (744 lines):**
   - Extract `HealthNavigationCards` (growth + sleep nav)
   - Extract `AllergyEventCard` widget
   - Extract `HealthFilterChips` widget

**Files to touch:** 1 screen + N extracted widget files per extraction
**Risk:** Low-medium. Pure extraction — no behavior change.

---

### Issue 6: Missing Use Cases

| Attribute | Current Value |
|---|---|
| `domain/usecases/` directories | None (all empty or absent) |
| Non-CRUD operations | 2 (dashboard orchestration, BabyMon creation wizard) |

**What's wrong:** Business logic lives in screen files. The `DashboardScreen` orchestrates 8 parallel API calls, computes stage progression, age, XP levels, and badge groupings — all in `setState()` calls within a `ConsumerStatefulWidget`. The `CreateBabyMonScreen` has a 5-step wizard with validation rules, conditional field logic, and payload assembly.

**Why it happened:** Most features are simple CRUD (create → read → update → delete). Adding use cases for CRUD is ceremonial overhead with no benefit. The dashboard and creation wizard are the only features complex enough to justify extraction.

**How to fix (step by step):**

1. Create `lib/features/dashboard/domain/usecases/load_dashboard_data.dart` — a class that takes multiple repositories and returns a unified result
2. Create `lib/features/onboarding/domain/usecases/create_baby_mon.dart` — a class that handles validation, payload assembly, and submission

**Example — Dashboard use case:**

```dart
// lib/features/dashboard/domain/usecases/load_dashboard_data.dart
class LoadDashboardData {
  final BabyMonRepository _babyMonRepo;
  final BadgeRepository _badgeRepo;
  final GrowthRepository _growthRepo;
  final AllergiesRepository _allergiesRepo;
  final StageContentRepository _stageRepo;

  const LoadDashboardData({
    required BabyMonRepository babyMonRepo,
    required BadgeRepository badgeRepo,
    required GrowthRepository growthRepo,
    required AllergiesRepository allergiesRepo,
    required StageContentRepository stageRepo,
  }) : _babyMonRepo = babyMonRepo,
       _badgeRepo = badgeRepo,
       _growthRepo = growthRepo,
       _allergiesRepo = allergiesRepo,
       _stageRepo = stageRepo;

  Future<DashboardData> call(String babyMonId) async {
    final results = await Future.wait([
      _babyMonRepo.getSummary(babyMonId),
      _badgeRepo.getAll(babyMonId),
      _growthRepo.getLatest(babyMonId),
      _allergiesRepo.getAll(babyMonId),
      _stageRepo.getContent(babyMonId),
    ]);
    return DashboardData(
      summary: results[0] as BabyMonSummary,
      badges: results[1] as List<Badge>,
      growth: results[2] as GrowthRecord?,
      allergies: results[3] as List<Allergy>,
      stageContent: results[4] as StageContent?,
    );
  }
}
```

**Files to touch:** 2 new use case files + 2 screen files (to consume them)
**Risk:** Low. Additive — use cases wrap existing calls.

---

## 3. Phased Execution Plan

Each phase is independent and can be done in any order, but the recommended sequence minimizes rework.

### Phase 0: Clean Up Dead Code

**Effort:** 30 minutes
**Risk:** Medium (router depends on dead code — must verify)

1. Identify which files in `lib/presentation/screens/` are still referenced by the router (`lib/presentation/router/app_router.dart`)
2. For each referenced file, update the import to point to `lib/features/` equivalent
3. Verify no remaining imports to `lib/presentation/screens/`
4. Delete `lib/presentation/` directory

### Phase 1: Domain Entities

**Effort:** 3-5 days
**Risk:** Low

1. Feeding → `FeedLog` entity
2. Milestones → `Milestone` entity
3. Health → `HealthRecord` entity
4. Sleep → `SleepLog` entity
5. Growth → `GrowthRecord` entity
6. Journal → `JournalEntry` entity
7. Dashboard → `BabyMonSummary`, `DashboardData` entities
8. Album → `PhotoEntry` entity
9. Partners → `Partner` entity
10. Settings → `UserSettings` entity

Each entity: add `domain/entities/` directory, create immutable class with `fromJson`/`toJson`.

### Phase 2: Feature Services (Split ApiClient)

**Effort:** 2-3 days
**Risk:** Low

1. Create one service class per feature (10 total)
2. Move relevant methods from `ApiClient` to each service
3. Create Riverpod providers for each service
4. Update screens to use service providers
5. Remove unused methods from `ApiClient`

### Phase 3: Feature Repositories

**Effort:** 2 days
**Risk:** Low

Only after Phase 1 (entities) and Phase 2 (services) are done.

1. Create abstract repository interface per feature
2. Create implementation wrapping the service
3. Create Riverpod providers
4. Update screens to use repository providers

### Phase 4: Break Up Large Screens

**Effort:** 4-7 days
**Risk:** Medium (extraction can introduce import issues)

Do in priority order:
1. Dashboard (1,719 lines → 8 widget files)
2. CreateBabyMon (1,732 lines → 7 widget files)
3. MainScreen (969 lines → 4 widget files)
4. Settings (778 lines → 3 widget files)
5. Health (744 lines → 3 widget files)
6. Feeding (727 lines → chart + list widgets)

### Phase 5: freezed Migration

**Effort:** 1 day
**Risk:** Low (build_runner already configured)

1. Add `freezed` and `freezed_annotation` to `pubspec.yaml`
2. Run `flutter pub get`
3. Convert entity files one by one (add annotations, run `build_runner`, verify)
4. Eventually deprecate and remove `lib/core/utils/json_utils.dart`

### Phase 6: Use Cases (Dashboard + Wizard Only)

**Effort:** 4-6 hours
**Risk:** Low

1. Create `LoadDashboardData` use case
2. Create `CreateBabyMon` use case
3. Update screen files to inject and call use cases

---

## 4. Effort Summary

| Phase | What | Effort | Risk |
|---|---|---|---|
| 0 | Clean up dead `presentation/` code | 30 min | Medium |
| 1 | Domain entities (10 features) | 3-5 days | Low |
| 2 | Feature services (split ApiClient) | 2-3 days | Low |
| 3 | Feature repositories (wrap services) | 2 days | Low |
| 4 | Break up large screens (6 screens) | 4-7 days | Medium |
| 5 | freezed migration | 1 day | Low |
| 6 | Dashboard + wizard use cases | 4-6 hours | Low |
| **Total** | | **~2-3 weeks** | |

### Optional / If Time Permits

- **Replace `DataScreenMixin`**: After phases 1-3, the mixin's boilerplate can be replaced by the repository pattern entirely
- **Unit tests**: Once repositories exist, screen logic becomes testable without widget tests
- **Remove `json_utils.dart`**: Once all entities use freezed, the helper functions are dead code

---

## 5. What NOT to Do

| Don't | Why |
|---|---|
| Don't add use cases for CRUD features | Ceremony without benefit. CRUD = repository call → done. |
| Don't add repositories before entities | They'll wrap raw Maps, defeating the purpose. |
| Don't rewrite screens from scratch during extraction | Pure extraction (move code, don't rewrite) minimizes bugs. |
| Don't mix phases | Each phase is independent. Do one, verify, then next. |
| Don't add state management (Bloc, etc.) | Riverpod is already in use and working. Adding another system creates complexity, not value. |
| Don't add new packages without necessity | Every dependency is a maintenance burden. `freezed` is the only new package justified. |

---

## 6. How to Verify Each Phase

| Phase | Verification |
|---|---|
| 0 | `flutter analyze` passes; app navigates to all screens |
| 1 | `flutter analyze` passes; entity `fromJson`/`toJson` roundtrip tests |
| 2 | `flutter analyze` passes; all screens load data correctly |
| 3 | `flutter analyze` passes; repository tests pass with fake implementations |
| 4 | `flutter analyze` passes; widget tests pass for extracted components |
| 5 | `dart run build_runner build` succeeds; `flutter analyze` passes |
| 6 | `flutter analyze` passes; dashboard and creation wizard behave identically |

---

## 7. Appendix: File Manifest

### Current Structure (simplified)

```
lib/
├── core/
│   ├── data/api_client.dart          ← 447 lines, 76 methods [TO SPLIT]
│   ├── mixins/data_screen_mixin.dart  ← 276 lines [TO DEPRECATE]
│   └── utils/json_utils.dart         ← JSON helpers [TO REMOVE after freezed]
│
├── features/
│   ├── auth/                          ← MODEL: keep this pattern
│   │   ├── domain/entities/user.dart
│   │   ├── domain/repositories/
│   │   ├── data/datasources/
│   │   ├── data/repositories/
│   │   └── presentation/
│   │
│   ├── feeding/                       ← FLAT: needs entities + service + repo
│   │   └── presentation/screens/feeding_screen.dart (727 lines)
│   │
│   ├── milestones/                    ← FLAT
│   ├── health/                        ← FLAT
│   ├── sleep/                         ← FLAT
│   ├── growth-chart/                  ← FLAT
│   ├── journal/                       ← FLAT
│   ├── album/                         ← FLAT
│   ├── dashboard/                     ← FLAT + 1,719-line screen
│   ├── settings/                      ← FLAT + 778-line screen
│   ├── onboarding/                    ← FLAT + 1,732-line screen
│   └── splash/                        ← FLAT
│
└── presentation/                      ← [TO DELETE — dead code]
```

### Target Structure (after all phases)

```
lib/
├── core/
│   └── data/api_client.dart            ← Slimmed: only generic HTTP methods
│
├── features/
│   ├── auth/                           ← Already correct
│   ├── feeding/                        ← RESTRUCTURED
│   │   ├── domain/entities/feed_log.dart
│   │   ├── domain/repositories/feeding_repository.dart
│   │   ├── data/services/feeding_service.dart
│   │   ├── data/repositories/feeding_repository_impl.dart
│   │   └── presentation/screens/ (< 400 lines)
│   ├── [all other features]            ← Same pattern as feeding
│   └── dashboard/                      ← RESTRUCTURED + USE CASE
│       ├── domain/entities/baby_mon_summary.dart
│       ├── domain/entities/dashboard_data.dart
│       ├── domain/repositories/baby_mon_repository.dart
│       ├── domain/usecases/load_dashboard_data.dart
│       ├── data/services/dashboard_service.dart
│       ├── data/repositories/baby_mon_repository_impl.dart
│       └── presentation/screens/ + widgets/ (< 400 lines each)
│
└── presentation/                       ← DELETED
```
