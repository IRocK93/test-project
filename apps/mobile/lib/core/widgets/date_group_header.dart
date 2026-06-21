import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A date-group section header used in the Journal screen to break
/// the entries list into Today / Yesterday / This Week / Month Year
/// sections, the iOS Photos pattern.
class DateGroupHeader extends StatelessWidget {
  final String label;
  const DateGroupHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLg,
        DesignTokens.spaceLg,
        DesignTokens.spaceLg,
        DesignTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          height: 1.3,
        ),
      ),
    );
  }
}
