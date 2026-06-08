# BabyMon — Known Gotchas & Bug Compendium
> Every bug discovered, root cause identified, and fix applied during the project revival (June 2026).
> **Purpose:** Prevent future developers from repeating the same debugging cycles.

---

## Critical Architecture Issues

### 1. Duplicate `apiClientProvider` — Two Different Riverpod Providers
**Symptom:** 401 Unauthorized on all authenticated API calls after successful login.
**Root Cause:** Two separate `final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());` definitions existed in:
- `lib/core/providers.dart` (line 5)
- `lib/presentation/providers/auth_provider.dart` (line 15)

In Riverpod, providers are identified by their **Dart variable reference**, not by name. These were two entirely separate providers with separate caches, creating **two different `ApiClient` instances**. Screens imported from `core/providers.dart` got instance A; auth flow (login/register) used instance B where tokens were saved.
**Fix:** Removed the `apiClientProvider` from `core/providers.dart`. All imports now point to `package:baby_mon/presentation/providers/auth_provider.dart`.
**Files Changed:** `core/providers.dart`, `create_baby_mon_screen.dart`
**Prevention:** Never create duplicate Riverpod providers with the same name. Single source of truth.

---

### 2. Missing `/api` Prefix on Typed API Methods
**Symptom:** 404 Not Found on milestone, feeding, health record, badge, evolution, journal, and export endpoints.
**Root Cause:** The NestJS backend applies a global `/api` prefix. The generic `get()/post()/patch()/delete()` methods in `ApiClient` auto-prepend `/api`. But **25 typed methods** (register, login, getProfile, createBabyMon, getMilestones, etc.) call `_dio.get/post()` directly with `ApiConstants` paths like `/auth/login` and `/baby-mons` — missing the `/api` prefix.
**Fix:** Audited all 40+ typed methods and added `/api` prefix. Example: `_dio.post(ApiConstants.babyMons, ...)` → `_dio.post('/api${ApiConstants.babyMons}', ...)`.
**Files Changed:** `lib/data/api_client.dart`
**Prevention:** When adding a typed method, always use `/api${ApiConstants.xxx}`. Better yet, use the generic method which handles the prefix automatically.

---

### 3. Token Storage Mismatch (SharedPreferences vs FlutterSecureStorage)
**Symptom:** 401 on name edit, create BabyMon, and other authenticated operations despite successful login.
**Root Cause:** The `AuthRemoteDatasource` saves tokens to `SharedPreferences` (`_prefs.setString('accessToken', token)`). But the Dio interceptor in `ApiClient` reads from `FlutterSecureStorage` (`_storage.read(key: StorageKeys.accessToken)`). Two completely different storage backends — the Authorization header was never sent.
**Fix:** Added `await _apiClient.saveTokens(token, '', user.id)` after both `login()` and `register()` success paths in `auth_remote_datasource.dart`. This saves tokens to **both** storage mechanisms.
**Files Changed:** `features/auth/data/datasources/auth_remote_datasource.dart`
**Prevention:** After any login/register operation, always call `ApiClient.saveTokens()`. The auth flow must write to both SharedPreferences (for the datasource) and FlutterSecureStorage (for the Dio interceptor).

---

### 4. 401 Interceptor Firing on Auth Endpoints
**Symptom:** After entering wrong credentials once, unable to login with correct credentials on subsequent attempts.
**Root Cause:** The Dio `onError` interceptor in `api_client.dart` fires on EVERY 401 response, including `/auth/login` and `/auth/register` 401s. It tries to refresh the token, which fails (no valid refresh token after a bad login), polluting the Dio instance state.
**Fix:** Added a path check in the interceptor:
```dart
final path = error.requestOptions.path;
if (path.contains('/auth/login') || path.contains('/auth/register') || path.contains('/auth/refresh')) {
  return handler.next(error); // Skip refresh for auth endpoints
}
```
**Files Changed:** `lib/data/api_client.dart`
**Prevention:** Always add auth endpoint paths to the skip list in the interceptor.

