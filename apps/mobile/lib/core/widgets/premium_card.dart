import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/glass_tokens.dart';
import 'animated_entry.dart';

/// A premium card widget with full glassmorphism support.
///
/// Features:
/// - Frosted glass via `BackdropFilter` + `ImageFilter.blur` when `isGlass` is true
/// - Bento grid variants (`bentoVariant`)
/// - Subtle elevation, tinted shadows, and gradient overlays
/// - Smooth press animation via `ScalePress`
///
/// Use this instead of raw Material `Card` throughout the app.
///
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Gradient? gradient;
  final bool isGlass;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? customShadow;

  /// Bento grid variant — adjusts padding and visual weight.
  /// - `standard`: default card
  /// - `hero`: larger visual weight, for featured content
  /// - `compact`: tighter padding for dense bento grids
  /// - `tall`: emphasis on vertical space
  final BentoVariant bentoVariant;

  /// Optional glass blur intensity override. Defaults to [DesignTokens.glassBlurMd].
  final double? glassBlurSigma;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    this.gradient,
    this.isGlass = false,
    this.bentoVariant = BentoVariant.standard,
    this.glassBlurSigma,
    this.height,
    this.width,
    this.onTap,
    this.border,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final glass = Theme.of(context).extension<GlassTokens>()!;

    final effectiveColor = backgroundColor ??
        (isGlass
            ? glass.background
            : colorScheme.surface);

    final effectiveRadius = borderRadius ?? DesignTokens.radiusLg;
    final effectivePadding = padding ??
        EdgeInsets.all(bentoVariant == BentoVariant.compact
            ? DesignTokens.spaceMd
            : bentoVariant == BentoVariant.hero
                ? DesignTokens.spaceXl
                : DesignTokens.cardDefaultPadding);

    final effectiveBorder = border ??
        (isGlass
            ? Border.all(
                color: glass.border.withValues(alpha: 0.6),
                width: DesignTokens.glassBorderWidth,
              )
            : Border.all(
                color: glass.border,
                width: 0.5,
              ));

    List<BoxShadow> effectiveShadow;
    if (customShadow != null) {
      effectiveShadow = customShadow!;
    } else if (isGlass) {
      effectiveShadow = DesignTokens.glassShadow(shadowColor ?? Colors.transparent);
    } else {
      effectiveShadow = DesignTokens.shadowMd(shadowColor ?? Colors.transparent);
    }

    Widget cardBody = Container(
      height: height,
      width: width,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        gradient: gradient,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    // Wrap with glass blur effect
    if (isGlass) {
      cardBody = ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: glassBlurSigma ?? DesignTokens.glassBlurMd,
            sigmaY: glassBlurSigma ?? DesignTokens.glassBlurMd,
          ),
          child: cardBody,
        ),
      );
    }

    // Wrap with margin if provided
    if (margin != null) {
      cardBody = Padding(
        padding: margin!,
        child: cardBody,
      );
    }

    if (onTap != null) {
      return ScalePress(
        onTap: onTap,
        child: cardBody,
      );
    }

    return cardBody;
  }

  /// ═══════════════════════════════════════
  ///  PERFORMANCE: Shared BackdropFilter Group
  /// ═══════════════════════════════════════
  ///
  /// Wraps multiple children in a single shared BackdropFilter.
  /// This is much more performant than wrapping each child in its own
  /// BackdropFilter, because Flutter only needs to blur once.
  ///
  /// Use this when you have several adjacent glass cards (e.g., a row of
  /// stats, a grid of bento tiles) to avoid the per-card blur penalty.
  ///
  /// Example:
  /// ```dart
  /// PremiumCard.glassGroup(
  ///   blurSigma: DesignTokens.glassBlurLight,
  ///   children: [
  ///     PremiumCard(isGlass: false, child: ...),
  ///     PremiumCard(isGlass: false, child: ...),
  ///   ],
  /// )
  /// ```
  ///
  /// Pass a [context] to auto-detect the correct glass surface color
  /// for the current theme (light/dark). If omitted, defaults to
  /// [glass.surface].
  static Widget glassGroup({
    BuildContext? context,
    required List<Widget> children,
    double blurSigma = DesignTokens.glassBlurLight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = DesignTokens.radiusLg,
    Color? backgroundColor,
    Gradient? gradient,
    Border? border,
    List<BoxShadow>? boxShadow,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    Axis direction = Axis.vertical,
    double gap = 0,
  }) {
    final glass = context != null
        ? Theme.of(context).extension<GlassTokens>()
        : null;

    Widget group = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                (glass?.background ?? const Color(0xFFF8F9FF)),
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: gradient,
            border: border ??
                Border.all(
                  color: glass?.border.withValues(alpha: 0.6) ?? const Color(0xFFE0E0E0).withValues(alpha: 0.6),
                  width: DesignTokens.glassBorderWidth,
                ),
            boxShadow: boxShadow ?? DesignTokens.glassShadow(Colors.transparent),
          ),
          padding: padding,
          child: direction == Axis.vertical
              ? Column(
                  mainAxisSize: mainAxisSize,
                  children: _insertGaps(children, SizedBox(height: gap)),
                )
              : Row(
                  mainAxisSize: mainAxisSize,
                  children: _insertGaps(children, SizedBox(width: gap)),
                ),
        ),
      ),
    );

    if (margin != null) {
      group = Padding(padding: margin, child: group);
    }

    return group;
  }

  static List<Widget> _insertGaps(List<Widget> items, Widget gap) {
    if (items.isEmpty) return items;
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) result.add(gap);
    }
    return result;
  }
}

/// Bento grid visual variants for cards.
enum BentoVariant {
  /// Default card with standard padding
  standard,

  /// Larger, featured content — wider padding, more visual weight
  hero,

  /// Compact padding for dense bento layouts
  compact,

  /// Tall emphasis for vertical content
  tall,
}
