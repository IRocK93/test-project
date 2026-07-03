import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// A premium section header widget with title, optional subtitle, and optional action.
///
/// Use at the top of each section in dashboard and list screens.
class PremiumSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final EdgeInsetsGeometry? padding;

  const PremiumSection({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceSm,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left decoration line
          Container(
            width: 3,
            height: 24,
            margin: const EdgeInsetsDirectional.only(top: 2, end: DesignTokens.spaceSm),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),

          // Action button
          if (actionLabel != null && onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? PhosphorIconsLight.caretRight, size: 12),
              label: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
