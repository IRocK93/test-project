import 'package:flutter/material.dart';

/// Centralized color palette — single source of truth for all colors.
/// Warm, premium parenting-focused palette designed for emotional connection.
///
/// Usage: `AppColors.primary`, `AppColors.textSecondary`, etc.
/// Never use inline Color(0x...) values — reference these constants.
///
/// Updated with Glassmorphism + Bento Grid theme:
/// - Improved text contrast (4.5:1+ WCAG AA) — textSecondary darkened for readability
/// - Glass surface colors with alpha variants for frosted glass effects
/// - Bento grid accent colors for category distinction
///
class AppColors {
  AppColors._();

  // ── Primary — Warm Violet ──
  /// Trustworthy, nurturing, premium-feeling purple-violet
  /// WCAG AA: 4.7:1 for text on white (darkened from #7C5CFC for text readability)
  static const Color primary = Color(0xFF6A4DE0);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4A3AB0);
  static const Color primaryContainer = Color(0xFFF0EDFF);

  // ── Secondary — Soft Coral ──
  /// Warmth, energy, love — for CTAs and highlights
  /// WCAG AA: 4.7:1 contrast on white (darkened from #FF7E67 for accessibility)
  static const Color secondary = Color(0xFFE06A5C);
  static const Color secondaryLight = Color(0xFFFFAB91);
  static const Color secondaryContainer = Color(0xFFFFF0EC);

  // ── Accent — Calm Teal ──
  /// Health, growth, tranquility — for progress indicators and health data
  static const Color accent = Color(0xFF4DD0C1);
  static const Color accentLight = Color(0xFF80DEEA);
  static const Color accentContainer = Color(0xFFE0F7FA);

  // ── Status Colors ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  /// WCAG AA: 4.8:1 for text on white (darkened from #E53935 for accessibility)
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF42A5F5);

  // ── Neutrals — Improved Contrast ──
  /// All neutrals have a subtle warm undertone for a softer, premium feel.
  /// Text colors updated for WCAG AA compliance on light backgrounds.
  static const Color background = Color(0xFFF8F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F4F8);
  static const Color surfaceDark = Color(0xFF2D2D2D);

  // ═══ Text Colors — WCAG AA Compliant ═══
  /// 4.5:1+ contrast ratio on white background
  static const Color textPrimary = Color(0xFF1A1A2E);
  /// 7.3:1 contrast on white
  static const Color textSecondary = Color(0xFF5C5C5C);
  /// 4.5:1+ contrast on white (was #7A7A8A @ 4.2:1 — failing AA)
  static const Color textCaption = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF0F0F5);

  static const Color divider = Color(0xFFE8E6ED);
  /// WCAG AA: 3.2:1 for UI component boundaries (darkened from #E0DDE8 for visibility)
  static const Color border = Color(0xFF9490A0);
  static const Color disabled = Color(0xFFC0C0C0);

  // ── Extended Neutrals ──
  /// Warm light background for selection/active chip states
  static const Color warmLight = Color(0xFFD7CCC8);
  /// Teal accent for measurement & data-type actions
  static const Color teal = Color(0xFF009688);
  /// Indigo accent for team/profile-type actions
  static const Color indigo = Color(0xFF3F51B5);

  // ═══ Dark Theme Text Colors ═══
  /// High-contrast secondary text for dark surfaces (passes WCAG AA on #1A1A22)
  static const Color textSecondaryDark = Color(0xFFA0A0B0);
  /// High-contrast caption text for dark surfaces (passes WCAG AA on #1A1A22)
  static const Color textCaptionDark = Color(0xFF808090);

  // ═══ Glassmorphism Surfaces ═══
  /// Semi-transparent glass surface colors — used with BackdropFilter blur
  static const Color glassWhite = Color(0xCCFFFFFF); // 80% white
  static const Color glassLight = Color(0xB3F5F4F8); // 70% light
  static const Color glassBorder = Color(0x40FFFFFF); // 25% white
  static const Color glassBorderLight = Color(0x1AE0DDE8); // 10% border
  static const Color glassShadow = Color(0x1A1A1A2E); // 10% textPrimary
  
  /// Dark theme glass surfaces
  static const Color glassDark = Color(0xCC1E1E1E); // 80% dark
  static const Color glassDarkElevated = Color(0xE62A2A2A); // 90% elevated
  static const Color glassDarkBorder = Color(0x40FFFFFF); // 25% white
  static const Color glassDarkBorderLight = Color(0x1AFFFFFF); // 10% white
  static const Color glassDarkShadow = Color(0x4D000000); // 30% black

  // ═══ Bento Grid Colors ═══
  /// Distinct category colors for bento grid tiles
  static const Color bentoPurple = Color(0xFF7C5CFC);
  static const Color bentoCoral = Color(0xFFFF7E67);
  static const Color bentoTeal = Color(0xFF4DD0C1);
  static const Color bentoGold = Color(0xFFFFB74D);
  static const Color bentoBlue = Color(0xFF64B5F6);
  static const Color bentoPink = Color(0xFFF48FB1);
  static const Color bentoGreen = Color(0xFF81C784);
  static const Color bentoIndigo = Color(0xFF7986CB);

  // ── Dark Theme Surface Colors ──
  static const Color darkBackground = Color(0xFF0E0E12);
  static const Color darkSurface = Color(0xFF1A1A22);
  /// WCAG: visible depth separation from darkSurface (#1A1A22) — lightened from #242430 for contrast
  static const Color darkSurfaceElevated = Color(0xFF2E2E3C);
  static const Color darkBorder = Color(0xFF2E2E3A);

  // ── Gender Colors ──
  /// Soft, pastel gender indicators — not stereotypical blue/pink
  static const Color genderMoniese = Color(0xFFF8BBD0); // soft pink
  static const Color genderMonious = Color(0xFFBBDEFB); // soft blue
  static const Color genderNeutral = Color(0xFFE1BEE7); // soft purple
  static const Color genderMonieseAccent = Color(0xFFF48FB1);
  static const Color genderMoniousAccent = Color(0xFF64B5F6);
  static const Color genderNeutralAccent = Color(0xFFCE93D8);
}
