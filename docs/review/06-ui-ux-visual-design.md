# 06 — UI/UX & Visual Design Audit

**Date:** 2026-06-17
**Severity Score:** 🟡 Medium (2 Critical, 5 High, 5 Medium, 3 Low)
**Verdict:** Surprisingly mature design system for a Flutter app. Minor hardcoded-color and dark-mode gaps.

---

## Summary

BabyMon has a **surprisingly mature design system** — the dual-theme architecture (Glass + Clay, each with light/dark) is well-architected with palette-agnostic component helpers, a pattern rarely seen outside large design systems. The component library (38 widgets) is extensive with strong abstractions (`PremiumCard`, `DataScreenMixin`, `ScalePress`). Typography uses a deliberate two-font system (Syne for display, Plus Jakarta Sans for body) with documented WCAG AA contrast ratios. However, there are meaningful polish gaps: a `LoadingWidget` that breaks dark mode by hardcoding white, a `PremiumEmptyState` hardcoded to Glass palette, 28 hardcoded `Color(0x...)` literals in celebration/auth widgets that bypass `AppColors`, remaining Material `Icons.*` in 5 files after the Phosphor migration, and a `shimmer` widget with no actual shimmer animation. The 5-step onboarding wizard may be too long.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| UI01 | 🔴 Critical | **`LoadingWidget` hardcodes white — breaks dark mode** | `lib/core/widgets/loading_widget.dart:20` | `color: Colors.white` — no dark mode awareness. | Use `Theme.of(context).colorScheme.surface`. |
| UI02 | 🔴 Critical | **`PremiumEmptyState` hardcodes `AppColors`, ignores Clay theme** | `lib/core/widgets/premium_empty_state.dart:79,86` | `AppColors.primaryContainer` — always Glass palette. Clay mode users see Glass colors in empty states. | Accept `Color? primaryColor` param or use `Theme.of(context).colorScheme`. |
| UI03 | 🟠 High | **28 hardcoded `Color(0x...)` literals in celebration/auth widgets** | `level_up_celebration.dart` (16), `dashboard_badge_section.dart` (4), `login_screen.dart` (1), `register_screen.dart` (1), `main.dart` (4), `premium_background.dart` (2) | Bypass `AppColors` and `DesignTokens`. Any palette change requires hunting through widget files. | Extract to named constants (e.g., `LevelUpColors.gold`, `BadgeTier.colors`, `SocialBrand.facebookBlue`). |
| UI04 | 🟠 High | **`Icons.*` Material icons remain in 5 files after Phosphor migration** | `data_screen_mixin.dart:47,224,245`; `level_up_celebration.dart:180-182`; `main_screen.dart:198`; `main.dart:21` | `Icons.inbox`, `Icons.child_care`, `Icons.eco`, `Icons.star`, `Icons.error_outline`, `Icons.keyboard_arrow_down` — breaks visual consistency. | Replace with `PhosphorIconsLight` equivalents. |
| UI05 | 🟠 High | **`PremiumLoading.shimmer` has no shimmer — just static colored boxes** | `lib/core/widgets/premium_loading.dart:51-91` | `cardSkeleton` and `listTileSkeleton` are colored `Container`s with no gradient animation. | Implement true `Shimmer` gradient animation or rename to `SkeletonPlaceholder`. |
| UI06 | 🟠 High | **Sleep screen: `shrinkWrap: true` `ListView.builder` inside `SingleChildScrollView`** | `lib/features/health/presentation/screens/sleep_screen.dart:318,348` | `NeverScrollableScrollPhysics` + `shrinkWrap: true` — all items render at once, no lazy loading. | Use `CustomScrollView` + `SliverList`. |
| UI07 | 🟠 High | **`bodyLarge` and `bodyMedium` have identical definitions** | `lib/core/theme/app_theme.dart:68-73` | Both: `fontSize: 16, fontWeight: w400, height: 1.6`. Duplicate token. | Differentiate (e.g., `bodyMedium: fontSize: 14`) or remove one. |
| UI08 | 🟡 Medium | **5-step wizard may be too long** | `create_baby_mon_screen.dart:28` | `_totalSteps = 5`: Splash, Name, Date/Stage, Traits/Gender, Review. Step 4 has optional fields. | Consider merging Steps 3+4 or making splash skippable on repeat. |
| UI09 | 🟡 Medium | **Clay theme button radius not tokenized** | `lib/core/theme/app_theme.dart:411-412` | `radius: DesignTokens.radiusMd + 4` — inline arithmetic. | Add `DesignTokens.radiusClayBtn` token. |
| UI10 | 🟡 Medium | **`ScreenHeader` uses inline font styling** | `lib/core/widgets/screen_header.dart:86-90` | `fontSize: 17, fontWeight: w700, letterSpacing: -0.3` — hardcoded. | Use `Theme.of(context).textTheme.titleLarge`. |
| UI11 | 🟡 Medium | **Growth chart: horizontal `SingleChildScrollView` with no day limit** | `lib/features/health/presentation/screens/growth_chart_screen.dart:348` | All day-bars render regardless of viewport. Could be expensive with many days. | Add day-count limit (e.g., max 90 days displayed). |
| UI12 | 🟡 Medium | **Dashboard `setState` rebuilds entire widget tree** | `dashboard_screen.dart:193-196,225-228` | Multiple `setState` calls rebuild the entire ~600-line widget tree. | Extract sections into independent widgets with granular state. |
| UI13 | 🔵 Low | **Subscription screen: no trial expiry urgency CTA** | `subscription_screen.dart:155-158` | `_trialDaysRemaining` displayed as static banner — no countdown or urgency. | Add countdown timer or progress bar for trial expiry. |
| UI14 | 🔵 Low | **Dashboard onboarding: manually managed loading state** | `dashboard_screen.dart:449-457` | Dashboard uses `_isLoading`/`_babyMonId` instead of `DataScreenMixin`. | Consider using `DataScreenMixin` or document why not. |
| UI15 | 🔵 Low | **Inline `TextStyle` in badge level-up widgets** | `level_up_celebration.dart:316` — `color: Color(0xFF5D4037)` | Raw TextStyle with hardcoded color for "GRAND MASTER" text. | Use theme text styles or define named style constants. |

