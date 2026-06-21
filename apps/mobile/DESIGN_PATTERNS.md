# BabyMon — Design Pattern Documentation

## Visual Identity

### Brand Colors
| Token | Value | Role |
|---|---|---|
| `AppColors.primary` | Warm violet (#6C63FF) | Primary actions, active states, brand accent |
| `AppColors.secondary` | Soft coral (#FF6B6B) | Secondary accents, heart icons, highlights |
| `AppColors.accent` | Calm teal (#4ECDC4) | Tertiary accents, variety |
| `AppColors.textPrimary` | Deep navy (#1A1A2E) | Primary text on light backgrounds |
| `AppColors.textOnDark` | Soft white (#F0F0F5) | Primary text on dark backgrounds |
| `AppColors.surface` | Off-white (#FAFAFF) | Screen backgrounds (light) |
| `AppColors.surfaceDark` | Deep navy (#0F0F23) | Screen backgrounds (dark) |

### Typography
- **Display font:** Syne (geometric, distinctive) — for headlines, splash, stage hero
- **UI font:** Plus Jakarta Sans (humanist, readable) — for body, labels, captions
- **Font scale:** `fontXs`(10) → `font2xs`(11) → `fontSm`(12) → `fontSm2`(13) → `fontMd`(14) → `fontMd2`(15) → `fontLg`(16) → `fontLg2`(18) → `fontXl`(20) → `fontXl2`(22) → `font2xl`(24) → `font3xl`(32) → `font4xl`(48) → `font5xl`(64)

### Visual Styles
- **Glass (default):** Frosted glass with `BackdropFilter`, semi-transparent surfaces, hairline borders, depth shadows
- **Clay:** Warm terracotta/sage palette, dual-shadow system (outer + inner highlight), softer geometry

---

## Component Library

### Core Primitives

#### `ThemeButton`
The primary button component. Three variants:
- `ThemeButtonVariant.filled` — solid primary background, white text
- `ThemeButtonVariant.outlined` — transparent with primary border
- `ThemeButtonVariant.text` — no border, primary text only

Props: `label`, `onPressed`, `variant`, `fullWidth`, `height`, `borderRadius`, `isLoading`, `prefix/suffixIcon`, `semanticLabel`

#### `ThemeText`
Drop-in replacement for `Text` that auto-resolves color based on theme brightness. Use instead of `Text(style: TextStyle(color: AppColors.textPrimary))`.
```dart
// Before: invisible in dark mode
Text('Hello', style: TextStyle(color: AppColors.textPrimary))
// After: visible in both modes, respects text scaling
ThemeText('Hello', style: TextStyle(fontSize: DesignTokens.fontLg))
```

#### `PremiumCard`
The main surface card. Props: `isGlass`, `padding`, `borderRadius`, `child`, `margin`
- `isGlass: true` → wraps in `ClipRRect` + `BackdropFilter`
- `glassGroup()` → shared `BackdropFilter` for performance (multiple cards)

#### `PremiumBackground`
Animated gradient background with radial orbs. Adapts between Glass and Clay variants. Use as the `body` wrapper for tab-style data screens.

#### `ScreenHeader`
Glassmorphic AppBar replacement with optional back button and right actions. Used across all tab-style screens.

#### `PremiumEmptyState`
Consistent empty/error state display: icon in rounded container (80px), title, optional subtitle, action button.

---

### Layout Patterns

#### Tab-Style Data Screen Pattern
```dart
Scaffold(
  appBar: ScreenHeader(title: 'Screen Title'),
  body: PremiumBackground(
    child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : hasData
        ? RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DesignTokens.spaceLg),
              child: Column(children: [...cards...]),
            ),
          )
        : PremiumEmptyState(icon: ..., title: 'No data yet'),
  ),
)
```

#### Auth Screen Pattern
```dart
Scaffold(
  body: Container(
    decoration: BoxDecoration(gradient: LinearGradient(...)),
    child: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: StaggeredFadeSlide(
            children: [
              // Logo orb
              Container(...baby icon...),
              // Glass card with form
              ClipRRect(
                borderRadius: DesignTokens.radius2xl,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: glassBlurMd, sigmaY: glassBlurMd),
                  child: Container(padding: space2xl, child: Column(...)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
)
```

#### Data Entry Bottom Sheet Pattern
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (ctx) => StatefulBuilder(
    builder: (ctx, setSheetState) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        left: DesignTokens.spaceLg,
        right: DesignTokens.spaceLg,
        top: DesignTokens.spaceLg,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Title
        Text('Title', style: Theme.of(ctx).textTheme.titleLarge),
        SizedBox(height: spaceMd),
        // Form fields...
        SizedBox(height: spaceLg),
        ThemeButton(label: 'Save', fullWidth: true, onPressed: _save),
      ]),
    ),
  ),
);
```

---

## Animation Guidelines

### Duration Tokens
Always reference `DesignTokens.duration*` — never hardcode `Duration(milliseconds: X)`:
- `durationInstant` (100ms) — micro-interactions (checkbox, toggle)
- `durationFast` (200ms) — button press feedback, hover states
- `durationNormal` (300ms) — standard transitions
- `durationPage` (400ms) — page transitions, entrance animations
- `durationSlow` (500ms) — complex reveals
- `durationXslow` (800ms) — celebration animations

### Page Transitions
All GoRouter routes use a shared `_pageTransition()` builder:
- Slide up (5% offset) + fade
- Uses `DesignTokens.curvePremium` (slide) + `curveDecelerate` (fade)
- Duration: `DesignTokens.durationPage` (400ms)

### Staggered Entry
For list items appearing on screen:
- Use `StaggeredFadeSlide` with `staggerDelayMs: DesignTokens.staggerDelayMs` (80ms)
- Use `ScrollStagger` for lazy-loading items as they scroll into view
- Both respect `MediaQuery.of(context).disableAnimations` for reduced motion

### Tap Feedback
Use `ScalePress` for interactive elements — not raw `GestureDetector(onTap:)`:
- 0.96x scale on press down
- Magnetic offset for depth
- `DesignTokens.durationFast` (200ms) press/release
- Optional haptic feedback

### Performance
- Wrap `AnimatedBuilder` children with `RepaintBoundary` when the subtree is complex
- Use `PremiumCard.glassGroup()` to share one `BackdropFilter` across multiple cards
- Use `const` constructors everywhere possible

---

## Color Resolution

### Correct Pattern (use throughout)
```dart
// In build methods:
final isDark = Theme.of(context).brightness == Brightness.dark;
final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
final cardBg = isDark ? AppColors.glassDark : AppColors.glassWhite;
```

### Preferred Pattern (ThemeText)
```dart
// Auto-resolves color + respects text scaling:
ThemeText('Hello', style: TextStyle(fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700))
```

---

## Accessibility Checklist

- [x] All tappable elements have `Semantics(label: '...', button: true)` or `semanticLabel`
- [x] Decorative icons wrapped in `ExcludeSemantics`
- [x] Images have `semanticLabel` or `Semantics(label: 'Photo from baby album')`
- [x] Bottom nav tabs announce as `'Dashboard tab'`, `'Milestones tab'`, etc.
- [x] Form errors linked to inputs via `Semantics(error: true)`
- [x] Text respects system font scaling via `ThemeText` (WCAG 1.4.4)
- [x] WCAG AA color contrast: textPrimary 4.5:1+, textSecondary 7.3:1+
- [x] Medical disclaimer gate has full semantic labeling
- [x] Reduced motion respected (`MediaQuery.of(context).disableAnimations`)

---

## Spacing Scale
```
space2xs = 2    spaceXs = 4    spaceSm = 8
spaceMd  = 12   spaceLg = 16   spaceXl  = 20
space2xl = 24   space3xl = 32  space4xl = 40
space5xl = 48   space6xl = 64  space7xl = 80
space8xl = 96
```

## Border Radius Scale
```
radiusXs  = 4   radiusSm  = 8   radiusMd  = 12
radiusLg  = 16  radiusXl  = 20  radius2xl = 24
radius3xl = 32  radiusFull = 999
```

## Opacity Scale
```
opacityGhost    = 0.06  (barely visible)
opacitySubtle   = 0.15  (decorative elements)
opacityDim      = 0.30  (disabled/dimmed text)
opacityDisabled = 0.40  (disabled buttons)
opacityGlassBase    = 0.80  (glass surface base)
opacityGlassElevated = 0.90 (glass surface elevated)
```
