import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A consistent section header for the Settings screen.
///
/// Modern iOS-style: uppercase label, tight letter-spacing, no bar accent.
/// Optional trailing link and "danger" treatment for the Danger Zone.
///
/// Use one of these between every group of settings rows.
class SettingsSectionHeader extends StatelessWidget {
  /// The uppercase label shown above a section of rows.
  final String title;

  /// Optional right-aligned action link, e.g. "Manage all".
  final String? trailingLabel;

  /// Callback for the trailing link.
  final VoidCallback? onTrailingTap;

  /// Applies an `errorContainer` background and red text — used for the
  /// Danger Zone so destructive actions are visually distinct.
  final bool danger;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    this.danger = false,
  });

  @override
	  Widget build(BuildContext context) {
    final bg = danger
        ? context.colorScheme.error
        : Colors.transparent;
    final fg = danger
        ? context.colorScheme.onError
        : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final dividerColor = danger
        ? context.colorScheme.onError.withValues(alpha: 0.25)
        : context.dividerColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLg,
        DesignTokens.spaceLg,
        DesignTokens.spaceLg,
        DesignTokens.spaceLg,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: fg,
              ),
            ),
          ),
          if (trailingLabel case final trailing? when onTrailingTap != null)
            Semantics(
              label: trailing,
              button: true,
              child: InkWell(
              onTap: onTrailingTap,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceSm,
                  vertical: DesignTokens.space2xs,
                ),
                child: Text(
                  trailingLabel!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
              ),
        ],
      ),
    );
  }
}
