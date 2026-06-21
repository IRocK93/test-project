import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/glass_tokens.dart';

/// A standalone glassmorphism surface widget.
///
/// Composes [ClipRRect], [BackdropFilter] with [ImageFilter.blur], and a
/// decorated [Container] into a single reusable primitive. Theme-aware:
/// picks [glass.background] or [glass.surface] automatically
/// based on the ambient [Brightness] when no explicit [backgroundColor]
/// is supplied.
///
/// For **multiple adjacent glass children** prefer [GlassSurface.group],
/// which amortises a single [BackdropFilter] across all children.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = DesignTokens.radiusLg,
    this.blurSigma = DesignTokens.glassBlurMd,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glass = Theme.of(context).extension<GlassTokens>();

    final effectiveBg = backgroundColor ??
        (glass != null
            ? (isDark ? glass.background : glass.surface)
            : (isDark
                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.85)));

    final effectiveBorderColor = borderColor ??
        (glass != null
            ? (isDark ? glass.border : glass.border.withValues(alpha: 0.6))
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3));

    Widget surface = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: effectiveBorderColor, width: DesignTokens.glassBorderWidth),
            boxShadow: DesignTokens.glassShadow(effectiveBg),
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      surface = Padding(padding: margin!, child: surface);
    }

    return surface;
  }

  /// Shared [BackdropFilter] group for performance.
  ///
  /// Wraps multiple children in a single blur so Flutter only composites
  /// once. Dramatically more efficient than wrapping each child individually.
  static Widget group({
    BuildContext? context,
    required List<Widget> children,
    double blurSigma = DesignTokens.glassBlurLight,
    double borderRadius = DesignTokens.radiusLg,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double gap = 0,
    Axis direction = Axis.vertical,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    final isDark = context != null
        ? Theme.of(context).brightness == Brightness.dark
        : false;
    final ctx = context;
    final effectiveBg = backgroundColor ??
        (isDark && ctx != null ? ctx.glass.background : ctx?.glass.surface ?? Colors.white);
    final effectiveBorderColor = borderColor ??
        (isDark && ctx != null ? ctx.glass.border : ctx?.glass.border.withValues(alpha: 0.6) ?? Colors.grey.shade300);

    Widget group = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: effectiveBorderColor, width: DesignTokens.glassBorderWidth),
            boxShadow: DesignTokens.glassShadow(effectiveBg),
          ),
          padding: padding,
          child: direction == Axis.vertical
              ? Column(mainAxisSize: mainAxisSize, children: _insertGaps(children, SizedBox(height: gap)))
              : Row(mainAxisSize: mainAxisSize, children: _insertGaps(children, SizedBox(width: gap))),
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
