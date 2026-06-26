import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/theme/clay_colors.dart';

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
            background: AppColors.glassWhite,
            surface: AppColors.glassWhite,
        border: AppColors.glassBorder,
        borderLight: AppColors.glassBorderLight,
        shadow: AppColors.glassShadow,
        accent: AppColors.accent,
      );

      /// Dark-mode Glass theme tokens.
      factory GlassTokens.dark() => const GlassTokens(
            background: AppColors.glassDarkElevated,
            surface: AppColors.darkSurface,
        border: AppColors.glassDarkBorder,
        borderLight: AppColors.glassDarkBorderLight,
        shadow: AppColors.glassDarkShadow,
        accent: AppColors.accent,
      );

  /// Clay theme tokens — softer, warmer equivalents.
  factory GlassTokens.clay() => const GlassTokens(
        background: ClayColors.background,
        surface: ClayColors.surface,
        border: ClayColors.border,
        borderLight: ClayColors.divider,
        shadow: ClayColors.primaryDark,
        accent: ClayColors.accent,
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