---

## Screen Loading Issues

### 5. Eternal Loading (Black Screen) When No BabyMon Exists
**Symptom:** After login, all 7 tab screens show a perpetual spinner.
**Root Cause:** Every screen's `_loadData()` method calls `api.getSelectedBabyMonId()` and does `if (id == null) return;` — but never sets `_isLoading = false`. Since `_isLoading` defaults to `true`, the build method shows a `CircularProgressIndicator` forever.
**Fix:** Added `setState(() => _isLoading = false);` before the early return in all 7 screen files. Also added a "Welcome to BabyMon! Create one to get started" UI state on Dashboard when `_babyMonId` is null.
**Files Changed:** `dashboard_screen.dart`, `milestones_screen.dart`, `feeding_screen.dart`, `health_screen.dart`, `sleep_screen.dart`, `album_screen.dart`, `journal_screen.dart`
**Prevention:** Always call `setState(() => _isLoading = false)` before ANY early return in data-loading methods.

---

### 6. Missing `_isLoading = false` in Partners Screen
**Symptom:** Partners screen shows eternal spinner.
**Root Cause:** Same pattern as issue #5, but for the `_loadData()` method in `partners_screen.dart`.
**Fix:** Added `if (mounted) setState(() => _isLoading = false);` before return when no BabyMon exists.
**Prevention:** Same as #5.

---

## Null Safety Issues

### 7. Null Check Operator on Creation Dialogs
**Symptom:** App crashes with "Null check operator used on a null value" when tapping FAB on Milestones, Feeding, Health, or Sleep screens.
**Root Cause:** Creation dialogs call `api.createXxx(_babyMonId!, ...)` but `_babyMonId` is null when no BabyMon exists.
**Fix:** Added `if (_babyMonId == null) return;` guards before all `_babyMonId!` usages in creation dialogs.
**Files Changed:** `milestones_screen.dart`, `feeding_screen.dart`, `health_screen.dart`, `sleep_screen.dart`
**Prevention:** Never use `!` (null assertion) on `_babyMonId`. Always guard with null check.

---

### 8. Null Check on Partner Invite
**Symptom:** "Error sending invite: Null check operator used on a null value" when inviting a partner.
**Root Cause:** `_invitePartner()` calls `ref.read(apiClientProvider).invitePartner(_babyMonId!, email, role)` but `_babyMonId` is null.
**Fix:** Added `if (_babyMonId == null) { show snackbar; return; }` guard.
**Files Changed:** `partners_screen.dart`
**Prevention:** Same as #7.

---

## Flutter Widget Issues

### 9. SegmentedButton Assertion Error
**Symptom:** Red screen on Create BabyMon: `'selected.length > 0 || emptySelectionAllowed': is not true.`
**Root Cause:** Gender `SegmentedButton` had `selected: _gender != null ? {_gender!} : {}`. When `_gender` was null, the selected set was `{}` (empty), violating the widget's assertion.
**Fix:** Changed `String? _gender;` → `String _gender = 'MONIOUS';` and `selected: {_gender}`.
**Files Changed:** `create_baby_mon_screen.dart`
**Prevention:** Always provide a default value for SegmentedButton selections, or set `emptySelectionAllowed: true`.

---

### 10. GoRouter.pop() Doesn't Work on go()-Navigated Routes
**Symptom:** Back buttons on Settings and Create BabyMon screens do nothing.
**Root Cause:** Settings is navigated via `GoRouter.of(context).go('/settings')` which replaces the route. There is no Navigator stack entry to pop.
**Fix:** Changed `GoRouter.of(context).pop()` → `GoRouter.of(context).go('/home')`.
**Files Changed:** `settings_screen.dart`, `create_baby_mon_screen.dart`
**Prevention:** Use `.go()` for top-level routes, `.pop()` only for pushed routes (e.g., `Navigator.push`).

---

## Compilation Errors

