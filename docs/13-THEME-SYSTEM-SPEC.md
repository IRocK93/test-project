# BabyMon Theme System — V2 Architecture & Best Practices Specification

**Status:** Spec (not yet implemented)
**Created:** 13 June 2026
**Scope:** Flutter mobile frontend — theme architecture upgrade
**Builds on:** V1 theme system (Glass/Clay toggle implemented in `docs/12-XP-SYSTEM-SPEC.md` companion work)

---

## 1. V1 Current State Assessment

### 1.1 What Was Built

| Component | File | Status |
|---|---|---|
| Clay palette tokens | `lib/core/theme/clay_colors.dart` | ✅ Complete |
| Theme mode provider | `lib/core/theme/theme_mode_provider.dart` | ✅ Complete |
| Glass light/dark themes | `lib/core/theme/app_theme.dart` | ✅ Complete |
| Clay light/dark themes | `lib/core/theme/app_theme.dart` | ✅ Complete |
| App.dart wiring | `lib/app.dart` | ✅ Complete |
| Settings toggle | `lib/features/settings/presentation/screens/settings_screen.dart` | ✅ Complete |

### 1.2 V1 Limitations Identified

| # | Issue | Severity | User-Visible? |
|---|---|---|---|
| 1 | **Init flash** — `AppVisualThemeNotifier` initializes as `glass`, then async-loads saved pref. One frame renders Glass before switching to Clay on cold start | High | Yes — visible flicker |
| 2 | **Hardcoded `_textTheme` references `AppColors`** — clay themes work around this with `.apply()` but it's fragile. Adding a third theme would compound the problem | Medium | No (current hack works) |
| 3 | **Theme resolution in `app.dart`** — conditional logic for 4 `ThemeData` instances with repeated pattern. Should be a single provider | Medium | No (code quality) |
| 4 | **No system mode integration** — Clay = light mode, Glass = dark mode, regardless of system setting. User can't choose dark Clay or light Glass | High | Yes — missing UX |
| 5 | **No animated transition** — theme switch flashes instantly instead of cross-fading | Medium | Yes — jarring UX |
| 6 | **Contrast audit needed** — clay palette uses softer browns/creams that may fall below WCAG AA (4.5:1) | High | Yes — accessibility |
| 7 | **`AppColors` leakage in shared helpers** — `_snackBarTheme`, `_dividerTheme`, `_progressTheme`, `_bottomSheetTheme` reference `AppColors` statics, which carry over to Clay unintentionally where not explicitly overridden | Medium | Yes — incorrect colors |
| 8 | **No theme architecture documentation** | Low | No (onboarding) |

---

## 2. V2 Architecture — Target State

### 2.1 Domain Model

```
┌──────────────────────────────────────────────────┐
│                  ThemeMode (system)               │
│  light  ──  dark  ──  system (follows OS)        │
└──────────────────┬───────────────────────────────┘
                   │ combined with
┌──────────────────▼───────────────────────────────┐
│              AppVisualStyle                       │
│  glass  ──  clay  ──  (extensible)                │
└──────────────────┬───────────────────────────────┘
                   │ resolves to
┌──────────────────▼───────────────────────────────┐
│              Concrete ThemeData                    │
│  glassLight  glassDark  clayLight  clayDark       │
└──────────────────────────────────────────────────┘
```

**Key insight:** `ThemeMode` and `AppVisualStyle` are orthogonal. The user gets two independent controls:
- **Style:** Glass (default) or Clay
- **Mode:** Follow System, Light, or Dark

This surfaces in Settings as two rows instead of one.

### 2.2 Provider Architecture

```
appThemeModeProvider (ThemeMode)     ──┐
                                       ├──→ appThemeProvider (ThemeData)
appVisualStyleProvider (AppVisualStyle) ──┘

app.dart watches ONLY appThemeProvider
```

**Rationale:** `app.dart` should know nothing about how themes resolve. It watches one provider that returns `ThemeData`. All theme selection logic lives in `appThemeProvider`.

---

## 3. Implementation Plan — All 8 Improvements

### 3.1 Fix Init Flash (#1)

**Problem:** `AppVisualThemeNotifier._init()` is async (loads from SharedPreferences). The constructor sets `super(AppVisualTheme.glass)`, so the provider value is `glass` for one frame until `_init()` completes and flips to `clay`.

**Fix:** Convert to `FutureProvider` pattern — the provider emits nothing until the preference is loaded. `app.dart` shows a brief splash/spinner during theme resolution, then renders with the correct theme.

