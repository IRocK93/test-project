import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';
import 'sliver_fill_centered.dart';
import 'theme_button.dart';

/// A premium empty state widget with icon, message, and optional action button.
///
/// Use instead of raw icon + text for empty lists and states across the app.
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  /// Quick preset for "No data yet" with add action
  static PremiumEmptyState noData({
    required String itemName,
    VoidCallback? onAdd,
  }) {
    return PremiumEmptyState(
      icon: PhosphorIconsLight.mailbox,
      title: 'No $itemName yet',
      subtitle: 'Tap + to add your first $itemName',
      actionLabel: onAdd != null ? 'Add $itemName' : null,
      onAction: onAdd,
    );
  }

  /// Quick preset for "Coming soon" feature
  static PremiumEmptyState comingSoon({
    String featureName = 'This feature',
    IconData icon = PhosphorIconsLight.wrench,
  }) {
    return PremiumEmptyState(
      icon: icon,
      title: 'Coming Soon',
      subtitle: '$featureName is under development.',
    );
  }

  /// Builds the action button when [actionLabel] and [onAction] are both non-null.
  Widget _buildActionButton(BuildContext context, String actionLabel, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.space2xl),
      child: ThemeButton(
        text: actionLabel,
        onPressed: onAction,
        icon: PhosphorIconsLight.plus,
        semanticLabel: actionLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverFillCentered(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            ),
            child: customIcon ??
                Icon(
                  icon,
                  size: 36,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: DesignTokens.space2xl),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),

          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],

          // Action button
          if (actionLabel != null && onAction != null)
            _buildActionButton(context, actionLabel!, onAction!),
        ],
      ),
    );
  }
}
