import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';

/// Glassmorphism design tokens exposed as a [ThemeExtension].
///
/// This makes glass-specific properties (glassDark, glassLight, shadows,
/// borders) theme-aware so widgets can reference `Theme.of(context).extension<GlassTokens>()`
/// instead of hardcoding `AppColors.*`. Clay theme provides its own values.
@immutable
class GlassTokens extends ThemeExtension<GlassTokens> {
  final Color background;
  final Color surface;
  final Color border;
  final Color borderLight;
  final Color shadow;
  final Color accent;

  const GlassTokens({
    required this.background,
    required this.surface,
    required this.border,
    required this.borderLight,
    required this.shadow,
    required this.accent,
  });

  /// Default Glass theme tokens.
  factory GlassTokens.light() => const GlassTokens(
        background: AppColors.glassDark,
        surface: AppColors.glassWhite,
        border: AppColors.glassBorder,
        borderLight: AppColors.glassBorderLight,
        shadow: AppColors.glassShadow,
        accent: AppColors.accent,
      );

  /// Dark-mode Glass theme tokens.
  factory GlassTokens.dark() => const GlassTokens(
        background: AppColors.glassDark,
        surface: AppColors.darkSurface,
        border: AppColors.glassDarkBorder,
        borderLight: AppColors.glassDarkBorderLight,
        shadow: AppColors.glassDarkShadow,
        accent: AppColors.accent,
      );

  /// Clay theme tokens — softer, warmer equivalents.
  factory GlassTokens.clay() => const GlassTokens(
        background: Color(0xFFF5EDE4),
        surface: Colors.white,
        border: Color(0xFFD4C5B2),
        borderLight: Color(0xFFE8DCD0),
        shadow: Color(0xFFB8A088),
        accent: Color(0xFFA45D35),
      );

  @override
  GlassTokens copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? borderLight,
    Color? shadow,
    Color? accent,
  }) {
    return GlassTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      shadow: shadow ?? this.shadow,
      accent: accent ?? this.accent,
    );
  }

  @override
  GlassTokens lerp(GlassTokens? other, double t) {
    if (other is! GlassTokens) return this;
    return GlassTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}
