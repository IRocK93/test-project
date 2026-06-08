# BabyMon — Architecture Overview

> **Last Updated:** June 5, 2026 (v9.0 — Universal units, health FAB, notifications endDrawer, solid piece)

---

## 1. Flutter Layered Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                          │
│  Screen widgets (ConsumerStatefulWidget), Riverpod providers,  │
│  GoRouter navigation. Imports from domain + data layers.       │
│  Files: presentation/screens/, presentation/providers/,        │
│         presentation/router/                                   │
├────────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                             │
│  Entities (User, BabyMon), Repository interfaces (abstract),   │
│  Use cases. Pure Dart — zero Flutter/dependencies.             │
│  Files: features/*/domain/                                     │
├────────────────────────────────────────────────────────────────┤
│                        DATA LAYER                              │
│  ApiClient (Dio wrapper), Remote datasources, Repository impl. │
│  Local storage (Drift SQLite, SharedPreferences, SecureStorage)│
│  Files: data/api_client.dart, features/*/data/                 │
├────────────────────────────────────────────────────────────────┤
│                         CORE LAYER                             │
│  Constants (API paths, colors, storage keys), OAuth services.  │
│  Files: core/constants/, core/services/                        │
└────────────────────────────────────────────────────────────────┘
```

## 2. NestJS Backend Layers

```
Controller (routes) → Service (business logic) → PrismaService (DB)
AuthGuard (JWT)    → AccessControlService (permissions)
```

All routes under `/api` global prefix. 20+ modules registered in `app.module.ts`.

---

## 3. Provider Registry (Flutter Riverpod)

| Provider | File | Type |
|----------|------|------|
| `apiClientProvider` | `presentation/providers/auth_provider.dart` | `Provider<ApiClient>` |
| `sharedPreferencesProvider` | `presentation/providers/auth_provider.dart` | `Provider<SharedPreferences>` |
| `authRemoteDatasourceProvider` | `presentation/providers/auth_provider.dart` | `Provider<AuthRemoteDatasource>` |
| `authRepositoryProvider` | `presentation/providers/auth_provider.dart` | `Provider<AuthRepository>` |
| `authProvider` | `presentation/providers/auth_provider.dart` | `StateNotifierProvider<AuthNotifier, AuthState>` |
| `isLoggedInProvider` | `presentation/providers/auth_provider.dart` | `Provider<bool>` |

⚠️ `core/providers.dart` is DEPRECATED — `apiClientProvider` has been removed from there.

---

## 4. Storage Map

| Storage | Used For | Key Examples |
|---------|----------|-------------|
| **FlutterSecureStorage** | Dio interceptor auth, selected BabyMon ID | `access_token`, `refresh_token`, `user_id`, `selected_baby_mon_id` |
| **SharedPreferences** | Auth datasource token cache, biometric preference | `accessToken`, `userId`, `userEmail`, `biometrics_enabled` |
| **Drift SQLite** | Offline-first local database (milestones, feed logs, health records) | Local tables for each entity |

---

## 5. GoRouter Route Map

| Route | Screen | Auth Required | Notes |
|-------|--------|---------------|-------|
| `/` | SplashScreen | No | Redirects to /home if logged in |
| `/login` | LoginScreen | No | Email/password + OAuth + biometric |
| `/register` | RegisterScreen | No | Navigates to /verify-email after |
| `/verify-email` | VerificationScreen | No | Query param: `email` |
| `/reset-password` | ResetPasswordScreen | No | Query param: `token` |
| `/create-baby-mon` | CreateBabyMonScreen | Yes | Name, stage, gender, traits |
| `/home` | MainScreen | Yes | Bottom nav shell |
| `/settings` | SettingsScreen | Yes | Profile, sub, partners, export |

---

## 6. Component Tree — MainScreen

```
MainScreen (ConsumerStatefulWidget)
├── AppBar (gender-colored BabyMon selector pill @ 55% width + hamburger menu → Drawer + notifications bell icon)
├── Drawer (7 tabs + Settings + Partners + Logout)
├── IndexedStack (index: _currentIndex)
│   ├── [0] DashboardScreen    — Age-appropriate stages (Fetus→Child), compact cards, XP, badges (all locked shown), quick stats, single FAB
│   ├── [1] MilestonesScreen   — Baby milestone CRUD
│   ├── [2] FeedingScreen      — Breastmilk/formula/solid logs with Metric/Imperial toggle + auto-unit
│   ├── [3] HealthScreen       — Weight/Height/Head Circumference/Body Temperature + Vax/Visit/Other with Metric/Imperial toggle
│   ├── [4] SleepScreen        — Nap/night sleep tracking
│   ├── [5] AlbumScreen        — Photo timeline
│   └── [6] JournalScreen      — Unified feed with proposals
└── BottomNavigationBar (7 tabs, fixed type)
    └── FAB (Dashboard: quick actions, Journal: new entry)
