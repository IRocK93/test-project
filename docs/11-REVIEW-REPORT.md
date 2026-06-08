# BabyMon Review Report — June 6, 2026

## Summary

| Area | Result |
|---|---|
| Backend TypeScript | **0 errors** — clean compilation |
| Flutter Analyze | **0 errors**, 25 warnings, 192 info hints |
| API Route Alignment | **0 mismatches** — all 59 methods verified |
| Backend Modules | **23 models, 24 modules** — all registered |
| Critical Bugs Found | **11 null safety violations** (runtime crash risk) |
| UX Issues Found | **4** |
| Dead Code | **8 instances** |
| Tech Debt | **45+ deprecated API usages** |

---

## 🔴 Critical — Null Safety Violations (11)

The following screens use `_babyMonId!` without null guards when called from FAB tap or pull-to-refresh paths (not just from `_loadData`). This causes "Null check operator used on a null value" crash when no BabyMon is selected.

| # | File | Line | Method | Code |
|---|---|---|---|---|
| 1 | `milestones_screen.dart` | 43 | `_fetchMilestones()` | `getMilestones(_babyMonId!)` |
| 2 | `feeding_screen.dart` | 43 | `_fetchFeedLogs()` | `getFeedLogs(_babyMonId!)` |
| 3 | `health_screen.dart` | 66 | `_fetchHealthRecords()` | `'$_babyMonId/health-records'` |
| 4 | `sleep_screen.dart` | 57 | `_fetchSleepLogs()` | `getSleepLogs(_babyMonId!)` |
| 5 | `album_screen.dart` | 55 | `_fetchPhotos()` | `getPhotos(_babyMonId!)` |
| 6 | `journal_screen.dart` | 47 | `_fetchJournal()` | `getJournal(_babyMonId!)` |
| 7 | `partners_screen.dart` | 49 | `_fetchPartners()` | `getPartners(_babyMonId!)` |
| 8 | `milestones_screen.dart` | ~185 | FAB dialog create | `createMilestone(_babyMonId!, ...)` |
| 9 | `feeding_screen.dart` | ~195 | FAB dialog create | `createFeedLog(_babyMonId!, ...)` |
| 10 | `health_screen.dart` | ~540 | FAB dialog create | uses `_babyMonId` |
| 11 | `sleep_screen.dart` | ~220 | FAB dialog create | `createSleepLog(_babyMonId!, ...)` |

**Fix:** Add `if (_babyMonId == null) { show snackbar; return; }` guard at the top of every `_fetch*()` method and FAB dialog handler.

---

## 🟠 Warning — Loading State Bug (1)

| # | File | Line | Issue |
|---|---|---|---|
| 12 | `dashboard_screen.dart` | 79 | `_loadInProgress` guard returns without setting `_isLoading = false`. If provider init throws before `finally{}`, spinner stuck forever |

**Fix:** Add `setState(() => _isLoading = false)` before the re-entrancy guard's early return.

---

## 🟡 UX/Content Issues (4)

| # | File | Line | Issue |
|---|---|---|---|
| 13 | `dashboard_screen.dart` | 188 | Empty state text differs from spec |
| 14 | `dashboard_screen.dart` | 342 | No dedicated "No badges unlocked yet" empty state |
| 15 | `milestones_screen.dart` | cards | Sync status indicator not visible on milestone cards |
| 16 | `sleep_screen.dart` | 346 | `_qualityText` declared but never used |

---

## 🔵 Dead Code (8)

| # | File | Line | Item |
|---|---|---|---|
| 17 | `sleep_screen.dart` | 346 | `_qualityText` — unused element |
| 18 | `settings_screen.dart` | 205 | `_deleteAccount` — unused element |
| 19 | `subscription_screen.dart` | 20 | `_subscription` — unused field |
| 20 | `dashboard_screen.dart` | 339 | `_badgesExpanded` — unused field |
| 21 | `dashboard_screen.dart` | 375 | `isExpanded` — unused local variable |
| 22 | `health_screen.dart` | 540 | `selectedType` — unused local variable |
| 23 | 25 unused imports | various | Lint noise, minor bundle size |
| 24 | `pubspec.yaml` | 43 | `flutter_secure_storage` in both deps and dev_deps |

---

## ⬜ Technical Debt — Deprecated APIs (45+)

All `withOpacity()` calls should migrate to `withValues()`.
All `value:` in form fields should migrate to `initialValue:`.
All `groupValue:`/`onChanged:` on Radio widgets should use RadioGroup.

These will become compile errors on Flutter 3.34+.

---

*Document created: June 6, 2026 · Review Run #1*