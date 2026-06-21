# 05 — Mobile Architecture Audit

**Date:** 2026-06-17
**Severity Score:** 🔴 Critical (5 Critical, 6 High, 7 Medium, 6 Low)
**Verdict:** Strong design system and testing, but repository layer is missing, god files dominate, and social login is fake.

---

## Summary

BabyMon's Flutter app (~114 Dart files) has a well-organized feature-first structure with Riverpod v2 for state management, GoRouter for navigation, and Dio for HTTP. The design system (`AppColors`, `DesignTokens`, `AppTheme` with Glass/Clay dual-theme architecture) is exceptional. The testing infrastructure is surprisingly strong with 60+ test files. However, the architecture has five critical gaps: **(1) the repository layer exists only in `auth/`** — every other feature calls `ApiClient` directly from screens; **(2) five god screen files exceed 30 KB** (`create_baby_mon_screen.dart` is 68 KB with 19 `setState` calls); **(3) `setState` ×116 across 25 files** coexists uneasily with Riverpod; **(4) four dependencies are dead weight** (`provider`, `get_it`, `drift`, `sqlite3_flutter_libs`); and **(5) social login is entirely simulated with fake tokens** — a security and product gap. The API base URL is hardcoded to an emulator address with HTTP.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| MA01 | 🔴 Critical | **Repository layer only in `auth/` — 15 screens hit `ApiClient` directly** | `lib/features/*/presentation/` — 60+ `ref.read(apiClientProvider)` calls outside auth/ | Only `auth/` has proper layering (`auth_remote_datasource.dart` → `auth_repository_impl.dart` → `auth_repository.dart`). `domain/entities/`, `domain/usecases/`, `domain/repositories/` directories are empty. | Create a repository + remote datasource per feature. Move API calls out of presentation widgets. |
| MA02 | 🔴 Critical | **God file: `create_baby_mon_screen.dart`** | `lib/features/onboarding/presentation/screens/create_baby_mon_screen.dart` | ~1800 lines, 19 `setState` calls, `TickerProviderStateMixin`, 5-step wizard, splash animation, MJ voice, flavor text — all one file. | Extract wizard steps into separate widgets. Extract animation controllers into a manager class. |
| MA03 | 🔴 Critical | **God file: `dashboard_screen.dart`** | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | ~900+ lines, 7 `setState`, 8 `_fetch*` methods, 10 silent `catch {}` blocks. Manages BabyMon state, evolution, badges, allergies, growth, reorderable tiles — 8+ concerns. | Decompose into `ConsumerWidget`s fed by Riverpod `AsyncNotifierProvider`s. One provider per data slice. |
| MA04 | 🔴 Critical | **`setState` ×116 in 25 files — Riverpod+setState hybrid** | `create_baby_mon_screen.dart` (19×), `settings_screen.dart` (12×), `verification_screen.dart` (8×), `main_screen.dart` (8×), `dashboard_screen.dart` (7×) | Business state (loading flags, data, form values) lives in `setState` instead of Riverpod providers. Dual-state confusion. | Audit each `setState`. Move business state to Riverpod `StateProvider`/`NotifierProvider`. Keep UI-only state (animation, obscure toggle) as local. |
| MA05 | 🔴 Critical | **Social login is fully simulated** | `auth_provider.dart:159,204,238` | `googleLogin()` creates fake user with id `'google-${timestamp}'`. TODO: "Send ID token to backend for verification". Same for Apple and Facebook. No backend OAuth endpoints exist. | Implement real backend token exchange. |
| MA06 | 🟠 High | **Hardcoded emulator URL in production constants** | `lib/core/constants/api_constants.dart:3` | `static const String baseUrl = 'http://10.0.2.2:3000';` — HTTP, not HTTPS. No environment switching. | Use `--dart-define=API_BASE_URL=...` + `envied` package for compile-time injection. |
| MA07 | 🟠 High | **Dead dependencies** | `pubspec.yaml:13-14,18-19,51` | `provider ^6.0.5` — 0 `ChangeNotifier` uses. `get_it ^7.6.4` — 0 `GetIt` references. `drift ^2.14.1` + `sqlite3_flutter_libs` + `drift_dev` — 0 `DriftDatabase` references. `http ^1.1.0` — unused alongside `dio`. | Remove all unused deps. |
| MA08 | 🟠 High | **`riverpod_annotation` + `build_runner` + `json_serializable` declared but unused** | `pubspec.yaml:24,52-54` | No `.g.dart` or `.freezed.dart` files exist. All providers hand-written. All `fromJson`/`toJson` manual. | Either adopt code-gen or remove the dev_dependencies. |
| MA09 | 🟠 High | **Silent error swallowing: 16 `catch {}` blocks** | `dashboard_screen.dart:229,252,261,270,281,296,304,313,945`; `api_client.dart:90`; `auth_remote_datasource.dart:99`; `login_screen.dart:58` | Dashboard has 10 silent catches. Failures in badge/growth/allergy/stage loading invisible to users. | Log errors via `debugPrint`. Surface errors in UI. |
| MA10 | 🟠 High | **`ApiClient` is a 447-line god class** | `lib/core/data/api_client.dart:7-447` | Single class handles auth, babyMons, milestones, feed-logs, health-records, badges, allergies, medical team, evolution, journal, export, subscription, growth, partners, photos, sleep-logs, stage-content, storage. | Split into feature-scoped clients or fold into feature repositories. |
| MA11 | 🟠 High | **Splash screen hardcoded 2-second delay** | `splash_screen.dart:64` | `await Future.delayed(Duration(seconds: 2))` — blocks navigation for 2s regardless of auth resolution. | Use auth check result directly. Remove artificial delay or use as minimum animation duration. |
| MA12 | 🟡 Medium | **No offline cache layer** | Entire `lib/` — no local DB (drift unused), no data caching | Network calls on every screen visit. Only mitigated by 10-second in-memory cooldown. | Implement `SharedPreferences`-based JSON caching for read-heavy data. |
| MA13 | 🟡 Medium | **`SharedPreferences` bypasses provider in 7 places** | `theme_mode_provider.dart:35,53,58,66`; `auth_provider.dart:83` | `SharedPreferences.getInstance()` called directly instead of `ref.read(sharedPreferencesProvider.future)`. | Use `ref.read(sharedPreferencesProvider.future)`. |
| MA14 | 🟡 Medium | **Token stored in both `SecureStorage` AND `SharedPreferences`** | `auth_remote_datasource.dart:121` | Duplicate token storage — `SharedPreferences` for `isLoggedIn` check, `SecureStorage` for actual token. | Use `FlutterSecureStorage` as single source of truth. |
| MA15 | 🟡 Medium | **No deep linking support** | `app_router.dart:14-62` | 16 flat `GoRoute` entries. No `ShellRoute`. No deep link config in AndroidManifest/Info.plist. | Add `GoRouter` deep link configuration. Consider `ShellRoute` for persistent bottom nav. |
| MA16 | 🟡 Medium | **`AppStrings` is incomplete and unused** | `lib/core/constants/app_strings.dart:1-12` | Only 12 strings. Most screens use hardcoded English string literals. | Complete `AppStrings` or adopt `flutter_localizations` with ARB files. |
| MA17 | 🟡 Medium | **Empty `domain/` layer directories** | `lib/domain/entities/`, `usecases/`, `repositories/` | Scaffolding directories with zero files. | Populate or remove. |
| MA18 | 🟡 Medium | **Android release signing not configured** | `android/app/build.gradle.kts:35-38` | `signingConfig = signingConfigs.getByName("debug")`. `applicationId = "com.example.baby_mon"`. | Create release keystore. Update applicationId. |
| MA19 | 🔵 Low | **`main.dart` hardcoded `Color(0xFF0E0E12)` in ErrorWidget** | `lib/main.dart:16` | Same value as `AppColors.darkBackground` but uses raw hex. | Reference `AppColors.darkBackground`. |
| MA20 | 🔵 Low | **No image assets — only fonts and empty `audio/`** | `assets/` folder | No PNG/SVG/Lottie. Icons come from vendored `phosphor_flutter` package. | Document whether image assets are CDN/Cloudinary only. Add placeholder assets for offline states. |
| MA21 | 🔵 Low | **`StubApiClient` ships in `lib/` not `test/`** | `lib/core/testing/stub_api_client.dart` | Test utility bundled with production code — bloats APK. | Move to `test/` directory. |
| MA22 | 🔵 Low | **Vendored `phosphor_flutter` via path override** | `pubspec.yaml` dependency_overrides → `packages/phosphor_flutter` | Fork risk. Needs sync tracking. | Document how to keep in sync with upstream. |
| MA23 | 🔵 Low | **Form validation is manual** | `login_screen.dart:22,68` | `GlobalKey<FormState>` + inline `validator:` callbacks. No form library. | Acceptable at current complexity. If forms grow, consider `formz` or `reactive_forms`. |
| MA24 | 🔵 Low | **SDK constraint very broad** | `pubspec.yaml:7` | `sdk: '>=3.0.0 <4.0.0'` | Pin to `>=3.2.0 <4.0.0` to ensure language features. |

