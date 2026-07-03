import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A premium double-bezel (Doppelrand) container that wraps content in a nested
/// shell-and-core architecture — the hallmark of $150k agency-level UI.
///
/// ── Outer Shell ──
/// A subtle tray-like background (e.g., `bg-black/5` or tinted) with a hairline
/// border, generous outer squricle radius ([outerRadius]), and minimal padding
/// (`p-1.5` / 6px) that creates the visual illusion of a physical glass plate
/// sitting in an aluminum tray.
///
/// ── Inner Core ──
/// The actual content surface. Has its own [innerColor], an inner highlight
/// shadow (`shadow-[inset_0_1px_1px_rgba(255,255,255,0.15)]`), and a
/// mathematically smaller radius (`outerRadius - gap`) for perfectly concentric
/// curves.
///
/// Use this instead of raw `Container` for all premium cards, feature grids,
/// stat tiles, and content blocks that sit on top of the background.
///
/// Example:
/// ```dart
/// PremiumDoubleBezel(
///   child: Column(children: [...]),
/// )
/// ```
class PremiumDoubleBezel extends StatelessWidget {
  final Widget child;
  final double outerRadius;
  final double gap;
  final Color? outerColor;
  final Color? innerColor;
  final EdgeInsetsGeometry? innerPadding;
  final EdgeInsetsGeometry? outerPadding;
  final VoidCallback? onTap;
  final Gradient? innerGradient;
  final Border? innerBorder;
  final List<BoxShadow>? innerShadow;
  final bool showInnerHighlight;

  const PremiumDoubleBezel({
    super.key,
    required this.child,
    this.outerRadius = DesignTokens.radius2xl,
    this.gap = 6.0,
    this.outerColor,
    this.innerColor,
    this.innerPadding,
    this.outerPadding,
    this.onTap,
    this.innerGradient,
    this.innerBorder,
    this.innerShadow,
    this.showInnerHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveOuterColor = outerColor ??
        theme.colorScheme.outlineVariant.withValues(alpha: 0.15);

    final effectiveInnerColor = innerColor ??
        theme.colorScheme.surface;

    final effectiveInnerRadius = outerRadius - gap;

    // ── Build inner shadow list ──
    final shadows = <BoxShadow>[
      // Inner highlight (top edge light)
      if (showInnerHighlight)
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.5),
          blurRadius: 2,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      // Ambient shadow
      BoxShadow(
        color: (isDark ? context.glass.shadow : context.glass.shadow)
            .withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      ...?innerShadow,
    ];

    // ── Outer shell ──
    Widget shell = ClipRRect(
      borderRadius: BorderRadius.circular(outerRadius),
      child: Container(
        padding: outerPadding ?? EdgeInsets.all(gap),
        decoration: BoxDecoration(
          color: effectiveOuterColor,
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            width: 0.5,
          ),
        ),
        // ── Inner core ──
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveInnerRadius),
          child: Container(
            padding: innerPadding ??
                const EdgeInsets.all(DesignTokens.spaceLg),
            decoration: BoxDecoration(
              color: effectiveInnerColor,
              borderRadius: BorderRadius.circular(effectiveInnerRadius),
              gradient: innerGradient,
              border: innerBorder,
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );

    // Always wrap with half-gap margin so the outer hairlines are visible
    shell = Padding(
      padding: EdgeInsets.all(gap / 2),
      child: shell,
    );

    if (onTap != null) {
      return Semantics(
        label: context.l10n.semanticTap,
        button: true,
        child: GestureDetector(onTap: onTap, child: shell),
      );
    }

    return shell;
  }
}