### 11. Duplicate Import of `apiClientProvider`
**Symptom:** Compile error: `'apiClientProvider' is imported from both 'package:baby_mon/core/providers.dart' and 'package:baby_mon/presentation/providers/auth_provider.dart'`.
**Root Cause:** Settings screen imported from both files, each defining the same-named provider.
**Fix:** Removed `import 'package:baby_mon/core/providers.dart';` from settings_screen.dart.
**Prevention:** Only import `apiClientProvider` from `presentation/providers/auth_provider.dart`.

---

### 12. Wrong Relative Import Paths in MainScreen
**Symptom:** Compile error: `Error when reading '../dashboard/dashboard_screen.dart': The system cannot find the path specified.`
**Root Cause:** MainScreen imported screens with `../dashboard/dashboard_screen.dart` but all screens are siblings in the `main/` directory.
**Fix:** Changed to `dashboard/dashboard_screen.dart` (no `../`).
**Files Changed:** `main_screen.dart`
**Prevention:** Verify relative paths — or better, use `package:baby_mon/` prefix.

---

### 13. `const` IndexedStack with Non-Const Children
**Symptom:** Compile error: `Not a constant expression` for all 7 screen constructors in MainScreen.
**Root Cause:** `children: const [DashboardScreen(), ...]` — the screen constructors aren't `const`.
**Fix:** Changed to `children: <Widget>[const DashboardScreen(), ...]` or just `children: [...]` + used `const` on each screen constructor.
**Files Changed:** `main_screen.dart`
**Prevention:** Avoid `const` on the parent list if children aren't const.

---

### 14. `num` → `double` Type Mismatch in Growth Chart
**Symptom:** Compile error: `The argument type 'num' can't be assigned to the parameter type 'double?'` for `minX`, `maxX`, `minY`, `maxY`.
**Root Cause:** `dart:math` reduction operations return `num`, but `fl_chart` LineChartData expects `double?`.
**Fix:** Added `.toDouble()` calls: `minX: minX.toDouble(), maxX: maxX.toDouble(), ...`.
**Files Changed:** `growth_chart_screen.dart`
**Prevention:** Cast `num` types explicitly when passing to `double?` parameters.

---

### 15. `DateTime.now().minute` in Const Expression
**Symptom:** Compile error: `Cannot invoke a non-'const' constructor where a const expression is expected.`
**Root Cause:** `DateTime.now().subtract(const Duration(minutes: DateTime.now().minute))` uses `.minute` in a const Duration.
**Fix:** Extracted `final now = DateTime.now();` and used `Duration(minutes: now.minute)` without `const`.
**Files Changed:** `sleep_screen.dart`
**Prevention:** `const Duration(...)` requires compile-time constant arguments. Use non-const for dynamic values.

---

## Feature Gaps

### 16. No Password Visibility Toggle
**Fix:** Added `_obscurePassword` state + `suffixIcon: IconButton` with visibility icons to both login and register screens.

### 17. No Forgot Password Flow
**Fix:** Added "Forgot Password?" link → bottom sheet with email field → calls `/api/auth/forgot-password`.

### 18. No Biometric Login
**Fix:** Added `local_auth` package + biometric check in login screen + fingerprint button + opt-in flow.

### 19. No Back Button on Create BabyMon
**Fix:** Added `leading: IconButton(arrow_back)` navigating to `/home`.

### 20. Login Doesn't Clear Stale Error
**Fix:** Changed `state.copyWith(isLoading: true)` → `state.copyWith(isLoading: true, error: null)` in login/register.

### 21. Raw DioException Displayed to User
**Fix:** Wrapped API calls in `on DioException catch (e)` → extracted `e.response?.data?['message']`.

---

### 22. Hero Tag Conflict — Duplicate FAB Tags
**Symptom:** App crashes with "There are multiple heroes that share the same tag within a subtree."
**Root Cause:** AlbumScreen had two FABs (camera + gallery) both using default hero tags. When IndexedStack switches tabs, Flutter's Hero system detects duplicate default tags.
**Fix:** Replaced two FABs with a single FAB (`heroTag: 'album_fab'`) that shows a source picker dialog.
**Files Changed:** `album_screen.dart`

