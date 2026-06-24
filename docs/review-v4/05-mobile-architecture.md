# BabyMon Mobile Architecture Audit — v4

**Date:** 2026-06-22
**Overall Grade: C+**

---

## 1. Architecture Assessment

The Flutter app follows a Clean Architecture pattern with four layers:
- `core/` — Constants, theme, services, mixins, router
- `data/` — ApiClient (Dio wrapper with 46+ typed methods)
- `features/` — Domain entities + repositories + datasources + providers
- `presentation/` — Screens, shared providers, router

The conceptual architecture is sound, but the implementation has significant technical debt.

---

## 2. Top 15 Anti-Patterns

| # | Anti-Pattern | Severity | File/Location |
|---|-------------|----------|---------------|
| 1 | **Clay theme broken at runtime** — styleKey comparison `== 'clay'` fails because key is `'clay_loggedIn'` | CRITICAL | `app.dart:31` |
| 2 | **Duplicate HTTP clients** — Two different `api_client.dart` implementations coexisting in the codebase | CRITICAL | `data/` vs `features/` |
| 3 | **Divergent API methods** — Typed methods in one client, generic methods in another, different error handling | HIGH | Both api_client files |
| 4 | **Tokens stored in SharedPreferences AND FlutterSecureStorage** — Doubles attack surface | HIGH | `auth_remote_datasource.dart`, `auth_provider.dart` |
| 5 | **GoRouter recreated on login state change** — Should be a constant singleton | MEDIUM | `app_router.dart:130` |
| 6 | **Massive screen files** — `dashboard_screen.dart` at 1464 lines, `create_baby_mon_screen.dart` at 1800+ lines | MEDIUM | Dashboard, Onboarding |
| 7 | **ConsumerStatefulWidget overuse** — Causes full subtree rebuilds on every `setState()` | MEDIUM | Dashboard, MainScreen |
| 8 | **Missing `const` constructors** — 1464-line dashboard has only 7 `const` occurrences | MEDIUM | All screens |
| 9 | **Hardcoded AppColors bypassing theme** — 150+ direct `AppColors.*` references | HIGH | Auth screens (worst), Dashboard, Companion |
| 10 | **No response DTOs / model mapping** — API responses cast directly to domain types | MEDIUM | All repositories |
| 11 | **Embedded privacy policy/TOS as Dart strings** — Cannot be updated without app release | MEDIUM | `app_router.dart:44-128` |
| 12 | **`_loadInProgress` re-entrancy guard** — Pattern exists but inconsistently applied | LOW | IndexedStack screens |
| 13 | **No offline-first architecture** — Despite Drift (SQLite) dependency, no sync strategy | HIGH | Data layer |
| 14 | **Provider disposal uncertainty** — CompanionProvider, LLMProvider hold large model data | MEDIUM | Companion feature |
| 15 | **Inconsistent error handling** — Mix of `.catchError()`, try-catch, and `showError()` | MEDIUM | All screens |

---

## 3. State Management Assessment

Riverpod is correctly chosen but misused:
- `StateNotifierProvider` for auth — correct pattern
- `ref.read()` for one-shot API calls — acceptable
- `setState()` for per-screen local UI state — overused, causes unnecessary rebuilds
- `appRefreshProvider` (int counter) to force IndexedStack reloads — hacky, should use proper invalidation

---

## 4. Key Recommendations

### P0 — Critical
1. Fix Clay theme resolution bug
2. Consolidate duplicate HTTP clients into single `data/api_client.dart`
3. Migrate all token storage from SharedPreferences to FlutterSecureStorage only

### P1 — High
4. Make GoRouter a constant singleton — don't recreate on auth state change
5. Add response DTOs and domain model mapping layer
6. Implement proper provider invalidation instead of `appRefreshProvider` counter
7. Begin decomposing large screen files (>500 lines)

### P2 — Medium
8. Add `const` to all eligible constructors
9. Migrate AppColors references to `Theme.of(context).colorScheme`
10. Host privacy policy/TOS at stable URLs, load dynamically
11. Implement offline-first architecture with Drift
12. Ensure all providers properly dispose resources