**Files to change:**
- `theme_mode_provider.dart` — replace `StateNotifierProvider` with `FutureProvider` + `StateNotifierProvider` combo
- `app.dart` — add `.when(loading: () => splash, data: (theme) => ...)` to `appThemeProvider`

**Implementation:**

```dart
// theme_mode_provider.dart
final savedVisualStyleProvider = FutureProvider<AppVisualStyle>((ref) async {
  return _loadStylePref();
});

// app.dart
final appThemeProvider = Provider<ThemeData>((ref) {
  final savedAsync = ref.watch(savedVisualStyleProvider);
  return savedAsync.maybeWhen(
    data: (style) => _resolveTheme(style, ref.watch(appThemeModeProvider)),
    orElse: () => AppTheme.glassDarkTheme, // fallback while loading
  );
});
```

### 3.2 Parameterize Text Theme (#2)

**Problem:** `_textTheme` getter hardcodes `AppColors.textPrimary`, `AppColors.textSecondary`, etc. The clay themes work around this with `.apply()` to override colors, but the base colors are still baked in.

**Fix:** Make `_textTheme` accept a `Color textPrimary, Color textSecondary, Color textCaption, Color textOnPrimary` parameter object or a simple record.

```dart
static TextTheme _textTheme({
  required Color textPrimary,
  required Color textSecondary,
  required Color textCaption,
  required Color textOnPrimary,
}) {
  return TextTheme(
    displayLarge: display(textStyle: TextStyle(..., color: textPrimary)),
    bodySmall: ui(textStyle: TextStyle(..., color: textSecondary)),
    labelSmall: ui(textStyle: TextStyle(..., color: textCaption)),
    labelLarge: ui(textStyle: TextStyle(..., color: textOnPrimary)),
    // ...
  );
}
```

Each theme then calls:
```dart
// Glass light
textTheme: _textTheme(
  textPrimary: AppColors.textPrimary,
  textSecondary: AppColors.textSecondary,
  textCaption: AppColors.textCaption,
  textOnPrimary: AppColors.textOnPrimary,
),

// Clay light
textTheme: _textTheme(
  textPrimary: ClayColors.textPrimary,
  textSecondary: ClayColors.textSecondary,
  textCaption: ClayColors.textCaption,
  textOnPrimary: ClayColors.textOnPrimary,
),
```

**No more `apply()` hacks.** Each theme is self-contained.

### 3.3 Centralize Theme Resolution (#3)

**Problem:** `app.dart` has this pattern:
```dart
theme: visualTheme == AppVisualTheme.clay ? AppTheme.clayLightTheme : AppTheme.lightTheme,
darkTheme: visualTheme == AppVisualTheme.clay ? AppTheme.clayDarkTheme : AppTheme.darkTheme,
themeMode: visualTheme == AppVisualTheme.clay ? ThemeMode.light : ThemeMode.dark,
```

This is fragile — adding a third theme means more ternary operators. And it conflates style with mode.

**Fix:** Create a single resolver function that maps `(AppVisualStyle, ThemeMode)` → `ThemeData`:

```dart
// app_theme.dart — new public method
static ThemeData resolve({required AppVisualStyle style, required Brightness brightness}) {
  switch (style) {
    case AppVisualStyle.clay:
      return brightness == Brightness.light ? clayLightTheme : clayDarkTheme;
    case AppVisualStyle.glass:
      return brightness == Brightness.light ? lightTheme : darkTheme;
  }
}
```

Then `app.dart` simplifies to:
```dart
final style = ref.watch(appVisualStyleProvider);
final themeMode = ref.watch(appThemeModeProvider);
final brightness = themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
// or resolve from MediaQuery if using system mode

return MaterialApp.router(
  theme: AppTheme.resolve(style: style, brightness: Brightness.light),
  darkTheme: AppTheme.resolve(style: style, brightness: Brightness.dark),
  themeMode: themeMode,
  // ...
);
```

### 3.4 System Mode Integration (#4)

**Problem:** Currently Clay = forced light, Glass = forced dark. User can't have dark Clay or light Glass.

**Fix:** Split the single toggle into **two independent settings:**

**Settings → Preferences → Appearance:**

```
┌──────────────────────────────────────────────┐
│ 🎨  Appearance                               │
│                                              │
│  Visual Style                                │
│  [ Glass ]  [ Clay ]    ← persisted          │
│                                              │
│  Theme Mode                                  │
│  [ System ] [ Light ] [ Dark ]  ← persisted  │
└──────────────────────────────────────────────┘
```