---

### 23. Backend Down → Misleading "no status: no response body"
**Symptom:** Registration shows "Registration failed (nostatus): no responce body"
**Root Cause:** The NestJS backend wasn't running. Dio couldn't connect, so there was no HTTP response at all — no status code, no body.
**Fix:** Restart backend with `cd apps/api && npm run start:dev`. Added better error message including "no status" to indicate missing backend.
**Prevention:** Always verify backend is running: `curl http://localhost:3000/api/health`

---

### 24. Provider Import/Export Pattern (Final Architecture)
**Symptom:** 40+ "undefined name 'apiClientProvider'" compile errors across all screens
**Root Cause:** After moving provider to single source of truth, the import/export chain was incorrect. `export` alone doesn't make a symbol available within the exporting file — `import` is needed too.
**Final Architecture:**
- `core/providers.dart` — defines `final apiClientProvider = ...` (SINGLE DEFINITION)
- `presentation/providers/auth_provider.dart` — both `import` (for internal use) AND `export` (for consumers)
**Files Changed:** `core/providers.dart`, `auth_provider.dart`
**Prevention:** Never define `apiClientProvider` in more than one file. Use import+export pattern.

---

### 25. Backend Response Paginated Wrapper vs Raw Array Cast
**Symptom:** Data entered via create dialog, backend returns 201 + 200 with content, but screen stays on "No records yet" empty state. No error shown.
**Root Cause:** Backend services return `{ items: [...], total, skip, take }` but all Flutter screens parse `response.data as List` directly. Casting a `Map` to `List` throws silently inside `try/catch`, which sets `_isLoading = false` with empty data.
**Fix:** Changed to `(response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? []` across 8 instances in 6 files.
**Files Changed:** `milestones_screen.dart`, `feeding_screen.dart`, `health_screen.dart`, `sleep_screen.dart`, `album_screen.dart`, `journal_screen.dart`, `dashboard_screen.dart` (badges + growth records).
**Prevention:** Always check if the backend wraps responses in paginated envelopes before writing UI parsing code.

### 26. Swipe-to-Delete Deletes Entry Even on Cancel
**Symptom:** Swiping an activity left shows a "Delete / Cancel" dialog. Choosing "Cancel" still removes the entry from the screen.
**Root Cause:** `Dismissible` widgets used `onDismissed` which fires AFTER the swipe animation completes. The dialog appeared but the entry was already visually gone.
**Fix:** Changed `onDismissed` → `confirmDismiss` across 4 screens (milestones, feeding, health, sleep). Changed delete methods from `Future<void>` → `Future<bool>` returning `false` on cancel, `true` on success.
**Prevention:** Always use `confirmDismiss` for Dismissible widgets that require user confirmation.

### 27. Raw DioException 404 Shown to User on Unimplemented Backends
**Symptom:** After creating a BabyMon, an error appears: "DioException [bad response]: This exception was thrown because the response has a status code of 404..."
**Root Cause:** All 8 screens reload simultaneously on BabyMon creation. Sleep, Album, Journal, and Badges endpoints return 404 because their NestJS backends were never built. The catch blocks displayed the raw `DioException` to the user.
**Fix:** Sleep screen: removed SnackBar from _fetchSleepLogs catch. Album + Journal: silenced 404 with comment. Dashboard: added comments on optional fetches. CreateBabyMon: improved error handler to show "Server error. Please try again." instead of raw DioException strings.
**Files Changed:** `sleep_screen.dart`, `album_screen.dart`, `journal_screen.dart`, `dashboard_screen.dart`, `create_baby_mon_screen.dart`
**Prevention:** Never display raw `DioException.toString()` to users. Catch HTTP errors and show human-readable messages.

### 28. Missing Backend Endpoints (Blocking Features)
The following NestJS backend endpoints are missing, preventing these features from working:

