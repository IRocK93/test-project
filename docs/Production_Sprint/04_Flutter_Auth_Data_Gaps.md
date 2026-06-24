# Issues 7-9, 17: Flutter Auth & Data Gaps

**Date:** 2026-06-23 | **Priority:** HIGH

---

## Issue 7: sendVerificationEmail Is a No-Op Stub

**File:** `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart`, lines 125-136

```dart
Future<void> sendVerificationEmail(String email) async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    await Future<void>.delayed(const Duration(seconds: 1));  // ← NO-OP
    state = state.copyWith(isLoading: false);
  } catch (e) { ... }
}
```

**Impact:** Verification resend silently fails. User sees spinner → success, but no email is ever sent.

**Root cause:** Both the provider method AND the backend endpoint (`POST /api/auth/send-verification-email`) are missing. The repository calls it, but the controller has no such route.

**Fix (both sides):**
- **Backend:** Add `POST /auth/send-verification-email` — look up user, generate new token, send via MailService, return generic success
- **Mobile:** Replace `Future.delayed` with `await _repository.sendVerificationEmail(email)`

---

## Issue 8: checkEmailVerified Always Returns true

**File:** `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart`, lines 137-142

```dart
Future<bool> checkEmailVerified() async {
  // Email verification is optional/cosmetic; skip the backend call
  // that results in a 404. Always allow login to proceed.
  state = state.copyWith(isLoading: false, isEmailVerified: true);
  return true;
}
```

**Impact:** Email verification gate is completely bypassed. Any user proceeds to home screen regardless of verification status. The `VerificationScreen` is a 1-second speed bump.

**Root cause:** Backend endpoint `/api/auth/check-verification` returns 404 (doesn't exist). Developer worked around it client-side.

**Fix (both sides):**
- **Backend:** Add `POST /auth/check-verification` (authenticated) — return `{ verified: true/false }` based on `verifiedAt`
- **Backend (recommended):** Enforce in `login()` — reject unverified users with 403 `EMAIL_NOT_VERIFIED`
- **Mobile:** Remove hardcoded `true`, call `_repository.checkEmailVerified()`

---

## Issue 9: LLM Prompt Leakage via print()

**File:** `apps/mobile/lib/features/companion/data/llm/llm_inference_service.dart`, lines 73, 85

```dart
print('[PROMPT] === FIRST (full identity) ===\n$systemPrompt\n=== END ===');
print('[PROMPT] === Subsequent (context-only) ===\n$contextPrompt\n=== END ===');
```

**What leaks:** Full system prompt including baby's name, age, gender, developmental stage, RAG context (journal/health/milestone data), sleep/feeding summaries.

**Risk:** CRITICAL privacy breach. `print()` cannot be silenced in release builds. Child PII leaks to device logcat/console.

**Fix:** Remove both `print()` calls entirely. If debugging needed, use `kDebugMode` guard and log only metadata (prompt length), never the full text.

---

## Issue 17: Dashboard Has No Error State

**File:** `apps/mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart`

Nine `_fetch*` methods catch errors silently with `debugPrint` only. The dashboard renders with null/default data on API failure:

| Data Field | On Failure | UX |
|------------|-----------|-----|
| `_babyMon` | null → name="Baby", level=1 | Wrong identity |
| `_evolution` | null → XP shows 0 | Broken progress |
| `_stageContent` | null → card hidden | Section disappears |
| `_badges` | empty → empty section | Looks like no badges earned |
| `_allergies` | empty → empty panel | Looks healthy |
| `_parentName` | null → hidden | Missing family info |

**Fix:**
1. Add `String? _error` field to state
2. Set `_error` on failure in `_loadData`
3. Build `_buildErrorState()` with error icon, message, and Retry button
4. Handle partial data with a banner: "Some data could not be loaded. Pull to retry."
