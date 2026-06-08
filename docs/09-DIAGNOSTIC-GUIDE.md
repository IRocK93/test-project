# BabyMon Diagnostic Guide — Complete Architecture Map & Bug Catalog

> **Purpose**: When something breaks, start here. This documents every known architectural quirk, dual-file pattern, and historic bug so future debugging is systematic, not guesswork.

---

## 0. QUICK REFERENCE — API Endpoint Pattern

**Golden Rule**: ALL Flutter HTTP calls MUST include `/api` prefix because the NestJS backend has:
```typescript
// apps/api/src/main.ts:33
app.setGlobalPrefix('api');
```

**Correct pattern**:
```dart
// Good ✅
return _dio.get('/api/baby-mons/$id/badges');
return _dio.post('/api/baby-mons/$id/milestones', data: data);

// Bad ❌ — missing /api, hits wrong route
return _dio.get('/baby-mons/$id/badges');
```

**Exception**: The generic `post()`, `get()`, `patch()`, `delete()` methods at the bottom of `api_client.dart` auto-prepend `/api`, so screens using those generic methods don't need it.

---

## 1. FILE ARCHITECTURE — DUAL FILES TO WATCH

### 1.1 Two `api_client.dart` files

| File | Package Import | Role |
|---|---|---|
| `apps/mobile/lib/data/api_client.dart` | `package:baby_mon/data/api_client.dart` | **PRIMARY** — All typed API methods, token storage, interceptors. 417 lines. |
| `apps/mobile/lib/core/data/api_client.dart` | `package:baby_mon/core/data/api_client.dart` | **WRAPPER** — Thin wrapper around `ApiService`. Only has generic HTTP methods. Missing `setSelectedBabyMonId`, `getSelectedBabyMonId`. |

**Critical**: The `apiClientProvider` in `core/providers.dart` imports from `../data/api_client.dart` (the primary one). But the secondary one also exists and is imported in different places by `package:`. If you see `getSelectedBabyMonId()` calls, they must use the primary ApiClient.

### 1.2 Two `auth_provider.dart` files

| File | Package Import | Status |
|---|---|---|
| `apps/mobile/lib/presentation/providers/auth_provider.dart` | `package:baby_mon/presentation/providers/auth_provider.dart` | **ACTIVE** — Imported by login_screen, register_screen, verification_screen, main screen |
| `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart` | `package:baby_mon/features/auth/presentation/providers/auth_provider.dart` | **DEAD CODE** — Not imported by any screen |

**Lesson**: Fixes applied to the dead-code file have zero effect. Always check which file is actually imported.

---

## 2. AUTHENTICATION FLOW

### 2.1 Token Storage

Tokens are stored in TWO places during login/register:

```dart
// auth_remote_datasource.dart — login()
await _apiClient.saveTokens(token, refreshToken, user.id);  // → FlutterSecureStorage
await _prefs.setString('accessToken', token);               // → SharedPreferences
```

| Storage | Key | Used By |
|---|---|---|
| FlutterSecureStorage | `access_token` | Dio interceptor — auto-injected into every request header |
| FlutterSecureStorage | `refresh_token` | 401 interceptor — refreshes expired tokens |
| FlutterSecureStorage | `selected_baby_mon_id` | All screens — determines which BabyMon to load |
| SharedPreferences | `accessToken` | isLoggedIn() check only (not for API calls) |

### 2.2 Token Refresh Flow

1. Dio interceptor detects 401 on any request
2. Skips auth endpoints (`/auth/login`, `/auth/register`, `/auth/refresh`)
3. Reads `refresh_token` from FlutterSecureStorage
4. POSTs to `{baseUrl}/api/auth/refresh` with body `{"refreshToken": "..."}`
5. On 200: stores new `access_token` and `refresh_token`
6. Retries original request with new token

**Bug fixed**: The refresh URL was `{baseUrl}/auth/refresh` (missing `/api`). Fixed to `{baseUrl}/api/auth/refresh`.

### 2.3 JWT Guard (Backend)

```typescript
// apps/api/src/common/guards/jwt-auth.guard.ts
export class JwtAuthGuard extends AuthGuard('jwt') {
  // extends AuthGuard (not implements CanActivate)
  // triggers Passport's JwtStrategy to decode + validate token
  // checks @Public() decorator to skip auth on login/register/etc
}
```

## 3. COMPLETE BUG CATALOG (Bugs 41-42 added June 6, 2026)

### Bug #31: CONCEIVED Stage — Missing lmpDate
When creating a BabyMon with "Expecting" stage, backend DTO requires both `conceptionDate` AND `lmpDate`. Flutter only sent `conceptionDate`. **Fix:** Send both with same date value in `create_baby_mon_screen.dart`.

### Bug #32: Emulator Crash — Re-entrant HTTP Requests
Dashboard `_loadData()` triggered from multiple sources simultaneously (~30+ concurrent requests on BabyMon switch). **Fix:** Added `_loadInProgress` guard, cached `_allBabyMons`, and made `_switchBabyMon()` call `_loadData()` directly.

