# Bug 2: Routine Page — "Failed to update step" on Tick

**Date:** 2026-06-23 | **Severity:** HIGH

## Two Root Causes

Both bugs are in the Flutter client. The backend endpoint exists and is correct.

---

### Primary Cause: Unencoded stepLabel in URL Path Crashes Dio

**File:** `apps/mobile/lib/features/companion/data/companion_repository.dart`, lines 30-36

```dart
Future<void> completeRoutineStep(String babyMonId, String stepLabel) async {
  await _api.post(
    '/stage-content/$babyMonId/routine/$stepLabel/complete',  // ← RAW stepLabel
    data: <String, dynamic>{},
  );
}
```

The `stepLabel` is routine template activity text like:
- `"Wake, feed, burp, diaper change"`
- `"Brief awake time (tummy time on chest, face-to-face gazing)"`

These contain **spaces, commas, hyphens, and parentheses**. The string is interpolated directly into the URL path. After the versioning interceptor upgrades the prefix, the final path is:

```
/api/v1/stage-content/<uuid>/routine/Wake, feed, burp, diaper change/complete
```

### What Happens in Dio

When Dio processes the request, it calls `Uri.parse(url)` on the raw, unencoded URL string. Dart's `Uri.parse()` throws a `FormatException` for illegal characters (unencoded spaces). The request **never reaches the server**. Dio wraps this into a `DioException`.

### Backend Verification

The endpoint exists and is correct:

**File:** `apps/api/src/companion/companion.controller.ts`, line 31

```typescript
@Post('routine/:stepLabel/complete')
async completeStep(
  @Param('babyMonId') babyMonId: string,
  @Param('stepLabel') stepLabel: string,
) {
  return this.companionService.completeRoutineStep(babyMonId, stepLabel);
}
```

**File:** `apps/api/src/companion/companion.service.ts`, lines 152-169 — correctly finds today's routine, toggles the step in `completedSteps` array, and updates the database. The backend is fine.

---

### Secondary Cause: Cache Not Invalidated After Successful POST

Even if the URL encoding is fixed, the UI would **still show no change** because the cache invalidation pattern doesn't match the GET cache key.

**File:** `apps/mobile/lib/core/data/api_client.dart`, lines 68-77

```dart
// After POST to: /api/v1/stage-content/<uuid>/routine/<stepLabel>/complete
final resource = url
    .replaceAll(RegExp(r'^/api(/v1)?'), '')     // → /stage-content/<uuid>/routine/<stepLabel>/complete
    .replaceAll(RegExp(r'/[a-f0-9-]{36}'), '')   // → /stage-content/routine/<stepLabel>/complete
    .replaceAll(RegExp(r'/+$'), '');              // → unchanged
_cache.invalidatePattern(resource);
```

The invalidation pattern becomes: `/stage-content/routine/<stepLabel>/complete`

But the GET cache key is: `/api/v1/stage-content/<uuid>/routine`

The pattern does NOT match the key. The stale cached routine data is returned on the next fetch, and `ref.invalidate(routineProvider(...))` + the `get()` call without `forceRefresh` serves the cached (pre-tick) response.

---

### Also: Error Message Is Discarded

**File:** `apps/mobile/lib/features/companion/presentation/screens/routine_screen.dart`, lines 272-277

```dart
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update step')),  // ← hardcoded, real error discarded
    );
  }
}
```

The `FormatException` detail (which would clearly show the URL encoding issue) is swallowed in favor of a generic message. This significantly slowed debugging.

---

## Production-Grade Fix

### Fix 1: URL-encode the stepLabel (companion_repository.dart)

```dart
Future<void> completeRoutineStep(String babyMonId, String stepLabel) async {
  await _api.post(
    '/stage-content/$babyMonId/routine/${Uri.encodeComponent(stepLabel)}/complete',
    data: <String, dynamic>{},
  );
}
```

### Fix 2: Fix cache invalidation (api_client.dart)

The resource extraction should target the route collection, not the specific action. Add a step that strips action suffixes:

```dart
final resource = url
    .replaceAll(RegExp(r'^/api(/v1)?'), '')
    .replaceAll(RegExp(r'/[a-f0-9-]{36}'), '')
    .replaceAll(RegExp(r'/routine/.+/complete$'), '/routine')  // ← NEW: collapse action to collection
    .replaceAll(RegExp(r'/+$'), '')
    .replaceAll(RegExp(r'//+'), '/');  // ← NEW: normalize double slashes
```

### Fix 3: Show real error (routine_screen.dart)

```dart
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(extractErrorMessage(e))),
    );
  }
}
```

### Also: Backend should handle decoding

Express/NestJS automatically decodes `%20` → space in path params, so `Uri.encodeComponent` on the client works seamlessly with the existing backend `@Param('stepLabel')`.
