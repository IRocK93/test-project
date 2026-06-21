# S13 — Accessibility Audit

**Date:** 2026-06-18 | **Overall Grade:** C+ — Marginal WCAG AA Fail

---

## Key Findings

### A11-C01 | 🔴 CRITICAL | No i18n Infrastructure
Zero `flutter_localizations`, no `.arb` files, every string hardcoded in English. App is English-only with no RTL support.

### A11-H01 | 🟠 HIGH | Clay Theme Button Contrast FAILS WCAG AA
`ClayColors.primary` (#C17F59) on white text at 15px = 3.1:1 ratio (4.5:1 required). Used on filled `ThemeButton` everywhere.

### A11-H02 | 🟠 HIGH | Glass secondary (#FF7E67) on white FAILS at 2.6:1
### A11-M01 | 🟡 MEDIUM | 40dp FAB.small and 40×40dp close button below 48dp minimum
### A11-M02 | 🟡 MEDIUM | No `SemanticsService.announce()` — status changes not announced to screen readers
### A11-M03 | 🟡 MEDIUM | "Tap" used as generic semantic label on stat cards and bezels
### A11-M04 | 🟡 MEDIUM | Overlays (InfoFab, LevelUpCelebration) don't trap focus
### A11-M05 | 🟡 MEDIUM | `ScalePress` and `InfoFab` animations ignore reduced motion preferences

## Strengths
- ✅ 39+ `Semantics()` calls across shared widgets
- ✅ `DashboardXpCard` and `DashboardGrowthCard` have excellent semantic labels
- ✅ 3 core animation widgets respect `disableAnimations`
- ✅ `LevelUpCelebration` has exemplary reduced motion support
- ✅ Golden semantics tests cover both themes × light/dark
- ✅ No `MediaQuery.textScaleFactor` override (allows system font scaling)
- ✅ Haptic feedback in 20 locations across 12 files

## Top Priority Fixes
1. Add i18n — `flutter_localizations` + `.arb` files + `localizationsDelegates`
2. Darken Clay primary to ~#A45D35 for 4.5:1 contrast
3. Grow touch targets to 48dp minimum
4. Add `SemanticsService.announce()` for status changes
5. Replace "Tap" labels with actual content text