**New provider: `appThemeModeProvider`**
```dart
enum AppThemeMode { system, light, dark }

final appThemeModeProvider = StateNotifierProvider<AppThemeModeNotifier, AppThemeMode>((ref) {
  return AppThemeModeNotifier();
});
```

**Persistence keys:**
- `app_visual_style` → `glass` | `clay` (already exists as `app_visual_theme`)
- `app_theme_mode` → `system` | `light` | `dark` (new)

**Backward compatibility:** The existing `app_visual_theme` pref is renamed to `app_visual_style` during migration. On first launch after upgrade, the app reads the old key, migrates to the new key, and deletes the old one.

### 3.5 Animated Theme Transitions (#5)

**Problem:** Switching themes currently flashes — the old theme disappears and the new one appears instantly.

**Fix:** Wrap `MaterialApp.router` in an `AnimatedTheme` or use a `ValueListenableBuilder` with a custom transition:

```dart
// app.dart
final theme = ref.watch(appThemeProvider);

return AnimatedTheme(
  data: theme,
  duration: DesignTokens.durationPage, // 400ms
  curve: DesignTokens.curvePremium,
  child: Builder(
    builder: (context) => MaterialApp.router(
      theme: Theme.of(context),
      // ...
    ),
  ),
);
```

**Important:** Test that `AnimatedTheme` doesn't cause rebuild loops with Riverpod. Alternative: use a `TweenAnimationBuilder<ThemeData>` wrapping just the transition:

```dart
return TweenAnimationBuilder<ThemeData>(
  tween: ThemeDataTween(begin: _previousTheme, end: theme),
  duration: DesignTokens.durationPage,
  curve: DesignTokens.curvePremium,
  builder: (context, tweened, _) {
    _previousTheme = tweened;
    return MaterialApp.router(
      theme: tweened,
      // ...
    );
  },
);
```

### 3.6 WCAG Contrast Audit (#6)

**Problem:** The clay palette was designed for aesthetics without formal contrast verification.

**Audit targets (minimum 4.5:1 for normal text, 3:1 for large text):**

| Pair | Colors | Expected Ratio | Notes |
|---|---|---|---|
| `textPrimary` on `background` | #2E2925 / #F3EFE9 | ~12.8:1 ✅ | Passes easily |
| `textSecondary` on `claySurface` | #6B635C / #FDFBFA | ~4.8:1 ✅ | Barely passes — verify |
| `textCaption` on `clayElevated` | #8E8680 / #F6F2EA | ~3.9:1 ⚠️ | Below 4.5:1 — **fails AA for normal text** |
| `textOnPrimary` on `primary` | #FFFFFF / #C17F59 | ~3.2:1 ⚠️ | Below 4.5:1 — verify with actual hex |
| `primary` on `claySurface` | #C17F59 / #FDFBFA | ~2.5:1 ❌ | **Fails AA** — decorative only, not text |

**Fix (if any fail):**
- Darken `textCaption` from #8E8680 → #6E6660 (gain ~1.5 ratio points)
- Lighten `clayElevated` from #F6F2EA → #FDFBFA (minor gain)
- The `textOnPrimary` on `primary` pair is borderline — increase font weight to `w600` for all white-on-terracotta text (bold text only needs 3:1)
- Add `Semantics` labels for any decoratively-colored text

**Tool:** Use Flutter's `computeLuminance()` + manual calculation during implementation, or verify with an online WCAG calculator using the exact hex values.

### 3.7 Fix `AppColors` Leakage (#7)

**Problem:** Several shared `_*Theme` getters in `app_theme.dart` reference `AppColors` members directly:

| Getter | References `AppColors.X` | Affects Clay? |
|---|---|---|
| `_snackBarTheme` | `textOnDark` | Yes — uses wrong color group |
| `_dividerTheme` | `divider` | Yes |
| `_progressTheme` | `primary`, `divider` | Yes — uses glass purple not clay terracotta |
| `_bottomSheetTheme` | `divider` | Yes |
| `_elevatedButtonTheme` | `primary`, `textOnPrimary`, `disabled` | Yes — uses hardcoded glass colors |
| `_outlinedButtonTheme` | `primary` | Yes |
| `_textButtonTheme` | `primary` | Yes |
| `_fabTheme` | `secondary`, `textOnPrimary` | Yes |
| `_chipTheme` | `primaryContainer`, `disabled` | Partially — overridden in clay |
| `_segmentedButtonTheme` | `primaryContainer`, `primary` | Partially — overridden in clay |
| `_expansionTileTheme` | `textSecondary`, `textCaption` | Partially — overridden in clay |