### Bug #33: BabyMon Details & Multi-BabyMon Selector
Dashboard now fetches all BabyMons via `getBabyMons()`, shows dropdown selector when >1 exist, and stage card expands to show full details (traits, special move, gender).

### Bug #34: Token Refresh Stampede — Emulator Crash
8+ simultaneous `POST /api/auth/refresh` calls when JWT expires. **Fix:** Serialized refresh with `_isRefreshing` gate + `_pendingRetries` queue in `api_client.dart` Dio interceptor.

---

### Bug #1: JWT Guard not extending AuthGuard — 401 on all protected routes
**Found**: Day 1
**Root cause**: Custom `JwtAuthGuard` implemented `CanActivate` instead of extending `AuthGuard('jwt')`. Passport never decoded the token, so `request.user` was always undefined.
**Fixed**: Changed to `extends AuthGuard('jwt')`.

### Bug #2: Refresh token not saved — 401 after 15 minutes
**Found**: Day 2
**Root cause**: `auth_remote_datasource.dart` passed `''` (empty string) as refresh token to `saveTokens()`.
**Fixed**: Now captures `response.data['refreshToken']` and passes it.

### Bug #3: check-verification 404 — wrong auth_provider patched
**Found**: Day 3
**Root cause**: Fix applied to `lib/features/auth/presentation/providers/auth_provider.dart` (dead code), but screens import `lib/presentation/providers/auth_provider.dart` (active code).
**Fixed**: Patched the active file — `checkEmailVerified()` returns `true` immediately.

### Bug #4: Empty string BabyMon ID — screens load with no BabyMon
**Found**: Day 3
**Root cause**: `setSelectedBabyMonId('')` stored `""` instead of deleting the key. `getSelectedBabyMonId()` returned `""` which passed `if (id == null)` checks.
**Fixed**: `getSelectedBabyMonId()` treats empty string as null. `setSelectedBabyMonId(null)` deletes the key.

### Bug #5: Dashboard not refreshing after BabyMon creation
**Found**: Day 3
**Root cause**: Dashboard is inside `IndexedStack`, so `initState` never re-fires after creation. The "Create BabyMon" button stays visible even after successful creation.
**Fixed**: Added `appRefreshProvider` — a Riverpod counter that bumps after create/delete. All 8 screens listen via `ref.listenManual()`.

### Bug #6: All typed API methods missing `/api` prefix — activities not registering
**Found**: Day 4 (final analysis)
**Root cause**: Only 7 of ~45 methods in `api_client.dart` had `/api` prefix. The other 38 constructed paths like `/baby-mons/{id}/health-records` which didn't match any NestJS route.
**Fixed**: All 38 methods now have `/api` prefix.

### Bug #7: Refresh token URL missing `/api` — forced re-login every 15 minutes
**Found**: Day 4
**Root cause**: `_refreshToken()` POSTed to `{baseUrl}/auth/refresh` instead of `{baseUrl}/api/auth/refresh`.
**Fixed**: Added `/api` to the URL.

### Bug #8: Traits validation @MaxLength(3) — all trait strings rejected
**Found**: Day 2
**Root cause**: Backend DTO used `@MaxLength(3)` which validates each individual trait string length (e.g., "Curious" = 7 chars → too long).
**Fixed**: Changed to `@ArrayMaxSize(3)` which limits the array to 3 items.

### Bug #9: Response structure mismatch — data returned but never displayed
**Found**: Day 4
**Root cause**: Backend services return paginated wrappers `{ items: [...], total, skip, take }` but all 7 Flutter screens cast `response.data as List` directly, causing a silent type-cast crash inside try/catch. The catch block set `_isLoading = false` with empty data — loading spinner disappeared, zero errors shown, but data never populated.
**Fixed**: All 8 instances across 6 screens changed to `(response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? []`.
**Files**: `milestones_screen.dart`, `feeding_screen.dart`, `health_screen.dart`, `sleep_screen.dart`, `album_screen.dart`, `journal_screen.dart`, `dashboard_screen.dart` (badges + growth).

### Bug #10: Swipe-to-delete deletes entry even on Cancel
**Found**: Day 4
**Root cause**: All 4 screens used `onDismissed` on `Dismissible` widgets, which fires AFTER the swipe animation completes. The delete dialog appeared but the entry was already removed from view. Even if user tapped "Cancel", the visual removal had already happened.
**Fixed**: Changed `onDismissed` → `confirmDismiss` across all 4 screens, and changed delete methods from `Future<void>` → `Future<bool>` (return `false` on cancel, `true` on success).
**Files**: `milestones_screen.dart`, `feeding_screen.dart`, `health_screen.dart`, `sleep_screen.dart`.

---

## 4. SCREEN-TO-API MAPPING

