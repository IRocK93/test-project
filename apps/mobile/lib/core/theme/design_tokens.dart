import 'package:flutter/material.dart';
import 'glass_tokens.dart';

/// Central design tokens for consistent spacing, sizing, and visual rhythm.
///
/// All screens reference these constants instead of hardcoded values.
/// This ensures visual consistency and makes global spacing adjustments trivial.
///
/// Updated with Glassmorphism + Bento Grid design tokens:
/// - Bento grid breakpoints and aspect ratios
/// - Glass blur intensities
/// - Expanded spacing for bento layouts
///
class DesignTokens {
  DesignTokens._();

  // ═══════════════════════════════════════
  //  SPACING SCALE (4px base unit)
  // ═══════════════════════════════════════
  static const double space2xs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double space2xl = 24;
  static const double space3xl = 32;
  static const double space4xl = 40;
  static const double space5xl = 48;
  static const double space6xl = 64;
  static const double space7xl = 80;
  static const double space8xl = 96;

  // ═══════════════════════════════════════
  //  BORDER RADIUS
  // ═══════════════════════════════════════
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radius3xl = 32;
  static const double radiusFull = 999;

  // ═══════════════════════════════════════
  //  TYPOGRAPHY SCALE
  // ═══════════════════════════════════════
  static const double fontXs = 10;
  static const double font2xs = 11;
  static const double fontSm = 12;
  static const double fontSm2 = 13;
  static const double fontMd = 14;
  static const double fontMd2 = 15;
  static const double fontLg = 16;
  static const double fontLg2 = 18;
  static const double fontXl = 20;
  static const double fontXl2 = 22;
  static const double font2xl = 24;
  static const double font3xl = 32;
  static const double font4xl = 48;
  static const double font5xl = 64;

  // ═══════════════════════════════════════
  //  OPACITY SCALE
  // ═══════════════════════════════════════
  static const double opacityDisabled = 0.40;
  static const double opacityDim = 0.30;
  static const double opacitySubtle = 0.15;
  static const double opacityGhost = 0.06;
  static const double opacityGlassBase = 0.80;
  static const double opacityGlassElevated = 0.90;

  // ═══════════════════════════════════════
  //  GLASSMORPHISM TOKENS
  // ═══════════════════════════════════════
  /// Standard frosted glass blur intensity (in sigma pixels)
  static const double glassBlurLight = 8.0;
  /// Medium frosted glass blur
  static const double glassBlurMd = 15.0;
  /// Heavy frosted glass blur
  static const double glassBlurHeavy = 24.0;
  /// Glass border width
  static const double glassBorderWidth = 0.5;
  /// Glass border width (elevated)
  static const double glassBorderWidthElevated = 1.0;
  /// Glass card shadow blur
  static const double glassShadowBlur = 20.0;
  /// Glass card shadow offset
  static const double glassShadowOffset = 8.0;

  // ═══════════════════════════════════════
  //  BENTO GRID TOKENS
  // ═══════════════════════════════════════
  /// Bento grid gap
  static const double bentoGap = 12.0;
  /// Bento grid outer padding
  static const double bentoPadding = 16.0;
  /// Aspect ratio for a 2-column bento tile (width:height)
  static const double bentoDoubleWide = 2.0 / 1.0;
  /// Aspect ratio for a tall bento tile
  static const double bentoTall = 1.0 / 1.8;
  /// Aspect ratio for a square bento tile
  static const double bentoSquare = 1.0;
  /// Aspect ratio for a hero bento tile
  static const double bentoHero = 2.0 / 1.2;

  // ═══════════════════════════════════════
  //  DURATIONS
  // ═══════════════════════════════════════
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationPage = Duration(milliseconds: 400);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationXslow = Duration(milliseconds: 800);

  // ═══════════════════════════════════════
  //  ENTRANCE ANIMATIONS
  // ═══════════════════════════════════════
  /// Standard duration for entrance animations (fade, scale, slide).
  /// Maps to [durationPage] for consistency.
  static const Duration durationEntrance = durationPage;

  /// Stagger delay per item in a list/grid for staggered entrance.
  static const int staggerDelayMs = 80;

