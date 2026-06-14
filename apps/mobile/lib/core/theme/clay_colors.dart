import 'package:flutter/material.dart';

/// Claymorphism color palette — lighter, warmer, more organic than glassmorphism.
///
/// Claymorphism is characterized by:
/// - Soft, warm neutral backgrounds (cream, off-white, warm beige)
/// - Rounded, almost "play-doh" aesthetic — generous border radius
/// - Dual shadows: inner highlight (top-left) + outer shadow (bottom-right)
/// - Lower contrast, gentler color transitions
/// - Warm terracotta / earthy primaries instead of cool purples
///
/// This palette is designed as a drop-in replacement for [AppColors] —
/// same token names, different values.
class ClayColors {
  ClayColors._();

  // ── Primary — Warm Terracotta ──
  /// Earthy, nurturing, warm clay-brown
  static const Color primary = Color(0xFFC17F59);
  static const Color primaryLight = Color(0xFFD9A882);
  static const Color primaryDark = Color(0xFF8B5E3C);
  static const Color primaryContainer = Color(0xFFF5EDE4);

  // ── Secondary — Soft Sage Green ──
  /// Calm, growth-oriented, natural green
  static const Color secondary = Color(0xFF8FA88A);
  static const Color secondaryLight = Color(0xFFB2C5AE);
  static const Color secondaryContainer = Color(0xFFF0F4EE);

  // ── Accent — Warm Sand ──
  /// Sunshine warmth, gentle energy
  static const Color accent = Color(0xFFD4A96A);
  static const Color accentLight = Color(0xFFE8C98F);
  static const Color accentContainer = Color(0xFFFBF5EA);

  // ── Status Colors ──
  static const Color success = Color(0xFF7CAB7C);
  static const Color warning = Color(0xFFD4A060);
  static const Color error = Color(0xFFC1756B);
  static const Color errorContainer = Color(0xFFFDF2F0);
  static const Color info = Color(0xFF8BA9B8);

  // ── Neutrals — Warm Cream ──
  /// Clay surfaces are light, warm, and slightly tinted — never sterile white.
  static const Color background = Color(0xFFF3EFE9);
  static const Color surface = Color(0xFFFDFBFA);
  static const Color surfaceLight = Color(0xFFF8F5F0);
  static const Color surfaceDark = Color(0xFF3D3832);

  // ── Text — Brown-Toned ──
  /// Dark brown instead of near-black — gentler on eyes, matches clay warmth.
  static const Color textPrimary = Color(0xFF2E2925);
  /// Warm grey for secondary text.
  static const Color textSecondary = Color(0xFF6B635C);
  /// Muted warm grey for captions.
  static const Color textCaption = Color(0xFF6E6660);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF0EDE8);

  static const Color divider = Color(0xFFE8E3DB);
  static const Color border = Color(0xFFDDD7CF);
  static const Color disabled = Color(0xFFD0CBC3);

  // ── Extended Neutrals ──
  static const Color textMuted = Color(0xFF6E6660);
  static const Color warmLight = Color(0xFFF2ECE3);
  static const Color teal = Color(0xFF7BA89E);
  static const Color indigo = Color(0xFF8B8AAD);

  // ── Dark Theme Text ──
  static const Color textSecondaryDark = Color(0xFFB0A99E);
  static const Color textCaptionDark = Color(0xFF908A82);

  // ── Claymorphism Surfaces ──
  /// Opaque light cream surface for clay cards
  static const Color claySurface = Color(0xFFFDFBFA);
  /// Slightly darker clay for elevated surfaces
  static const Color clayElevated = Color(0xFFF6F2EA);
  /// Warm border for clay cards
  static const Color clayBorder = Color(0xFFE8E3DB);

  // ── Claymorphism Dual Shadow ──
  /// Outer shadow (bottom-right) — deeper, warmer
  static const Color clayShadowOuter = Color(0x338B7355);
  /// Inner highlight (top-left) — lighter, creamier
  static const Color clayShadowInner = Color(0x66FFFFFF);

  /// Standard clay card shadow — dual-layer: inset highlight + outset shadow.
  static List<BoxShadow> clayCardShadow({double blurOuter = 16, double blurInner = 8}) => const [
    // Outer shadow (bottom-right) — depth
    BoxShadow(
      color: clayShadowOuter,
      blurRadius: 16,
      offset: Offset(6, 6),
    ),
    // Inner highlight (top-left) — clay "pushed in" feel
    BoxShadow(
      color: clayShadowInner,
      blurRadius: 8,
      offset: Offset(-4, -4),
    ),
    // Subtle base separation
    BoxShadow(
      color: Color(0x1A8B7355),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Subtle clay shadow for smaller elements (buttons, chips)
  static List<BoxShadow> clayShadowSm() => const [
    BoxShadow(
      color: clayShadowOuter,
      blurRadius: 8,
      offset: Offset(3, 3),
    ),
    BoxShadow(
      color: clayShadowInner,
      blurRadius: 4,
      offset: Offset(-2, -2),
    ),
  ];

  // ── Dark Theme Clay Surfaces ──
  static const Color clayDarkSurface = Color(0xFF2E2A26);
  static const Color clayDarkElevated = Color(0xFF38342F);
  static const Color clayDarkBorder = Color(0xFF4A453E);
  static const Color clayDarkShadowOuter = Color(0x4D000000);
  static const Color clayDarkShadowInner = Color(0x1AFFFFFF);

  static List<BoxShadow> clayDarkCardShadow({double blurOuter = 16, double blurInner = 8}) => const [
    BoxShadow(
      color: clayDarkShadowOuter,
      blurRadius: 16,
      offset: Offset(6, 6),
    ),
    BoxShadow(
      color: clayDarkShadowInner,
      blurRadius: 8,
      offset: Offset(-4, -4),
    ),
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> clayDarkShadowSm() => const [
    BoxShadow(
      color: clayDarkShadowOuter,
      blurRadius: 8,
      offset: Offset(3, 3),
    ),
    BoxShadow(
      color: clayDarkShadowInner,
      blurRadius: 4,
      offset: Offset(-2, -2),
    ),
  ];

  // ── Dark Theme Surface Colors ──
  static const Color darkBackground = Color(0xFF1C1815);
  static const Color darkSurface = Color(0xFF25211E);
  static const Color darkSurfaceElevated = Color(0xFF302C28);
  static const Color darkBorder = Color(0xFF3E3A35);

  // ── Gender Colors — Soft Pastel Clay ──
  static const Color genderMoniese = Color(0xFFF0D8DF);
  static const Color genderMonious = Color(0xFFD8E4F0);
  static const Color genderNeutral = Color(0xFFE8D8F0);
  static const Color genderMonieseAccent = Color(0xFFE0A0B0);
  static const Color genderMoniousAccent = Color(0xFFA0B8D8);
  static const Color genderNeutralAccent = Color(0xFFC8A8D8);
}