import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/glass_tokens.dart';

/// A premium stat card for displaying metrics with icon and color.
///
/// Glassmorphism-enhanced with frosted background, subtle shimmer borders,
/// and compact bento-friendly sizing.
class PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isGlass;

  const PremiumStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTokens>()!;

    final effectiveBg = backgroundColor ??
        (isGlass
            ? glass.background
            : iconColor.withValues(alpha: 0.1));

    final effectiveBorder = Border.all(
      color: glass.borderLight,
      width: 0.5,
    );

    Widget statTile = Container(
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.spaceMd,
        horizontal: DesignTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: effectiveBorder,
        boxShadow: [
          BoxShadow(
            color: glass.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon container with subtle glow ──
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          // ── Value ──
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: iconColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: DesignTokens.space2xs),
          // ── Label ──
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: iconColor.withValues(alpha: 0.75),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    // Wrap with glass blur
    if (isGlass) {
      statTile = ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: DesignTokens.glassBlurLight,
            sigmaY: DesignTokens.glassBlurLight,
          ),
          child: statTile,
        ),
      );
    }

    if (onTap != null) {
      return Semantics(
        label: 'Tap',
        button: true,
        child: GestureDetector(onTap: onTap, child: statTile),
      );
    }

    return statTile;
  }
}
