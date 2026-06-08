# BabyMon — API Client Guide

> **Last Updated:** June 5, 2026 (v3.1)  
> **Audience:** Anyone adding API calls  
> **Related Docs:** `02-AUTH-FLOW.md` (auth), `03-KNOWN-GOTCHAS.md` (bugs #2, #3, #35)
> **✅ All 5 previously missing backend endpoints now implemented** — see `01-ARCHITECTURE.md`

---

## Backend Connection

| Setting | Value |
|---------|-------|
| Base URL | `http://10.0.2.2:3000` (emulator) or `http://localhost:3000` (web/desktop) |
| Global prefix | `/api` (NestJS `app.setGlobalPrefix('api')`) |
| Config file | `apps/mobile/lib/core/constants/api_constants.dart` |

---

## Two Ways to Call the API

### 1. Typed Methods (Preferred — Add New Endpoints Here)

Located in `ApiClient` class at `lib/data/api_client.dart`. These call `_dio.get/post/patch/delete` DIRECTLY.

**CRITICAL RULE:** Must include `/api` prefix in the path.

| Method | HTTP | Full URL |
|--------|------|----------|
| `register(email, password, name)` | POST | `/api/auth/register` |
| `login(email, password)` | POST | `/api/auth/login` |
| `getProfile()` | GET | `/api/auth/profile` |
| `logout()` | POST | `/api/auth/logout` |
| `getBabyMons()` | GET | `/api/baby-mons` |
| `getBabyMon(id)` | GET | `/api/baby-mons/:id` |
| `createBabyMon(data)` | POST | `/api/baby-mons` |
| `updateBabyMon(id, data)` | PATCH | `/api/baby-mons/:id` |
| `deleteBabyMon(id)` | DELETE | `/api/baby-mons/:id` |
| `getBabyMonStage(id)` | GET | `/api/baby-mons/:id/stage` |
| `getMilestones(babyMonId)` | GET | `/api/baby-mons/:id/milestones` |
| `createMilestone(babyMonId, data)` | POST | `/api/baby-mons/:id/milestones` |
| `updateMilestone(id, data)` | PATCH | `/api/milestones/:id` |
| `deleteMilestone(id)` | DELETE | `/api/milestones/:id` |
| `getFeedLogs(babyMonId)` | GET | `/api/baby-mons/:id/feed-logs` |
| `createFeedLog(babyMonId, data)` | POST | `/api/baby-mons/:id/feed-logs` |
| `updateFeedLog(id, data)` | PATCH | `/api/feed-logs/:id` |
| `deleteFeedLog(id)` | DELETE | `/api/feed-logs/:id` |
| `getHealthRecords(babyMonId)` | GET | `/api/baby-mons/:id/health-records` |
| `createHealthRecord(babyMonId, data)` | POST | `/api/baby-mons/:id/health-records` |
| `updateHealthRecord(id, data)` | PATCH | `/api/health-records/:id` |
| `deleteHealthRecord(id)` | DELETE | `/api/health-records/:id` |
| `getBadges(babyMonId)` | GET | `/api/baby-mons/:id/badges` |
| `getBadgeDefinitions()` | GET | `/api/badges/definitions` |
| `getEvolution(babyMonId)` | GET | `/api/baby-mons/:id/evolution` |
| `getJournal(babyMonId)` | GET | `/api/baby-mons/:id/journal` |
| `getProposals(babyMonId)` | GET | `/api/baby-mons/:id/journal/proposals` |
| `respondToProposal(babyMonId, propId, accept)` | POST | `/api/baby-mons/:id/journal/proposals/:pid/respond` |
| `exportBabyMon(babyMonId)` | GET | `/api/baby-mons/:id/export` |
| `getSubscription()` | GET | `/api/subscriptions/current` |
| `devOverrideTrial(days)` | POST | `/api/subscriptions/dev-override-trial` |
| `getGrowthRecords(babyMonId)` | GET | `/api/baby-mons/:id/growth` |
| `createGrowthRecord(babyMonId, data)` | POST | `/api/baby-mons/:id/growth` |
| `deleteGrowthRecord(babyMonId, id)` | DELETE | `/api/baby-mons/:id/growth/:id` |
| `invitePartner(babyMonId, email, role)` | POST | `/api/baby-mons/:id/partners/invite` |
| `getPartners(babyMonId)` | GET | `/api/baby-mons/:id/partners` |
| `respondToInvitation(partnerId, status)` | PATCH | `/api/baby-mons/:id/respond` |
| `removePartner(partnerId)` | DELETE | `/api/baby-mons/:id` |
| `uploadPhoto(babyMonId, data)` | POST | `/api/baby-mons/:id/photos` |
| `getPhotos(babyMonId)` | GET | `/api/baby-mons/:id/photos` |
| `deletePhoto(id)` | DELETE | `/api/baby-mons/photos/:id` |
| `getSleepLogs(babyMonId)` | GET | `/api/baby-mons/:id/sleep-logs` |
| `createSleepLog(babyMonId, data)` | POST | `/api/baby-mons/:id/sleep-logs` |
| `updateSleepLog(babyMonId, id, data)` | PATCH | `/api/baby-mons/:id/sleep-logs/:id` |
| `deleteSleepLog(babyMonId, id)` | DELETE | `/api/baby-mons/:id/sleep-logs/:id` |

### 2. Generic Methods (Fallback)

Use for endpoints that don't have a typed method yet. These AUTO-prepend `/api` — do NOT include it.

```dart
// ✅ CORRECT: generic methods auto-prepend /api
ref.read(apiClientProvider).get('/users/me');          // → /api/users/me
ref.read(apiClientProvider).post('/users/me', data);   // → /api/users/me
ref.read(apiClientProvider).patch('/users/me', data);  // → /api/users/me
ref.read(apiClientProvider).delete('/users/me');       // → /api/users/me

// ❌ WRONG: double /api prefix
ref.read(apiClientProvider).get('/api/users/me');      // → /api/api/users/me
```

---

## Auth Header

Automatic via Dio interceptor in `api_client.dart`:

```dart
onRequest: (options, handler) async {
  final token = await _storage.read(key: StorageKeys.accessToken);
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
}
```

- Token saved during login/register by `_apiClient.saveTokens()`
- Read from `FlutterSecureStorage` key `access_token`
- Interceptor SKIPS refresh on `/auth/login`, `/auth/register`, `/auth/refresh`

---

## Error Handling

```dart
try {
  final response = await ref.read(apiClientProvider).getSomething();
  // Handle success
} on DioException catch (e) {
  final message = e.response?.data?['message'] ?? 'Request failed';
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
} catch (e) {
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
}
```

---

## Provider Usage

```dart
// ✅ CORRECT
import 'package:baby_mon/presentation/providers/auth_provider.dart';
final api = ref.read(apiClientProvider);

// ❌ WRONG
import 'package:baby_mon/core/providers.dart';  // Deprecated — causes duplicate providers
```

---

## Adding a New Endpoint

1. Add a path constant to `api_constants.dart` if needed
2. Add a typed method to `ApiClient` in `api_client.dart`
3. Remember `/api` prefix on the path
4. Call `ref.read(apiClientProvider).yourNewMethod()` from your screen

---

*Last Updated: June 4, 2026*