| Endpoint | Feature | Status |
|---|---|---|
| `GET/POST /api/baby-mons/:id/sleep-logs` | Sleep Tracking | **No module exists** |
| `GET /api/baby-mons/:id/photos` | Photo Album | Routes use `/media` not `/photos` |
| `GET /api/baby-mons/:id/journal` | Journal | Only `@Post('journal')` exists, no `@Get` |
| `GET /api/baby-mons/:id/badges` | Badges | Service throws NotFoundException |

These require NestJS backend changes — not fixable from the Flutter side.

### 29. Two auth_provider.dart Files (Active vs Dead Code)
**Symptom:** Fixes applied to auth_provider.dart have no effect on the running app.
**Root Cause:** The project has two `auth_provider.dart` files:
- `lib/presentation/providers/auth_provider.dart` — **ACTIVE** (imported by all screens)
- `lib/features/auth/presentation/providers/auth_provider.dart` — **DEAD CODE** (never imported)
**Prevention:** Before editing any file with a duplicate name, check which one is actually imported by the screens using it.

### 30. Album Camera Button Not Wired
**Symptom:** Album screen only has a gallery picker, no camera option.
**Fix:** Added second mini FAB (`heroTag: 'album_camera_fab'`) calling `_pickFromCamera` (method already existed but was never connected). FABs stacked in Column: camera (mini) above gallery.
**Files Changed:** `album_screen.dart`

### 31. CONCEIVED Stage Requires lmpDate in Addition to conceptionDate
**Symptom:** When creating a BabyMon with "Expecting" (CONCEIVED) stage: "lmpDate must be a valid ISO 8601 date string" error.
**Root Cause:** The NestJS DTO (CreateBabyMonDto) has `@ValidateIf(o => o.stageStartType === 'CONCEIVED')` on both `conceptionDate` AND `lmpDate`. The Flutter screen only sent `conceptionDate`.
**Fix:** Modified `create_baby_mon_screen.dart` to send both `conceptionDate` and `lmpDate` (same value) when stage is CONCEIVED.
**Files Changed:** `create_baby_mon_screen.dart`
**Prevention:** Always check backend DTO validation rules when adding new form fields. Each `@ValidateIf` conditional requires its corresponding field to be sent.

### 32. Emulator Crash from Re-entrant Loading
**Symptom:** Android emulator crashes when refreshing the app or switching BabyMons. Multiple simultaneous HTTP requests overwhelm the emulator.
**Root Cause:** `_loadData()` could be called simultaneously from `ref.listenManual(appRefreshProvider)`, `didChangeAppLifecycleState`, and hot restart. Additionally, `_switchBabyMon()` bumped `appRefreshProvider` causing all 8 screens to reload at once (~30+ concurrent HTTP requests). The `getBabyMons()` endpoint returns ~5859 bytes of JSON and was called on every refresh cycle.
**Fix:** (1) Added `_loadInProgress` re-entrancy guard — prevents concurrent `_loadData()` calls. (2) Cached all BabyMons list (`if (_allBabyMons.isEmpty)` check) so it's only fetched once. (3) Changed `_switchBabyMon()` to call `_loadData()` directly instead of bumping the global `appRefreshProvider`.
**Files Changed:** `dashboard_screen.dart`
**Prevention:** Always use re-entrancy guards for any async method that can be triggered from multiple sources. Cache expensive API calls that don't change frequently.

### 33. BabyMon Details View & Multi-BabyMon Selector
**Feature:** Dashboard now shows expandable BabyMon details and supports switching between multiple BabyMons.
**Implementation:**
- Stage card is now a `GestureDetector` — tap expands to show traits, special move, stage type, and gender
- `_showDetails` state toggles "Tap for details ▼" / "Hide details ▲" indicator
- `_allBabyMons` list fetched once via `getBabyMons()` and cached
- Dropdown selector appears only when more than 1 BabyMon exists
- `_switchBabyMon()` updates `selectedBabyMonId` in storage and reloads dashboard only (not all 8 screens)
**Files Changed:** `dashboard_screen.dart`