**Fix:** All these shared getters should accept their color values as parameters, just like `_cardTheme`, `_inputTheme`, `_appBarTheme`, `_chipTheme`, `_dialogTheme` already do. Pattern:

```dart
// Before (broken for multi-theme):
static ProgressIndicatorThemeData get _progressTheme =>
    const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.divider,
      circularTrackColor: AppColors.divider,
    );

// After (theme-agnostic):
static ProgressIndicatorThemeData _progressTheme({
  required Color color,
  required Color trackColor,
}) =>
    ProgressIndicatorThemeData(
      color: color,
      linearTrackColor: trackColor,
      circularTrackColor: trackColor,
    );
```

Each theme then passes its own palette:
```dart
// Glass darkTheme:
progressIndicatorTheme: _progressTheme(
  color: AppColors.primaryLight,
  trackColor: AppColors.divider,
),

// Clay lightTheme:
progressIndicatorTheme: _progressTheme(
  color: ClayColors.primary,
  trackColor: ClayColors.divider,
),
```

**Files to change:** Only `app_theme.dart` — this is a refactoring of the existing shared helpers.

### 3.8 Theme Architecture Documentation (#8)

**This document (`docs/13-THEME-SYSTEM-SPEC.md`) serves as the architecture documentation.** It covers the domain model, provider architecture, palette token maps, and how to add a third theme.

---

## 4. Palette Token Reference

### 4.1 Glass Palette (`AppColors`)

| Token | Light Value | Dark Value | Usage |
|---|---|---|---|
| `primary` | #7C5CFC | #A29BFE | CTAs, active states, emphasis |
| `secondary` | #FF7E67 | #FFAB91 | FAB, secondary CTAs |
| `accent` | #4DD0C1 | #80DEEA | Progress, health data |
| `background` | #F8F7FA | #0E0E12 | Scaffold bg |
| `surface` | #FFFFFF | #1A1A22 | Card, nav bar bg |
| `textPrimary` | #1A1A2E | #F0F0F5 | Headings, body |
| `textSecondary` | #5C5C5C | #A0A0B0 | Subtitles, metadata |
| `textCaption` | #6B6B6B | #808090 | Small labels, hints |
| `success` | #4CAF50 | — | Positive states |
| `warning` | #FFA726 | — | Caution states |
| `error` | #E53935 | — | Destructive actions |
| `glassBorder` | #40FFFFFF | #40FFFFFF | Card borders |
| `bentoGold` | #FFB74D | — | Badge achievements |

### 4.2 Clay Palette (`ClayColors`)

| Token | Light Value | Dark Value | Usage |
|---|---|---|---|
| `primary` | #C17F59 | #D9A882 | CTAs, active states |
| `secondary` | #8FA88A | #B2C5AE | FAB, secondary CTAs |
| `accent` | #D4A96A | #E8C98F | Progress, health data |
| `background` | #F3EFE9 | #1C1815 | Scaffold bg |
| `claySurface` | #FDFBFA | #2E2A26 | Card bg |
| `textPrimary` | #2E2925 | #F0EDE8 | Headings, body |
| `textSecondary` | #6B635C | #B0A99E | Subtitles, metadata |
| `textCaption` | #8E8680 | #908A82 | Small labels (⚠️ check contrast) |
| `success` | #7CAB7C | — | Positive states |
| `warning` | #D4A060 | — | Caution states |
| `error` | #C1756B | — | Destructive actions |
| `clayBorder` | #E8E3DB | #4A453E | Card borders |

---

## 5. Adding a Third Theme — Architecture Test

The architecture should support adding a third visual style (e.g., "Neumorphic", "Brutalist", "High-Contrast") with **zero changes to any screen file.** Only these files should need modification:

1. `lib/core/theme/` — new palette file (e.g., `neo_colors.dart`)
2. `app_theme.dart` — add `neoLightTheme` and `neoDarkTheme` getters
3. `theme_mode_provider.dart` — add `neo` to `AppVisualStyle` enum
4. `settings_screen.dart` — add `ButtonSegment(value: AppVisualStyle.neo, label: Text('Neo'))` to the toggle

If this test fails (i.e., if a screen needs modification), the architecture is wrong. This is the litmus test.

---

## 6. Files Summary — V2 Implementation

### 6.1 Files to Modify