| Screen | Creates via | Fetches via | BabyMon ID from |
|---|---|---|---|
| **Dashboard** | — | `getEvolution()`, `getBadges()`, `getStageContent()`, `getGrowthRecords()` | `getSelectedBabyMonId()` |
| **Milestones** | `createMilestone(id, data)` | `getMilestones(id)` | `getSelectedBabyMonId()` |
| **Feeding** | `createFeedLog(id, data)` | `getFeedLogs(id)` | `getSelectedBabyMonId()` |
| **Health** | `createHealthRecord(id, data)` | `get(id)` via generic method | `getSelectedBabyMonId()` |
| **Sleep** | `createSleepLog(id, data)` | `getSleepLogs(id)` | `getSelectedBabyMonId()` |
| **Album** | `uploadPhoto(id, data)` | `getPhotos(id)` | `getSelectedBabyMonId()` |
| **Journal** | — | `getJournal(id)`, `getProposals(id)` | `getSelectedBabyMonId()` |
| **Partners** | `invitePartner(id, email, role)` | `getPartners(id)` | `getSelectedBabyMonId()` |
| **Settings** | `deleteBabyMon(id)` | `getProfile()`, `getSubscription()` | `getSelectedBabyMonId()` |
| **Create** | `post('/baby-mons', data)` (generic) | — | — |

---

## 5. DEBUGGING CHECKLIST

When something doesn't work:

1. **Check backend logs** first (`cd apps/api; npm run start:dev` terminal):
   - What status code? (200/201 = worked, 400 = validation, 401 = auth, 404 = route)
   - What URL was requested?
   - Is the path missing `/api`? If so → Bug #6

2. **401 errors**: Check token expiry time in the JWT payload (paste token at jwt.io):
   - `exp` within last 15 minutes? → Token expired, refresh should auto-handle
   - Refresh not working? → Check Bug #7 (URL) or Bug #2 (not saved)

3. **404 errors**: 
   - Compare requested URL in backend logs to `ApiConstants` paths
   - Missing `/api`? → Bug #6
   - Correct file being edited? → Check Section 1.2 (dual auth_provider files)

4. **Empty screen after navigation**:
   - Screen inside IndexedStack? → Won't re-initState → Bug #5
   - BabyMon ID is empty string? → Check with `getSelectedBabyMonId()` → Bug #4

5. **Form validation errors** (400 responses):
   - View the `message` array in the response
   - Check DTO in `apps/api/src/*/dto/` for exact validation rules

---

## 6. PROJECT LAYOUT

```
apps/
├── api/                          # NestJS backend (port 3000)
│   └── src/
│       ├── main.ts               # Global pipe, CORS, /api prefix
│       ├── app.module.ts         # All modules registered
│       ├── auth/                 # Login/register/refresh JWT
│       ├── baby-mon/             # BabyMon CRUD + DTO validation
│       ├── common/guards/        # JwtAuthGuard (extends AuthGuard)
│       └── {entity}/             # One module per entity (milestones, feed-logs, etc.)
│
├── mobile/                       # Flutter app
│   └── lib/
│       ├── data/
│       │   └── api_client.dart   # PRIMARY — ALL typed API methods + storage
│       ├── core/
│       │   ├── data/api_client.dart  # WRAPPER — thin, missing BabyMon ID methods
│       │   ├── providers.dart        # apiClientProvider + appRefreshProvider
│       │   └── services/api_service.dart  # Dio setup, token handling
│       ├── features/auth/
│       │   └── presentation/providers/auth_provider.dart  # DEAD CODE
│       ├── presentation/
│       │   ├── providers/auth_provider.dart  # ACTIVE — used by all screens
│       │   └── screens/main/     # 7 tab screens + settings
│       └── core/constants/
│           └── api_constants.dart  # Base URL, path constants, storage keys
```

---

## 7. RIVERPOD REFRESH ARCHITECTURE

```dart
// core/providers.dart
final appRefreshProvider = StateProvider<int>((ref) => 0);

// create_baby_mon_screen.dart or settings_screen.dart
ref.read(appRefreshProvider.notifier).state++;  // Bump after create/delete

// Every tab screen's initState:
ref.listenManual(appRefreshProvider, (prev, next) {
  if (prev != next) _loadData();  // Reload when counter changes
});
```

Clocks: 8 screens × 1 listener = 8 screens refresh on every create/delete.

---

## 8. BACKEND ENDPOINTS — ALL RESOLVED (June 4, 2026)

Previously 5 endpoints returned 404 blocking key features. All now implemented:

| Endpoint | Resolution |
|---|---|
| `GET/POST /api/baby-mons/:id/sleep-logs` | New `SleepLogsModule` + `SleepLog` model |
| `GET /api/baby-mons/:id/photos` | New `PhotosController` delegating to `MediaService` |
| `GET /api/baby-mons/:id/journal` | Changed `@Post` → `@Get` with `?type=` query |
| `GET /api/baby-mons/:id/badges` | `BabyMonBadgesController` registered in `BadgesModule` |
| `GET /api/baby-mons/:id/partners` | New `getPartnersForBabyMon()` in `LinkedAccountsService` |

**Note:** Run `npx prisma db push` to create the `SleepLog` table in PostgreSQL.

---

*Document Version: 5.0 · Last Updated: June 4, 2026*
