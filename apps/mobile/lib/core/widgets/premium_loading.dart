import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A premium loading widget with shimmer skeleton and branded spinner variants.
///
/// Provides consistent loading states across the app.
class PremiumLoading extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final Color? baseColor;

  const PremiumLoading({
    super.key,
    this.height,
    this.width,
    this.borderRadius = DesignTokens.radiusSm,
    this.baseColor,
  });

  /// A full-page branded loading spinner
  static Widget spinner({String? message}) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: DesignTokens.spaceMd),
                Text(
                  message,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// A shimmer placeholder matching a typical card's height
  static Widget cardSkeleton({
    double height = 100,
    double width = double.infinity,
  }) {
    return PremiumLoading(
      height: height,
      width: width,
      borderRadius: DesignTokens.radiusLg,
    );
  }

  /// A shimmer placeholder matching a typical list tile
  static Widget listTileSkeleton() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceSm,
      ),
      child: Row(
        children: [
          PremiumLoading(
            height: 40,
            width: 40,
            borderRadius: 20,
          ),
          SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumLoading(height: 14, width: 150),
                SizedBox(height: DesignTokens.spaceSm),
                PremiumLoading(height: 12, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBase = baseColor ?? Theme.of(context).cardTheme.color ?? context.colorScheme.surface;

    return Container(
      height: height ?? 20,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: effectiveBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