| File | Changes | Complexity |
|---|---|---|
| `lib/core/theme/theme_mode_provider.dart` | Rewrite: add `AppThemeMode` enum, new `appThemeModeProvider`, rename `appVisualThemeProvider` → `appVisualStyleProvider`, add migration logic for old pref key | Medium |
| `lib/core/theme/app_theme.dart` | Major refactor: parameterize all shared helpers (#7), add `resolve()` method (#3), remove all `AppColors` static references from shared getters | Large |
| `lib/app.dart` | Simplify: watch single `appThemeProvider`, add animated transition (#5) | Small |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Add second row for Theme Mode (System/Light/Dark), update import for renamed provider | Small |

### 6.2 Files to Create

| File | Purpose |
|---|---|
| `docs/13-THEME-SYSTEM-SPEC.md` | ✅ This document |

### 6.3 Files NOT Changed

| File | Reason |
|---|---|
| `lib/core/theme/clay_colors.dart` | Palette tokens are correct (possibly minor contrast tweaks at implementation time) |
| `lib/core/constants/app_colors.dart` | Glass palette unchanged |
| Any screen file in `lib/features/` | Theme resolution is centralized — screens reference `Theme.of(context)` as always |

---

## 7. Migration Path (User-Facing)

### 7.1 For New Users
- Default: Glass style + System mode
- No migration needed

### 7.2 For Existing Users (had Glass/Clay toggle)
- Old pref key `app_visual_theme` → read once, convert to new `app_visual_style` key, delete old
- Theme mode defaults to `system` for existing users
- If they previously had Clay selected: they get Clay + System mode (which may render as light if their OS is light, dark if dark)

### 7.3 Upgrade Code
```dart
Future<AppVisualStyle> _migrateStylePref() async {
  final prefs = await SharedPreferences.getInstance();
  final oldKey = 'app_visual_theme';
  final newKey = 'app_visual_style';
  
  // Try old key first
  final oldValue = prefs.getString(oldKey);
  if (oldValue != null) {
    final style = oldValue == 'clay' ? AppVisualStyle.clay : AppVisualStyle.glass;
    await prefs.setString(newKey, oldValue);
    await prefs.remove(oldKey);
    return style;
  }
  
  // Try new key
  final newValue = prefs.getString(newKey);
  if (newValue == 'clay') return AppVisualStyle.clay;
  return AppVisualStyle.glass;
}
```

---

## 8. Testing Checklist

### Visual Correctness
- [ ] Glass + Light mode: all screens render with correct glass palette
- [ ] Glass + Dark mode: all screens render with correct glass palette
- [ ] Clay + Light mode: all screens render with correct clay palette
- [ ] Clay + Dark mode: all screens render with correct clay palette
- [ ] System mode: follows OS setting correctly

### Transition Behavior
- [ ] Switching style animates smoothly (no flash)
- [ ] Switching mode animates smoothly (no flash)
- [ ] Cold-start renders correct persisted theme (no init flash)

### Accessibility
- [ ] All text/surface pairs pass WCAG AA (4.5:1 normal, 3:1 large)
- [ ] Screen reader announces theme change (optional — nice to have)

### Migration
- [ ] Old `app_visual_theme` pref key is migrated to new `app_visual_style`
- [ ] Old key is deleted after migration
- [ ] Fresh install has no pref and defaults correctly

### Code Quality
- [ ] No `AppColors` references in shared `_*Theme` getters
- [ ] No hardcoded color values in `app_theme.dart`
- [ ] Adding a third theme requires only the 4 files listed in section 6.1

---

## 9. Implementation Order (Recommended)

1. **#7 first** (parameterize shared helpers) — pure refactoring, no user-facing change, makes all other changes cleaner
2. **#2** (parameterize text theme) — same rationale, pure refactoring
3. **#3 + #4 together** (centralize resolution + system mode) — these are intertwined, do them in one pass
4. **#6** (contrast audit) — verify and tweak clay palette values as needed
5. **#1** (init flash) — with centralized resolution in place, this becomes straightforward
6. **#5 last** (animated transition) — cosmetic, low risk, can be done independently

---

## 10. References

- Flutter `ThemeData` documentation: https://api.flutter.dev/flutter/material/ThemeData-class.html
- WCAG 2.1 Contrast Requirements: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html
- Riverpod Provider patterns: https://riverpod.dev/docs/concepts/providers
- `AnimatedTheme` widget: https://api.flutter.dev/flutter/material/AnimatedTheme-class.html