---

## Things Done Well

1. **Dual-theme architecture (Glass + Clay)** — Exceptional. Palette-agnostic helpers mean adding a third visual style requires zero screen changes. `AppTheme.resolve()` is clean.
2. **WCAG AA contrast documented** — `app_colors.dart` documents actual contrast ratios (e.g., `textSecondary: 7.3:1 on white`). Rare in Flutter apps.
3. **Design tokens comprehensive** — 250 lines: spacing scale (4px base), radius, glass blur, bento grid, durations, curves, shadows, icon sizes, avatar sizes, card dimensions.
4. **`DataScreenMixin`** — Eliminates loading/empty/no-BabyMon boilerplate across 7+ screens. Cooldown support. CancelToken cleanup. Professional pattern.
5. **Component library (38 widgets)** — Barrel-exported, organized by category. `PremiumCard` with `glassGroup` for shared `BackdropFilter`. `ScalePress` with magnetic translate.
6. **Animation discipline** — All use `DesignTokens.curvePremium`, `staggerDelayMs`. `MediaQuery.disableAnimations` respected. Controllers properly disposed.
7. **Onboarding step indicator** — 5-step pill with animated width transitions, completion checkmarks, gradient progress bars. Polished.
8. **Dashboard reorderability** — Long-press drag tiles, order persisted. 10s cooldown prevents redundant fetches. Background-resume detection.
9. **Typography system** — Syne (display) + Plus Jakarta Sans (body). Multiple weights. Documented contrast.
10. **Phosphor icons used consistently** (250× across 46 files) — clean modern icon system.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | Fix `LoadingWidget` dark-mode break — use theme surface color. | S |
| 2 | Make `PremiumEmptyState` theme-aware — use `Theme.of(context).colorScheme`. | S |
| 3 | Extract 28 hardcoded `Color(0x...)` literals to named constants. | M |
| 4 | Replace remaining `Icons.*` with `PhosphorIconsLight`. | S |
| 5 | Implement real shimmer animation in `PremiumLoading.shimmer`. | M |
| 6 | Refactor sleep screen to `CustomScrollView` + `SliverList`. | M |
| 7 | Fix duplicate `bodyLarge`/`bodyMedium` text theme. | S |
| 8 | Tokenize Clay button radius override. | S |
| 9 | Make `ScreenHeader` use theme text styles. | S |
| 10 | Add day-count limit to growth chart. | S |
| 11 | Evaluate onboarding flow length — consider merging steps. | L |
| 12 | Add trial countdown urgency to subscription screen. | M |