  /// Scale start point for FadeScaleIn (0.5 = half size on entry).
  static const double fadeScaleInBegin = 0.5;

  /// Standard slide-up offset for StaggeredFadeSlide and ScrollStagger (in px).
  static const double slideUpOffset = 20.0;

  // ═══════════════════════════════════════
  //  CURVES
  // ═══════════════════════════════════════
  /// Awwwards-tier spring deceleration — simulates real-world mass
  static const Curve curvePremium = Cubic(0.32, 0.72, 0.0, 1.0);
  /// Spring-like deceleration — feels natural and premium
  static const Curve curveDecelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  /// Sharp acceleration then soft settle — for entrance animations
  static const Curve curveOvershoot = Cubic(0.34, 1.56, 0.64, 1.0);
  /// Smooth standard easing
  static const Curve curveStandard = Cubic(0.4, 0.0, 0.2, 1.0);
  /// Standard entrance curve — replaces hardcoded Curves.easeOutCubic
  static const Curve curveEntrance = Curves.easeOutCubic;
  /// Spring-back curve — replaces hardcoded Curves.easeOutBack for bounce effects
  static const Curve curveBounce = Curves.easeOutBack;

  // ═══════════════════════════════════════
  //  SPLASH ANIMATION TOKENS
  // ═══════════════════════════════════════
  /// Total duration for splash screen entrance animation
  static const Duration splashDuration = Duration(milliseconds: 1800);
  /// Splash logo scale: end of scale-up interval (fraction of total)
  static const double splashLogoIntervalEnd = 0.6;
  /// Splash logo: end of fade-in interval
  static const double splashFadeIntervalEnd = 0.4;
  /// Splash tagline: start of fade-in interval
  static const double splashTaglineIntervalStart = 0.4;
  /// Splash tagline: end of fade-in interval
  static const double splashTaglineIntervalEnd = 0.8;
  /// Splash logo scale begin value
  static const double splashLogoScaleBegin = 0.6;
  /// Splash auth check delay (seconds)
  static const int splashAuthDelaySec = 3;

  // ═══════════════════════════════════════
  //  ELEVATION SHADOWS
  // ═══════════════════════════════════════
  static List<BoxShadow> shadowSm(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowLg(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowXl(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Glass-specific shadow with colored tint — used for frosted glass surfaces
  static List<BoxShadow> glassShadow(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.08),
      blurRadius: glassShadowBlur,
      offset: const Offset(0, glassShadowOffset),
    ),
    BoxShadow(
      color: tint.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ═══════════════════════════════════════
  //  ICON SIZES
  // ═══════════════════════════════════════
  static const double iconXs = 14;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // ═══════════════════════════════════════
  //  AVATAR SIZES
  // ═══════════════════════════════════════
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;

  // ═══════════════════════════════════════
  //  CARD DIMENSIONS
  // ═══════════════════════════════════════
  static const double cardMinHeight = 80;
  static const double cardDefaultPadding = 16;
  static const double cardCompactPadding = 12;

  // ═══════════════════════════════════════
  //  PAGE TRANSITION TOKENS
  // ═══════════════════════════════════════
  /// Fraction of the page width the incoming page slides from (8% = subtle slide).
  static const double pageTransitionSlideFraction = 0.08;

  /// Default page-transition builder for [AnimatedSwitcher]:
  /// slides in from the right (pageTransitionSlideFraction * width) while cross-fading.
  /// Note: the curve is handled by AnimatedSwitcher's `switchInCurve`/`switchOutCurve`,
  /// so we pass the raw animation directly — no extra CurvedAnimation needed.
  static Widget Function(Widget child, Animation<double> animation)
      get pageTransitionBuilder =>
          (Widget child, Animation<double> animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(pageTransitionSlideFraction, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
}

/// Convenience extensions on [BuildContext] for quick theme access.
/// These avoid the boilerplate of repeated `Theme.of(context).colorScheme`
/// and `Theme.of(context).extension<GlassTokens>()` across widget builds.
extension QuickThemeAccess on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  GlassTokens get glass => Theme.of(this).extension<GlassTokens>()!;
  Color get dividerColor => Theme.of(this).dividerColor;
}