### 34. Token Refresh Stampede — Emulator Crash
**Symptom:** Android emulator crashes shortly after app launch or during use. Backend logs show 8+ simultaneous `POST /api/auth/refresh` calls followed by 429 rate limit responses.
**Root Cause:** When the JWT expires (15 min), all 8 IndexedStack tab screens detect 401 simultaneously. Each screen's Dio interceptor independently triggers `_refreshToken()`, creating 8+ parallel refresh requests. Some hit the backend's 429 rate limit, and the emulator's HTTP client becomes overwhelmed.
**Fix:** Added a refresh gate with request queuing to `api_client.dart`:
- `_isRefreshing` flag — only ONE refresh call fires at a time
- `_pendingRetries` list — all other 401 requests queue their retry callbacks
- After the single refresh succeeds, ALL queued requests are retried with the new token
- If refresh fails, no requests are retried (app shows 401 gracefully)
**Files Changed:** `lib/data/api_client.dart`
**Prevention:** Always serialize token refresh operations to prevent parallel refresh calls. Use a boolean gate + callback queue pattern.

---

### 35. 5 Missing Backend Endpoints Causing 404s
**Symptom:** Sleep screen, album upload, journal GET, badges, and partners all return 404 Not Found.
**Root Cause:** The backend was missing entire modules or route registrations for these features:
- `sleep-logs` — No NestJS module existed at all
- `photos` — Flutter calls `/photos` but backend only had `/media` routes
- `journal GET` — Controller only had `@Post('journal')`, no GET handler
- `badges` — `BabyMonBadgesController` was defined but never registered in `BadgesModule`
- `partners` — No `baby-mons/:id/partners` route existed
**Fix:**
- Created full `SleepLogsModule` with DTO, service, controller, module + `SleepLog` model in Prisma schema
- Created `PhotosController` delegating to `MediaService` for all `/photos` routes
- Changed `@Post('journal')` to `@Get('journal')` with optional `?type=` query param
- Registered `BabyMonBadgesController` in `BadgesModule` controllers array
- Added `getPartnersForBabyMon()` to `LinkedAccountsService` + `GET baby-mons/:id/partners` route
- Changed `LinkedAccountsController` from `@Controller('linked-accounts')` to `@Controller()` for mixed route prefixes
**Files Changed:** `sleep-logs/` (4 new files), `media/photos.controller.ts`, `media/media.module.ts`, `journal/journal.controller.ts`, `badges/badges.module.ts`, `linked-accounts/` (2 files), `prisma/schema.prisma`, `app.module.ts`
**Prevention:** Always ensure controllers are registered in their module's `controllers` array. When adding a new sub-resource, create a complete module following the feed-logs/health-records pattern.

---

### 36. Activity Cross-Contamination Between BabyMons
**Symptom:** Creating a milestone on BabyMon A shows it on BabyMon B after switching via dropdown. Creating a new BabyMon clears all activities from all existing BabyMons.
**Root Cause:** `_switchBabyMon()` in `dashboard_screen.dart` only called `setSelectedBabyMonId()` and reloaded the dashboard — it did NOT bump `appRefreshProvider`. The other 7 IndexedStack screens retained their stale `_babyMonId` from `initState`. When activities were created, they went to the correct BabyMon in the database, but the screens displayed whatever was cached. When a new BabyMon was created, `appRefreshProvider` finally fired, causing all screens to reload with whatever ID was in storage at that moment.
**Fix:** Changed `_switchBabyMon()` to bump `appRefreshProvider` after saving the new ID. This triggers all 8 screens to reload with the correct BabyMon ID, ensuring activity segregation.
**Files Changed:** `dashboard_screen.dart`
**Prevention:** Any BabyMon-switching mechanism MUST trigger a global refresh of all screens via `appRefreshProvider`. Simply saving the new ID and reloading one screen is insufficient due to the IndexedStack architecture where all screens share the same state lifecycle.

