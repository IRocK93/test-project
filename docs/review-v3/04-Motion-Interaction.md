# Motion & Interaction Audit Report

## Grade: B+

## Summary
BabyMon demonstrates strong animation fundamentals with a centralized design-token system, thoughtful curve selection (Awwwards-tier cubic-bezier), and exemplary reduced-motion handling in select widgets like `LevelUpCelebration`. However, the motion system falls short of an A-grade in three areas: inconsistent reduced-motion affordances across widgets, a missing haptic integration in `ScalePress`, and heavy `BackdropFilter` usage on static scrolling surfaces that creates a persistent GPU tax with no visual payoff during interaction. The tab switcher uses a plain `IndexedStack` with no cross-fade -- a missed opportunity given the premium elsewhere. The animation motivation is largely sound, though the `PremiumBackground` radial mesh orbs are a purely ornamental effect that runs a 12-second looping `AnimationController` in every scaffold.

## Findings

| # | Severity | File:Line | Finding | Fix |
|---|----------|-----------|---------|-----|
| 1 | HIGH | `splash_screen.dart:123-128` | Splash screen applies `BackdropFilter` with `glassBlurHeavy` (sigma 24) across the entire screen while a scale+elastic animation runs. This is the most expensive GPU operation in the app and runs on the very first frame. | Remove the splash `BackdropFilter` entirely -- the gradient background and glass orbs already provide depth. The blur is invisible behind the center-anchored content during a 1.8s animation. |
| 2 | HIGH | `app_router.dart:31-32` | Page transition slide offset is `Offset(0, 0.05)` -- a mere 5% vertical shift. At 400ms on `curvePremium`, this is imperceptible to the user. The fade does all the work. | Increase the slide to 8-12% (`Offset(0, 0.08)`), or replace with a more intentional direction (e.g., forward-navigation slides right-to-left, back slides left-to-right). |
| 3 | HIGH | `animated_entry.dart:304-316` | `ScalePress.onTapUp` calls `widget.onTap?.call()` during `_controller.reverse()` (the reverse animation), meaning the navigation action fires mid-animation. On slower devices, the next route may push before the press-release animation completes, causing a visual glitch. | Delay the `onTap` callback until `reverse()` completes: `_controller.reverse().then((_) => widget.onTap?.call());` |
| 4 | MEDIUM | `animated_entry.dart:304-316` | `ScalePress` provides magnetic offset and spring physics but has zero haptic integration. Every tappable `ScalePress` interaction throughout the app is silent. | Add `HapticFeedback.lightImpact()` in `_onTapDown` and `HapticFeedback.selectionClick()` in `_onTapUp` (configurable). The `InfoFab` already does this manually; unify it. |
| 5 | MEDIUM | `main_screen.dart:825-828` | Tab switching uses a plain `IndexedStack` with no transition animation. The only animation is on the nav bar icon pill, not on the screen content itself. | Wrap the `IndexedStack` child in an `AnimatedSwitcher` with `FadeTransition` + scale, or use a `PageView` with controlled physics for swipe-back gesture. |
| 6 | MEDIUM | `main_screen.dart:839-843` | Bottom navigation bar applies `BackdropFilter` with `glassBlurHeavy` (sigma 24) in every frame, for the entire app lifetime, regardless of what content scrolls behind it. This is a constant ~2-4ms GPU cost per frame on mid-range devices. | Drop to `glassBlurLight` (sigma 8) and ideally disable the blur when the nav is over a solid background. The pill already has `alpha: 0.85` background -- the heavy blur adds negligible visual value. |
| 7 | MEDIUM | `premium_background.dart:30-37` | `PremiumBackground` runs a 12-second looping `AnimationController` with 4 animated radial orbs repositioning every frame. This runs in every screen using it (dashboard, settings, etc.), even when the user is idle. | Add `didChangeAppLifecycleState` to pause the controller when the app is backgrounded. Consider `RepaintBoundary` around each orb to isolate repaint costs. |
| 8 | MEDIUM | `info_fab.dart:136-146` | `InfoFab` animation (`_radialMenuOverlay`) has no reduced-motion check. The full 800ms fan-out with `easeOutBack` overshoot plays even when system animations are disabled. | Check `MediaQuery.of(context).disableAnimations` and snap the overlay and actions to their final positions instantly. |
| 9 | LOW | `animated_entry.dart:59-67` | `StaggeredFadeSlide` creates an `AnimationController` per widget instance. In a list of 50+ items, this means 50 concurrent `AnimationController` + `Timer` pairs. | Consider batching stagger into a single `AnimationController` with `Interval` curves, or lazy-creating controllers only when the item is laid out. |
| 10 | LOW | All feature screens using `RefreshIndicator` | Refresh indicator is the stock Material `RefreshIndicator` with no custom styling, no branding, and no progress animation beyond the default circular spinner. | Create a custom `BabyMonRefreshIndicator` that uses the app's `curvePremium`, branded colors, or a playful icon. |
| 11 | LOW | `splash_screen.dart:35` | `Curves.elasticOut` is hardcoded instead of using a design token. All other curves route through `DesignTokens` except this one. | Define `DesignTokens.curveElastic = Curves.elasticOut` and use it consistently. |

