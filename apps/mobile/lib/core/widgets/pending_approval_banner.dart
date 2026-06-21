import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// A banner at the top of the Journal screen that surfaces pending
/// approval requests from co-parents. Renders nothing if [count] is 0.
///
/// warningContainer background, 12dp radius, 1px warning border, a
/// warning icon, descriptive text, and a "Review" call-to-action.
class PendingApprovalBanner extends StatelessWidget {
  final int count;
  final VoidCallback? onReview;

  const PendingApprovalBanner({
    super.key,
    required this.count,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    final label = count == 1
        ? '1 change from your partner'
        : '$count changes from your partner';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLg,
        DesignTokens.spaceMd,
        DesignTokens.spaceLg,
        0,
      ),
      child: Semantics(
        label: 'Review pending approvals',
        button: true,
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onReview == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onReview!.call();
                },
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLg,
              vertical: DesignTokens.spaceMd,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.tertiary.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: context.colorScheme.tertiary.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsLight.hourglass,
                  size: 20,
                  color: context.colorScheme.tertiary,
                ),
                const SizedBox(width: DesignTokens.spaceMd),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Text(
                  'Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  PhosphorIconsLight.caretRight,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