---

### 37. Dashboard Age Not Showing + Stage Card Crash (evolution vs. BabyMon response mismatch)
**Symptom:** `_babyMonAge` always returned empty string. Stage card crashed with `type 'int' is not a subtype of type 'String'` when accessing `_evolution['currentStage']`.
**Root Cause:** Two issues:
1. **Age**: `_babyMonAge` read `_evolution['referenceDate']` which doesn't exist in the evolution endpoint response. The evolution endpoint returns `{ babyMon: { currentStage (int), currentXp }, stageInfo, xpProgress }` — no dates. Dates (`birthDate`, `conceptionDate`, `ideaDate`) live in the BabyMon model, returned by `getBabyMon()`.
2. **Stage crash**: `_evolution['currentStage']` is stored as `Int` in Prisma (numeric level, e.g., `1`), not the string label (`'BORN'`). The dashboard was treating it as a string to build labels like `"Born"` and emojis.
**Fix:**
- Store `_referenceDate` (a `DateTime?`) extracted from the `getBabyMon()` response based on `_stageStartType`: `birthDate` for BORN, `conceptionDate`/`lmpDate` for CONCEIVED, `ideaDate` for IDEA.
- Use `_stageStartType` (the string field from BabyMon, already stored) for `_stageEmoji()` and `_stageLabel()` instead of `_evolution['currentStage']`. The stage type values are exactly `'BORN'`, `'CONCEIVED'`, or `'IDEA'`.
- Also flatten the nested evolution response (`evoBabyMon`) so fields like `currentXp` are accessible directly.
**Files Changed:** `dashboard_screen.dart`
**Prevention:** Never assume the evolution endpoint returns date fields or string stage labels. Use `getBabyMon()` for dates and `_stageStartType` for stage display. The evolution endpoint is for XP/level data only.

---

### 38. Gender Mapping Confusion (MONIOUS vs MO)
**Symptom:** Dashboard shows wrong colors/emoji for BabyMon genders. Edit dialog dropdown labels are backwards. Colors inconsistent across different screens.
**Root Cause:** Gender mapping was incorrect throughout the codebase. The correct mapping from the Prisma schema is:
- `MONIOUS` = Male (light blue, `Colors.lightBlue.shade50/200`, emoji: 👶‍♂️)
- `MO` = Neutral (purple, `Colors.purple.shade50/200`, emoji: 👶)
- `MONIESE` = Female (pink, `Colors.pink.shade50/200`, emoji: 👶‍♀️)

Previous code had MONIOUS labeled as "Neutral" and MO labeled as "Male" — exactly backwards.
**Fix:** Updated `_genderColor()`, `_genderAccent()`, `_stageEmoji()`, `_detailRow()`, and the edit dialog `DropdownButtonFormField` across `dashboard_screen.dart`, `main_screen.dart`, and any other files referencing gender.
**Files Changed:** `dashboard_screen.dart`, `main_screen.dart`
**Prevention:** Always verify the Prisma schema for correct gender enum values: MONIOUS = Male, MO = Neutral, MONIESE = Female. Never swap them.

---

### 39. Age-Based Stage Names (Fetus/Neonate/Infant/Toddler/etc.)
**Symptom:** Dashboard always showed "Born" for BORN stage regardless of actual age.
**Root Cause:** Original `_stageLabel` only checked `_stageStartType` and returned "Born" / "Expecting" / "Planning" — no age differentiation.
**Fix:** Rewrote `_stageLabel` getter to compute age-appropriate names from `_referenceDate`:
- CONCEIVED → "Fetus"
- BORN + 0–28 days → "Neonate"
- BORN + 1–12 months → "Infant"
- BORN + 1–3 years → "Toddler"
- BORN + 3–5 years → "Preschooler"
- BORN + 5+ years → "Child"
**Files Changed:** `dashboard_screen.dart`
**Prevention:** Stage labels should be age-aware, not just stage-type-aware.