## Top 5 Issues

1. **Splash screen `BackdropFilter` with heavy blur during animation** -- The full-screen `glassBlurHeavy` on the splash screen is the single most expensive GPU operation at app launch. Remove it; the gradient and decorative orbs already create visual depth.
2. **`ScalePress` fires `onTap` mid-animation** -- The `onTapUp` handler calls `widget.onTap?.call()` immediately while `_controller.reverse()` is still running. This means the next route pushes before the press-release settles, causing visible jank on route transitions.
3. **No haptic feedback in `ScalePress`** -- Despite being the primary tap-feedback wrapper, `ScalePress` provides visual-only feedback. Every other interactive widget independently sprinkles `HapticFeedback` calls. This is an inconsistent, scattered pattern.
4. **Missing reduced-motion in 5+ animation widgets** -- `MorphingHamburger`, `ScalePress`, `InfoFab`, page transitions, and `PremiumBackground` do not respect `MediaQuery.of(context).disableAnimations`. This is a WCAG 2.1 violation (SC 2.3.3).
5. **Persistent GPU tax from `BackdropFilter` on non-scrolling surfaces** -- The bottom nav bar (`glassBlurHeavy`, sigma 24) and splash screen background blur run continuously regardless of content behind them. The nav bar sits over a solid body with `alpha: 0.85` -- the blur is effectively invisible. Wastes ~2-4ms per frame.

## Best 3 Animations

1. **`LevelUpCelebration`** (`level_up_celebration.dart`) -- Exemplary, complete animation package. Sequence-timed reveals (badge at 0.15, particles at 0.30, phase milestone at 0.45), per-element reduced-motion fallbacks, particle system with seeded RNG, haptic on entry, auto-dismiss at 4s. This is how every celebration animation should be built.

2. **`InfoFab` radial menu** (`info_fab.dart`) -- Well-crafted expansion with staggered fan-out using `easeOutBack` spring physics, pulse guide ring at t=0.2 with haptic, main FAB rotation for icon swap, scrim backdrop with tap-to-dismiss, per-action `mediumImpact` haptic. The only missing piece is reduced-motion support.

3. **`MorphingHamburger`** (`morphing_hamburger.dart`) -- Clean morph from three lines to X using `curvePremium` on staggered intervals. Rotation+translation decomposition on individual lines creates natural pivot feel. Includes semantics labels and `RepaintBoundary` via `CustomPaint`.

## Reduced Motion Assessment

**Score: 5/10 -- Inconsistent and Incomplete**

Widgets that handle reduced motion: `StaggeredFadeSlide`, `ScrollStagger`, `FadeScaleIn`, `SplashScreen`, `LevelUpCelebration` (exemplary).

Widgets that DO NOT: `MorphingHamburger`, `ScalePress`, `InfoFab` + `_RadialMenuOverlay`, page transitions (`app_router.dart`), `PremiumBackground`, every `AnimatedSwitcher` in the app.

The `LevelUpCelebration` is the benchmark: it snap-sets scale to 1.0, opacity to 1.0, and skips particles when reduced motion is active.

## Motion Motivation Audit

10 of 13 animations have clear UX motivation. The 3 decorative-only animations (PremiumBackground orbs, splash BackdropFilter, nav bar heavy blur) are all GPU-expensive effects that should be downgraded or removed. The decorative-to-functional ratio (3/13 = 23%) is acceptable but trending high for a parenting utility app where battery life and thermal headroom matter.
