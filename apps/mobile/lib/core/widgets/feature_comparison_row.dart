import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// A single row in the Subscription screen's feature comparison matrix.
///
/// Renders a 48dp row with the feature name on the left (60% width)
/// and two icon cells on the right — one for Free, one for Premium.
class FeatureComparisonRow extends StatelessWidget {
  final String feature;
  final bool freeIncluded;
  final bool premiumIncluded;
  final bool isLast;

  const FeatureComparisonRow({
    super.key,
    required this.feature,
    required this.freeIncluded,
    required this.premiumIncluded,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: context.dividerColor.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: _Cell(included: freeIncluded, accent: context.colorScheme.tertiary),
          ),
          Expanded(
            child:
                _Cell(included: premiumIncluded, accent: context.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final bool included;
  final Color accent;
  const _Cell({required this.included, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: included
              ? accent.withValues(alpha: 0.15)
              : context.dividerColor.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          included ? PhosphorIconsLight.check : PhosphorIconsLight.minus,
          size: 14,
          color: included ? accent : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
