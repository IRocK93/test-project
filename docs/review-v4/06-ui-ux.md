# BabyMon UI/UX Design Audit — v4

**Date:** 2026-06-22
**Overall Grade: C+ (64/100)**

---

## CRITICAL BUG: Clay Theme Broken at Runtime

**File:** `app.dart:31`

The `styleKey` is constructed as `'${style.name.toLowerCase()}_${isLoggedIn ? 'loggedIn' : 'loggedOut'}'`, producing strings like `'clay_loggedIn'`. But `AppTheme.resolve()` does `visualStyle == 'clay'`. Since `'clay_loggedIn' !== 'clay'`, the Clay theme can NEVER activate. Every user who selects Clay is silently served Glass.

**Severity:** P0 — Theme toggle is completely non-functional.

---

## 1. Design System Audit

### Theme Architecture: A- (foundation) / F (runtime)
- Palette-agnostic helper functions are well-architected
- All 18 component themes are parameterized correctly
- Adding a third visual style requires only creating a new palette class
- But the runtime resolution bug makes it all moot

### Typography: B
- Syne (display) + Plus Jakarta Sans (body) is a thoughtful pairing
- **Defect:** `bodyLarge` and `bodyMedium` are identical (both fontSize: 16, height: 1.6)
- Bottom nav labels at `fontSize: 11` — below WCAG minimum for touch

### Color Palette: B
- Well-structured `AppColors` class with semantically named colors
- Clay palette is well-organized with warm/earthy tones
- But 150+ hardcoded AppColors references bypass the theme system

---

## 2. Design Token Compliance: 42/100

### Worst Offenders — Auth Screens
Both `login_screen.dart` and `register_screen.dart` use `AppColors.*` for every color value, completely bypassing `Theme.of(context).colorScheme`. Over 80 direct AppColors references between them.

### Hardcoded Colors.flutterMaterial
- `daily_brief_screen.dart`: 5 references to `Colors.white`
- `routine_screen.dart`: 5 references to `Colors.white`
- `feed_log_card.dart`: `Colors.grey[500]`, `Colors.teal.withOpacity(0.3)`, `Colors.tealAccent`
- `feed_log_form.dart`: `Colors.deepPurple.withOpacity(0.3)`, `Colors.white`
- `milestone_card.dart`: `Colors.deepPurple.withOpacity(0.3)`

### Deprecated `.withOpacity()` Usage: 11 locations
Flutter 3.x deprecated `.withOpacity()` in favor of `.withValues(alpha:)`.

### Compliance by Screen
| Screen | Compliance |
|--------|-----------|
| Auth (login/register) | 0% — fully bypasses theme |
| Dashboard | ~60% |
| Companion | ~50% |
| Health/Sleep | ~70% |
| Journal | ~75% |
| Settings | ~85% (best) |

---

## 3. Screen-by-Screen Highlights

### SplashScreen: B+
Clean animated splash with well-structured animation timeline. Lacks app version label.

### Dashboard: B-
Bento-grid layout with reorderable tiles is well-designed. XP progress bar uses `MediaQuery.of(context).size.width * value` — breaks on landscape/tablet. Gender accent colors from AppColors.

### Milestones: C+
Standard list-based screen. Lacks timeline visualization. Hardcoded purple background on milestone cards.

### Feeding: C+
Good emoji-based type indicators. Multiple hardcoded color issues in card and form widgets.

### Health/Sleep/Growth: B-
Most complex feature area. Well-organized tab structure. Growth chart uses proper WHO percentile analysis. Some hardcoded grey values in cards.

### Journal: B
Uses `DataScreenMixin` with cooldown. Filter chips with count badges. Swipe-to-delete with `ConfirmDeleteDialog` and haptic feedback. Proposal system is smart UX.

### Companion (AI Chat): B-
Full chat interface with `ThinkingIndicator`. Safety classifier checks for emergency keywords. `MedicalDisclaimerGate` is responsible. Chat bubbles use `Colors.white` — should use theme.

---

## 4. Accessibility: 52/100

### Violations
- Font sizes below 11sp in 4 locations — fails WCAG 2.1 SC 1.4.4
- No minimum touch target enforcement (48dp)
- No text scaling support — only `ThemeText` widget handles `textScaler`
- `ExcludeSemantics` used in photo_grid, photo_viewer, settings_row — hiding meaningful UI

### Strengths
- 62 `Semantics()` widget instances across 36 files
- Better than most Flutter apps

---

## 5. Responsive Design: 25/100

Only 4 references to `MediaQuery.of(context).size` across all feature screens. No `LayoutBuilder`, `OrientationBuilder`, or adaptive layout patterns. Tablet drawer at 70% width = ~500dp (past Material max of 360dp).

---

## 6. Interaction Design: B

- 20 haptic feedback calls concentrated in info_fab, theme_button, journal, level_up_celebration
- 27 animation widgets with centralized curve tokens in `DesignTokens`
- Loading states use `PremiumLoading` with spinner and skeleton variants
- Empty states use `PremiumEmptyState` presets (noData, comingSoon)
- Error states are inconsistent — mostly `showError()` without inline retry

---

## 7. Visual Polish Recommendations

### Immediate (P0)
1. Fix Clay theme resolution bug in `app.dart:31`
2. After fixing, review auth screens under Clay — they'll look wrong

### Short-term (P1)
3. Refactor auth screens to use `Theme.of(context).colorScheme`
4. Remove all `Colors.white` hardcoded references
5. Replace all `.withOpacity()` with `.withValues(alpha:)`
6. Differentiate `bodyLarge` and `bodyMedium` in typography
7. Add text scaling support to all screens

### Medium-term (P2)
8. Create `BentoColors` token set in theme extension
9. Build responsive layouts with `LayoutBuilder`
10. Replace spinner loading with skeleton screens
11. Test all screens at 200% font scale
12. Decompose CreateBabyMonScreen into step widgets
13. Add tab-swipe gesture navigation
