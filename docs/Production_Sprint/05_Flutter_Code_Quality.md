# Issues 15-16: Flutter Code Quality

**Date:** 2026-06-23 | **Priority:** HIGH (P0) / MEDIUM (P1)

---

## Issue 15: 36 print/debugPrint Calls Across 14 Files

### P0 — MUST FIX (Privacy/Token Leaks)

| # | File | Line | Content | Fix |
|---|------|------|---------|-----|
| 1 | `llm_inference_service.dart` | 73 | Full system prompt + PII | Remove |
| 2 | `llm_inference_service.dart` | 85 | Full context prompt + PII | Remove |
| 3 | `profile_screen.dart` | 30 | `'$field = $value'` (PII) | Remove value, log only field name |

### P1 — SHOULD FIX (All Others)

| File | Count | Fix |
|------|-------|-----|
| `main.dart` | 2 | Route to crash reporter (Sentry) |
| `api_client.dart` | 1 | Guard with `kDebugMode` |
| `auth_remote_datasource.dart` | 1 | Guard with `kDebugMode` |
| `dashboard_screen.dart` | 10 | Guard with `kDebugMode` |
| `companion_tab.dart` | 7 | Guard with `kDebugMode` |
| `llm_provider.dart` | 3 | Guard with `kDebugMode` |
| Other screens (5 files) | 5 | Guard with `kDebugMode` |

### No Logging Infrastructure Exists

Create `AppLogger` service with log levels. `kDebugMode` gates debug output in release builds. Never print user data, tokens, or PII — even in debug mode.

---

## Issue 16: 40+ Silent Catch Blocks

### P0 — MUST FIX (User-Facing Operations)

| # | File | Lines | Pattern | Impact |
|---|------|-------|---------|--------|
| 1 | `journal_repository.dart` | 38, 47, 56 | `catch(_){return[]}` ×3 | Journal shows empty on any API error |
| 2 | `auth_repository_impl.dart` | 67-68 | `catch(e){return false}` | Verification check fails silently |
| 3 | `api_client.dart` | 108 | `catch(e){return false}` | Token refresh unlogged |
| 4 | `dashboard_provider.dart` | 25-26 | `catch(e){return empty}` | Dashboard shows blank on error |
| 5 | `profile_repository_impl.dart` | 20-21 | `catch(e){return empty}` | Corrupt profile silently replaced |
| 6 | `post_login_loading_screen.dart` | 88, 94-96 | `catch(_){}` ×2 | Prefetch fails silently |
| 7 | `data_screen_mixin.dart` | 220 | `catch(e){stopLoading}` | No error state in base mixin |
| 8 | `splash_screen.dart` | 64-65 | `catch(_){gotoLogin}` | Auth failure redirects silently |
| 9 | `health_screen.dart` | 499 | `catch(_){genericError}` | "Failed to add" with no detail |
| 10 | `model_manager.dart` | 55-56 | `catch(_){return defaults}` | Registry corruption silently replaced |
| 11 | `activity_repository_impl.dart` | 61 | `catch(e){return[]}` | Corrupt activity data discarded |
| 12 | `dashboard_screen.dart` | 175 | `catch(_){stopLoading}` | Dashboard load fails silently |
| 13 | `api_service.dart` | 75 | `catch(e){deleteTokens}` | Token refresh failure unlogged |
| 14 | `api_client.dart` | 138 | `print(...)` / silent | Logout API failure unlogged |

### P1 — SHOULD FIX (Background Operations)

22 catch blocks in `notification_service.dart`, `device_capability_service.dart`, `model_download_service.dart`, `advice_feed_provider.dart`, `companion_tab.dart`, `chat_screen.dart`, `model_settings_screen.dart`, `llamadart_engine.dart`, `dashboard_screen.dart`, `level_up_celebration.dart`.

**Fix for all P1:** Replace `catch(_){}` with `catch(e){AppLogger.debug('Operation failed', e);}`.

### Cross-Cutting Anti-Patterns

1. **Catch-and-debugPrint:** Silently swallows error AND clutters production console
2. **Empty catch in build methods:** `dashboard_screen.dart:1329,1333,1339` — Flutter anti-pattern
3. **No centralized error handling:** No error boundary, inconsistent surfacing (SnackBar vs silent vs print)
4. **Two API clients exist:** `ApiService` (deprecated) and `ApiClient` (current) — both have same silent catch issues