---

## Things Done Well

1. **Design system is exceptional** — `AppColors` (WCAG AA documented), `DesignTokens` (spacing/radius/glass scale), `AppTheme` (Glass + Clay × light/dark = 4 combos), `ClayColors`, all centralized with dartdoc.
2. **Testing infrastructure** — 60+ test files across unit/integration/widget/golden. `StubApiClient`, `TestApiClient`, `FakeAuthNotifier`, platform mocks. Above average.
3. **Error handling** — `error_handler.dart` with DioException type switching (timeout, connection, status codes). Never exposes raw stack traces.
4. **JSON safety** — `json_utils.dart` with `parseJsonMap()`, `parseString()`, `parseItems()` — safe casts instead of bare `as Map`.
5. **Token refresh interceptor** — `RetryInterceptor` queues concurrent 401s, single refresh, retries all. Auth endpoints excluded from retry.
6. **`DataScreenMixin`** — eliminates loading/empty/no-data boilerplate across 6+ screens with cooldown and re-entrancy guards.
7. **Constants well-organized** — barrel exports, API paths, storage keys, app constants. No scattered magic numbers.
8. **Feature-first folder structure** — right choice. Barrel exports keep imports clean.
9. **Widget library (40+ widgets)** — `PremiumCard`, `ThemeButton`, `ScalePress`, `PhotoGrid`, `ConfirmDeleteDialog`, etc.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | Replace hardcoded URL with `--dart-define` + `envied`. | S |
| 2 | Implement real social login token exchange with backend. | M |
| 3 | Remove dead dependencies (`provider`, `get_it`, `drift`, `sqlite3_flutter_libs`, `drift_dev`, `http`). | S |
| 4 | Create repository layer per feature. Move API calls from screens to repositories. | L |
| 5 | Decompose god screens: `create_baby_mon_screen.dart`, `dashboard_screen.dart`, `health_screen.dart`, `settings_screen.dart`. | L |
| 6 | Audit 116 `setState` calls. Move business state to Riverpod. | M |
| 7 | Replace 16 silent `catch {}` blocks with logging and user-facing error states. | S |
| 8 | Configure release signing + update `applicationId`. | S |
| 9 | Remove hardcoded 2-second splash delay. | S |
| 10 | Consolidate token storage to `FlutterSecureStorage` only. | S |
| 11 | Add offline caching for read-heavy data. | M |
| 12 | Split `ApiClient` into feature-scoped clients (overlaps with #4). | M |
| 13 | Add deep link configuration + consider `ShellRoute`. | M |
| 14 | Complete `AppStrings` or adopt `flutter_localizations`. | M |
| 15 | Remove empty `domain/` directories. Move `StubApiClient` to `test/`. | S |