---

### 40. Dedicated Allergy + MedicalTeam Tables (Not HealthRecord Subtypes)
**Symptom:** Allergies and medical team members were formerly stored as generic HealthRecord entries with category types ALLERGY / MEDICAL_TEAM. This caused issues with querying, duplicate detection, and type safety.
**Root Cause:** Allergies and MedicalTeam are domain entities that deserve their own tables with proper constraints, not polymorphic HealthRecord entries.
**Fix:** Created two dedicated Prisma models:
- `Allergy` model: id, babyMonId, userId, name, triggers, severity, treatment, notes — with `@@unique([babyMonId, name])` for duplicate prevention
- `MedicalTeam` model: id, babyMonId, userId, name, specialty, facility, notes — with `@@unique([babyMonId, name])`, indexed by facility and specialty
- Backend modules: `apps/api/src/allergies/` and `apps/api/src/medical-team/` with full CRUD controllers at `/api/baby-mons/:id/allergies` and `/api/baby-mons/:id/medical-team`
- AllergiesService.create() throws 409 Conflict on duplicate name per BabyMon — Flutter UI must catch and display "This allergy is already recorded"
- MedicalTeamService.create() throws 409 Conflict on duplicate name per BabyMon
- Both registered in `app.module.ts` after HealthRecordsModule
- Flutter ApiClient methods: `getAllergies()`, `createAllergy()`, `deleteAllergy()`, `getMedicalTeam()`, `createMedicalTeamMember()`, `deleteMedicalTeamMember()`
**Files Changed:** `apps/api/prisma/schema.prisma`, `apps/api/src/allergies/*`, `apps/api/src/medical-team/*`, `apps/api/src/app.module.ts`, `apps/api/src/health-records/dto/health-record.dto.ts` (expanded enum), `apps/mobile/lib/data/api_client.dart`, `apps/mobile/lib/presentation/screens/main/health/health_screen.dart`
**Prevention:** Any domain entity that needs unique constraints, dedicated querying, or type-specific fields should get its own Prisma model and REST module — NOT be crammed into a generic HealthRecord.


### 41. Null Safety — `_babyMonId!` Without Guards on 7 Screens
**Symptom:** App crashes with "Null check operator used on a null value" when tapping FAB or pulling to refresh with no BabyMon selected.
**Root Cause:** `_fetch*()` methods and FAB dialog handlers in 7 screens used `_babyMonId!` without null guards. Methods like `_fetchMilestones()` are called from `onRefresh` callbacks and after-save paths that don't have the null check from `_loadData()`.
**Fix:** Added `if (_babyMonId == null) return;` as the first line in every `_fetch*()` method and FAB/create dialog handler. Also changed journal's `String _babyMonId = ''` to `String? _babyMonId` for consistency.
**Files Changed:** `milestones_screen.dart`, `feeding_screen.dart`, `health_screen.dart`, `sleep_screen.dart`, `album_screen.dart`, `journal_screen.dart`, `partners_screen.dart`
**Prevention:** Every method using `_babyMonId!` needs its own null guard — don't rely on `_loadData()` as the sole gate.

### 42. Loading State — Re-entrancy Guard Skips Spinner Reset
**Symptom:** Dashboard shows perpetual loading spinner if `_loadData()` is called while a previous invocation is still in progress and the provider init throws before `finally{}` runs.
**Root Cause:** The re-entrancy guard `if (_loadInProgress) return;` in `_loadData()` returned without calling `setState(() => _isLoading = false)`. If `_loadInProgress` was left `true` by a failed invocation, spinner stayed forever.
**Fix:** Changed the guard to:
```dart
if (_loadInProgress) {
  setState(() => _isLoading = false);
  return;
}
```
**Files Changed:** `dashboard_screen.dart`
**Prevention:** Re-entrancy guards that skip data loading MUST still clear the loading state so the UI doesn't get stuck.

---

*Document Version: 10.0 · Last Updated: June 6, 2026*
