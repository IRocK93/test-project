import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../constants/app_colors.dart';

/// A premium progress bar with glass gradient fill and optional glow.
///
/// Used for XP bars, progress indicators, and level displays.
/// Enhanced with frosted track background and gradient shimmer.
class PremiumProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showGlow;
  final bool showLabel;
  final String? leadingLabel;
  final String? trailingLabel;
  final bool isGlass;

  const PremiumProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.showGlow = false,
    this.showLabel = false,
    this.leadingLabel,
    this.trailingLabel,
    this.isGlass = false,
  });

  Color get _progressFillColor => progressColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ??
        (isGlass
            ? (isDark
                ? context.colorScheme.surfaceContainerHighest
                : context.colorScheme.surface)
            : context.dividerColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Labels ──
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leadingLabel != null)
                Text(
                  leadingLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (trailingLabel != null)
                Text(
                  trailingLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXs),
        ],

        // ── Track ──
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Track background
                Container(
                  width: double.infinity,
                  height: height,
                  color: effectiveBg,
                ),

                // Glass shimmer overlay on track
                if (isGlass)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                // Progress fill
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.primary,
                          _progressFillColor,
                        ],
                      ),
                      boxShadow: showGlow
                          ? [
                              BoxShadow(
                                color: _progressFillColor
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