```

SettingsScreen → SubscriptionScreen, PartnersScreen
HealthScreen → GrowthChartScreen, SleepScreen
```

---

## 7. State Management Pattern

```
Screen (ConsumerStatefulWidget)
  → ref.read(apiClientProvider)        // API calls (one-shot read)
  → ref.watch(authProvider)            // Auth state (reactive)
  → setState(...)                      // Local UI state (_isLoading, data lists)
```

Riverpod `StateNotifierProvider` for auth state. Local `setState` for per-screen data loading.

---

## 8. NestJS Module Map

| Module | Controller | Base Path |
|--------|-----------|-----------|
| AuthModule | AuthController | `/api/auth` |
| UsersModule | UsersController | `/api/users` |
| BabyMonModule | BabyMonController | `/api/baby-mons` |
| MilestonesModule | MilestonesController | `/api/baby-mons/:id/milestones` |
| FeedLogsModule | FeedLogsController | `/api/baby-mons/:id/feed-logs` |
| HealthRecordsModule | HealthRecordsController | `/api/baby-mons/:id/health-records` |
| AllergiesModule | AllergiesController | `/api/baby-mons/:id/allergies` |
| MedicalTeamModule | MedicalTeamController | `/api/baby-mons/:id/medical-team` |
| BadgesModule | BadgesController, BabyMonBadgesController | `/api/badges`, `/api/baby-mons/:id/badges` |
| SleepLogsModule | SleepLogsController | `/api/baby-mons/:id/sleep-logs` |
| EvolutionModule | EvolutionController | `/api/baby-mons/:id/evolution` |
| GrowthModule | GrowthController | `/api/baby-mons/:id/growth` |
| JournalModule | JournalController | `/api/baby-mons/:id/journal` (GET + POST) |
| ExportModule | ExportController | `/api/baby-mons/:id/export` |
| SubscriptionsModule | SubscriptionsController | `/api/subscriptions` |
| StageContentModule | StageContentController | `/api/stage-content` |
| MediaModule | MediaController, PhotosController | `/api/baby-mons/:id/media`, `/api/baby-mons/:id/photos` |
| NotificationsModule | NotificationsController | `/api/notifications` |
| LinkedAccountsModule | LinkedAccountsController | `/api/linked-accounts`, `/api/baby-mons/:id/partners` |
| AdminModule | AdminController | `/api/admin` |
| StripeModule | StripeController | `/api/subscriptions` |
| StripeWebhookModule | StripeWebhookController | `/api/webhooks/stripe` |
| HealthModule | HealthController | `/api/health` |
| PrismaModule | — | Global |

---

## 9. Dashboard Data Flow (Critical)

The Dashboard has a specific data flow that must be followed:

### Stage Display
- `_stageStartType` (string: `'BORN'`, `'CONCEIVED'`, `'IDEA'`) comes from `getBabyMon()` response — **DO NOT** use `_evolution['currentStage']` which is an `Int` in Prisma (numeric level, e.g., `1`)
- `_stageEmoji()` and `_stageLabel()` both use `_stageStartType`

### Reference Dates (for Age/ETA)
- Dates (`birthDate`, `conceptionDate`, `lmpDate`, `ideaDate`) are extracted from `getBabyMon()` response as `_referenceDate` (`DateTime?`)
- Based on `_stageStartType`:
  - `'BORN'` → uses `birthDate`
  - `'CONCEIVED'` → uses `conceptionDate` || `lmpDate`
  - `'IDEA'` → uses `ideaDate`
- The **evolution endpoint has NO date fields** — it returns `{ babyMon: { currentStage (int), currentXp }, stageInfo, xpProgress }`

### Evolution Response Flattening
```dart
final evoData = evolutionRes.data as Map<String, dynamic>;
final evoBabyMon = (evoData['babyMon'] as Map<String, dynamic>?) ?? {};
final evolution = <String, dynamic>{...evoData, ...evoBabyMon};
```
This flattens the nested `babyMon` fields so `currentXp` is accessible directly.

### Age-Appropriate Stage Names
Computed in `_stageLabel` getter from `_referenceDate`:

| Age Range | Stage Name | Condition |
|-----------|-----------|-----------|
| Conception → Birth | Fetus | `_stageStartType == 'CONCEIVED'` |
| 0–28 days | Neonate | `ageInDays <= 28` |
| 1–12 months | Infant | `ageInDays <= 365` |
| 1–3 years | Toddler | `ageInDays <= 1095` |
| 3–5 years | Preschooler | `ageInDays <= 1825` |
| 5+ years | Child | default |

### Universal Metric/Imperial Setting
A **single global setting** controlled from the Settings screen determines units across the entire app. Individual screen toggles have been removed.

- **Key:** `measurement_units` stored in SharedPreferences (`"metric"` or `"imperial"`), exported as `const String measurementUnitsKey` from `settings_screen.dart`.
- **Default**: Metric
- **Settings UI:** `SegmentedButton<bool>` in Settings → reads/writes SharedPreferences.
- **All forms read** from `SharedPreferences.getInstance().getString(measurementUnitsKey)` at open time — no need to pass state between screens.

