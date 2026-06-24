# Bug 3: Milestones Page — Inconsistent UI Update After Achieve

**Date:** 2026-06-23 | **Severity:** MEDIUM

## Root Cause: Cache Invalidation Pattern Never Matches GET Cache Key

The "sometimes updates, sometimes not" behavior is caused by the in-memory `ResponseCache` (5-minute TTL). After a POST achieves a milestone, the cache invalidation computes a pattern that does NOT match the GET cache key. The stale response is served until the 5-minute TTL expires naturally.

---

## Full Trace

### 1. User taps a milestone checkbox

**File:** `apps/mobile/lib/features/companion/presentation/screens/milestone_tracker_screen.dart`, lines 331-354

```dart
Future<void> _achieveMilestone(Map<String, dynamic> milestone) async {
  await repo.achieveMilestone(widget.babyMonId, id);           // POST succeeds
  ref.invalidate(milestonesProvider(widget.babyMonId));        // triggers re-fetch
  // SnackBar: 'Milestone achieved! +XP'                       // always shows
}
```

### 2. POST sends to backend

**File:** `apps/mobile/lib/features/companion/data/companion_repository.dart`, lines 49-56

```dart
await _api.post('/stage-content/$babyMonId/milestones/$expectationId/achieve');
```

Path after interceptor: `/api/v1/stage-content/{babyMonUUID}/milestones/{expectationUUID}/achieve`

### 3. POST succeeds, cache invalidation fires

**File:** `apps/mobile/lib/core/data/api_client.dart`, lines 68-77

```dart
final url = response.requestOptions.path;
// url = '/api/v1/stage-content/{babyMonUUID}/milestones/{expectationUUID}/achieve'
final resource = url
    .replaceAll(RegExp(r'^/api(/v1)?'), '')     // → /stage-content/{babyMonUUID}/milestones/{expectationUUID}/achieve
    .replaceAll(RegExp(r'/[a-f0-9-]{36}'), '')   // → /stage-content/milestones//achieve  (double slash!)
    .replaceAll(RegExp(r'/+$'), '');              // → /stage-content/milestones//achieve  (unchanged)
_cache.invalidatePattern(resource);
```

**Computed pattern:** `/stage-content/milestones//achieve`

### 4. Stale cache is NOT invalidated

**File:** `apps/mobile/lib/core/data/response_cache.dart`, line 32

```dart
void invalidatePattern(String pattern) {
  _cache.removeWhere((key, _) => key.contains(pattern));
}
```

The GET milestones cache key is: `/api/v1/stage-content/{babyMonUUID}/milestones/expected`

Does this key **contain** the pattern `/stage-content/milestones//achieve`? **No** — the key has `/{UUID}/milestones/expected` while the pattern has `/milestones//achieve`. After `/stage-content/`, the strings diverge completely.

### 5. ref.invalidate triggers re-fetch, but cache returns stale data

```dart
ref.invalidate(milestonesProvider(widget.babyMonId));
// → companion_repository.getMilestones() is called
// → _api.get('/stage-content/$babyMonId/milestones/expected')
// → ApiClient.get() checks cache FIRST (no forceRefresh flag)
// → cache.get('/api/v1/stage-content/{UUID}/milestones/expected') → HIT
// → returns stale (pre-achievement) response
```

### 6. Intermittent behavior explained

| Cache State | Behavior | When |
|:---|:---|:---|
| Cache has unexpired entry (< 5 min old) | Stale data returned, milestone shows unchecked | **BUG** |
| Cache entry expired (> 5 min old) or evicted | Fresh GET to backend, milestone shows checked | **WORKS** |

The user sees "Milestone achieved!" SnackBar every time (POST succeeds). The checkbox update depends on whether the previous GET was cached within the last 5 minutes.

---

## Why Other POST Endpoints Work Correctly

The cache invalidation works for endpoints like `/api/v1/baby-mons/{id}/milestones` because the POST path contains a single UUID:

```
POST: /api/v1/baby-mons/{babyMonUUID}/milestones
After stripping: /baby-mons/milestones
GET key:  /api/v1/baby-mons/{babyMonUUID}/milestones
```

`/baby-mons/milestones` is CONTAINED in the GET key → cache IS invalidated ✅

For the companion stage-content routes, the pattern breaks because of the extra UUID segment in the path.

---

## Production-Grade Fix

### Option A: Targeted — Pass forceRefresh on re-fetch (recommended)

**File:** `apps/mobile/lib/features/companion/data/companion_repository.dart`

```dart
Future<List<Map<String, dynamic>>> getMilestones(String babyMonId, {bool forceRefresh = false}) async {
  final response = await _api.get(
    '/stage-content/$babyMonId/milestones/expected',
    options: Options(extra: {'forceRefresh': forceRefresh}),
  );
  return List<Map<String, dynamic>>.from(response.data);
}
```

Then in the provider, pass `forceRefresh: true` on every fetch:

```dart
// companion_provider.dart
Future<List<Map<String, dynamic>>> _fetchMilestones(ref) async {
  final repo = ref.read(companionRepositoryProvider);
  return repo.getMilestones(babyMonId, forceRefresh: true);  // always fresh
}
```

**Trade-off:** Slightly more network traffic on every milestones screen visit, but the data is always correct. The 5-minute cache is more appropriate for dashboard stats than for user-interactive toggle screens.

### Option B: System-wide — Fix cache invalidation pattern extraction

**File:** `apps/mobile/lib/core/data/api_client.dart`, lines 68-77

Replace the simple UUID strip with logic that extracts the resource collection path:

```dart
final resource = url
    .replaceAll(RegExp(r'^/api(/v1)?'), '')
    .replaceAll(RegExp(r'/[a-f0-9-]{36}'), '/')   // replace UUID segments with single slash
    .replaceAll(RegExp(r'/(achieve|complete|cure|reactivate|clear-all|respond)$'), '')  // strip action suffixes
    .replaceAll(RegExp(r'//+'), '/')               // normalize double slashes
    .replaceAll(RegExp(r'/+$'), '');               // strip trailing slash
```

This would fix cache invalidation for ALL endpoints with action suffixes (routine complete, milestone achieve, allergy cure, etc.) but requires careful testing across all POST/PATCH/DELETE patterns.

### Option C: Hybrid — Fix invalidation AND add forceRefresh for critical paths

Apply Option B for system-wide correctness, and add `forceRefresh: true` in screens where cache staleness is user-visible (milestones, routine, journal). This provides defense in depth.
