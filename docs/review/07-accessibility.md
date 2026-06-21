# 07 — Accessibility Audit

**Date:** 2026-06-17
**Severity Score:** 🟠 High (3 High, 4 Medium, 3 Low)
**Verdict:** Above-average a11y awareness for Flutter. Three systemic gaps: no font scaling, low-contrast disabled states, no i18n.

---

## Summary

BabyMon demonstrates above-average accessibility awareness for a Flutter codebase: 52 `Semantics()` wrappers across core widgets and feature screens, pervasive `semanticLabel` on buttons, thorough form labeling, good reduced-motion handling, and zero uses of `ExcludeSemantics`. However, three systemic gaps drag the score: **(1) no font-scaling support** — the `MaterialApp` lacks a `builder` to handle system text size; **(2) `AppColors.disabled` (#C0C0C0 on white ≈ 1.78:1)** fails WCAG AA by a wide margin, affecting disabled controls and low-alpha ghost states; **(3) no i18n infrastructure** — `flutter_localizations` is missing from `pubspec.yaml`, all strings are hardcoded English. Small tap targets (32–40dp) appear in settings footers, photo viewers, and segmented-button controls.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| A11 | 🟠 High | **No font scaling support** | `app.dart:19`; `theme_text.dart:34` | `MaterialApp.router` has no `builder`. `ThemeText.textScaler` parameter exists but never set. Zero callers of `MediaQuery.textScalerOf`. | Wrap with `builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(MediaQuery.textScaleFactorOf(ctx).clamp(1.0, 1.3))), child: child!)`. |
| A12 | 🟠 High | **`AppColors.disabled` (#C0C0C0) fails WCAG AA — ~1.78:1** | `app_colors.dart:63` | `disabled: 0xFFC0C0C0` against `surface: 0xFFFFFFFF`. Also used with `withValues(alpha: 0.1)` for photo placeholders — even worse. | Raise to at least `#949494` (≈3:1 for large/UI elements) or `#767676` (4.5:1 for text). |
| A13 | 🟠 High | **No i18n/l10n — all strings hardcoded English** | `pubspec.yaml:1-42`; `app.dart:19-28` | `flutter_localizations` missing. `intl` present but only for `DateFormat`. No `AppLocalizations` class. No `/l10n` directory. | Add `flutter_localizations`, set up `l10n.yaml`, create ARB files, configure `localizationsDelegates` + `supportedLocales`. |
| A14 | 🟡 Medium | **SegmentedButton tap targets shrunken below 44dp** | `settings_screen.dart:498,528,558`; `growth_chart_screen.dart:547`; `health_screen.dart:358`; `feeding_screen.dart:622` | `tapTargetSize: MaterialTapTargetSize.shrinkWrap` + `visualDensity: compact` + `fontSize: 11-12` — estimated ~32–36dp. | Remove `shrinkWrap` and `compact` on interactive controls. Let Material enforce ≥48dp. |
| A15 | 🟡 Medium | **Footer links tap height only 32dp** | `settings_screen.dart:791-792` | `minimumSize: const Size(0, 32)` + `tapTargetSize: shrinkWrap`. | Raise `minimumSize` to `Size(0, 48)`. Remove `shrinkWrap`. |
| A16 | 🟡 Medium | **Photo viewer close button is 40×40dp** | `photo_viewer.dart:160-161` | `width: 40, height: 40` `GestureDetector`. | Increase to 48×48 or wrap in `Semantics` with padding. |
| A17 | 🟡 Medium | **`CachedNetworkImage` has no `semanticLabel`** | `photo_grid.dart:39`; `photo_viewer.dart:216` | Images render without alt text. Parent `Semantics` labels exist but don't describe photo content. | Add `semanticLabel: 'Photo: ${caption ?? 'untitled'}'`. |
| A18 | 🔵 Low | **`textCaptionDark` borderline contrast on dark surface** | `app_colors.dart:77` | `textCaptionDark: 0xFF808090` on `darkSurface: 0xFF1A1A22` — ~4.3:1, barely passes AA. | Bump to `#9494A4` for comfortable 5.5:1. |
| A19 | 🔵 Low | **Disabled button contrast collapses** | `theme_button.dart:200-204` | Filled disabled: `primaryLight/disabled.withValues(alpha: 0.4)` — likely below 3:1. | Define explicit disabled colors with guaranteed ≥3:1 contrast. |
| A20 | 🔵 Low | **Growth chart not screen-reader navigable** | `growth_chart_screen.dart:165-286` | `fl_chart`'s `LineChart` has no a11y bindings. Outer `Semantics` describes chart but individual data points not exposed. | Provide companion `ListView` data table below chart with per-point `Semantics`. |

---

## Things Done Well

1. **Pervasive button semantics** — `ThemeButton` and `ThemeButton.icon` consistently accept and forward `semanticLabel` to `Semantics(button: true, label: ...)` — all 30+ callsites.
2. **Reduced motion respected** — `StaggeredFadeSlide`, `ScrollStagger`, `FadeScaleIn`, splash screen, `LevelUpCelebration` all check `MediaQuery.of(context).disableAnimations` and skip animations when true. Exemplary coverage.
3. **Form fields fully labeled** — Every `TextField`/`TextFormField` has `labelText` and usually `hintText`. `AuthTextField` systematically forwards both. Zero unlabeled inputs.
4. **Chart Semantics wrapper** — Growth chart `Semantics` label dynamically describes metric, data point count, and interaction mode ("swipe to pan"). Record list items have per-row `Semantics(button: true, label: ...)`.
5. **16 core widgets include `Semantics` wrappers** — `identity_card`, `settings_row`, `premium_stat_card`, `journal_entry_row`, `milestone_timeline_row`, `pending_approval_banner`, `photo_grid`, `photo_viewer`, etc. — systematic, reusable approach.
6. **Zero `ExcludeSemantics` uses** — no widgets actively hiding content from screen readers.
7. **52 `Semantics()` calls** across the codebase.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | Add font scaling support via `MediaQuery` `builder` in `MaterialApp.router` (clamped to 1.3x). | S |
| 2 | Fix `AppColors.disabled` to ≥#949494 for 3:1 AA. Replace alpha-only disabled states with explicit contrast-verified colors. | S |
| 3 | Set up i18n: add `flutter_localizations` dep, create `l10n.yaml`, extract strings to ARB. | L |
| 4 | Fix small tap targets: remove `shrinkWrap` from `SegmentedButton`s. Bump footer min height to 48. Bump photo close button to 48. | S |
| 5 | Add `semanticLabel` to `CachedNetworkImage` instances. | S |
| 6 | Add `Semantics` to onboarding step widgets. | M |
| 7 | Build accessible data-table companion for growth chart. | M |