**Feeding units** (auto from global setting + solid adds piece option):
- Breastmilk/Formula: `ml` / `fl oz`
- Solid: `g` / `oz` — with Weight/Piece toggle for individual items

**Health units** (auto from global setting):
- Weight: `kg` / `lbs`
- Height: `cm` / `in`
- Head Circumference: `cm` / `in`
- Body Temperature: `°C` / `°F`

### Health Screen: Expandable FAB
The health screen "+" FAB expands into a fan-out menu with 3 mini-FABs:
- **Measurements** (teal): Weight, Height, Head Circumference, Body Temperature — single form with SegmentedButton for type
- **Event** (orange): Opens picker then shows type-specific form with dynamic fields:
  - Hospital/Clinic: Name + Reason + Outcome + Date
  - Injury: Reason + Severity + Description
  - Bowel Movement: Time + Color + Type (Normal/Diarrhea/Constipation)
  - Vaccination: Vaccine Name + Date + Location + Venue
  - Other: Simple title/notes
- **Medical Team** (indigo): Coming Soon placeholder

### Notifications EndDrawer
The bell icon in the AppBar opens an `endDrawer` (slides from the right) with:
- "Coming Soon" placeholder
- Settings shortcut
- Create BabyMon shortcut (replaces the removed "+" AppBar button)

---

## Critical Patterns & Gotchas

### `/api` Prefix Rule
All Flutter API calls MUST include `/api` prefix because `apps/api/src/main.ts` has `app.setGlobalPrefix('api')`. 
- ✅ Correct: `_dio.get('/api/baby-mons/$id/badges')`
- ❌ Wrong: `_dio.get('/baby-mons/$id/badges')`
- Original bug: 38 of 45 typed methods in `api_client.dart` were missing `/api` — activities silently failed.

### Paginated Wrapper Response Pattern
Backend services return `{ items: [...], total, skip, take }`. Flutter screens must extract `items`:
```dart
_milestones = (response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? [];
```
Original bug: All screens used `response.data as List` — cast to Map crashed silently.

### Gender Mapping (MONIOUS/MO — June 5 Fix)
```
MONIOUS  = Male   (light blue)   — previously incorrectly labeled as Neutral
MO       = Neutral (purple)      — previously incorrectly labeled as Male
MONIESE  = Female  (pink)
```
Applies universally to `_genderColor()`, `_genderAccent()`, `_stageEmoji()`, `_detailRow()`, and the edit dialog dropdown.

### Riverpod Refresh Architecture
```dart
// core/providers.dart
final appRefreshProvider = StateProvider<int>((ref) => 0);
// Bump after create/delete — all 8 tab screens listen via ref.listenManual()
```
This solves IndexedStack not re-firing initState after BabyMon creation.

### BabyMon Switching: MUST Bump appRefreshProvider
When switching between BabyMons via the selector, `_switchBabyMon()` MUST call `ref.read(appRefreshProvider.notifier).state++` — not just `_loadData()`. All 8 IndexedStack screens need to reload with the new BabyMon ID.

### Swipe-to-Delete: Use confirmDismiss
`Dismissible` widgets must use `confirmDismiss` (not `onDismissed`) when showing confirmation dialogs.

### Error Handling: Never Show Raw DioException
Always catch `DioException` and show user-friendly messages.

### _loadInProgress Re-entrancy Guard
Standard for all IndexedStack screens — prevents concurrent load calls from Riverpod rebuilds:
```dart
bool _loadInProgress = false;
Future<void> _loadData() async {
  if (_loadInProgress) return;
  _loadInProgress = true;
  try { /* API calls */ } finally { _loadInProgress = false; }
}
```

### Compact Dashboard Sizing
Dashboard cards use `edgeInsets.all(12)`, emoji fontSize 36, `VisualDensity.compact`, `dense: true` for ExpansionTile. Single FAB (quick actions only — create BabyMon moved to AppBar selector).

### ✅ Previously Missing Backend Endpoints — ALL RESOLVED (June 4, 2026)
| Endpoint | Feature | Resolution |
|---|---|---|
| `GET/POST /api/baby-mons/:id/sleep-logs` | Sleep | ✅ New SleepLogsModule + SleepLog model in Prisma schema |
| `GET /api/baby-mons/:id/photos` | Photos | ✅ New PhotosController delegating to MediaService |
| `GET /api/baby-mons/:id/journal` | Journal | ✅ Changed `@Post` to `@Get` with optional `?type=` query |
| `GET /api/baby-mons/:id/badges` | Badges | ✅ BabyMonBadgesController registered in BadgesModule |
| `GET /api/baby-mons/:id/partners` | Partners | ✅ New `getPartnersForBabyMon()` method |

---

*Last Updated: June 5, 2026 (v9.0)*
