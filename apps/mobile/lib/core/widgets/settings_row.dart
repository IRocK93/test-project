import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// A single row in the Settings screen — leading icon, title, optional
/// subtitle, and a flexible trailing widget (chevron, switch, segmented
/// control, plain text).
///
/// Renders a 1px hairline divider below the row (suppressed when [last]
/// is true) so multiple `SettingsRow`s inside the same card visually
/// group as one section.
class SettingsRow extends StatelessWidget {
  /// 24×24 icon shown inside a 36×36 tinted square.
  final IconData icon;

  /// Tint color for the leading icon and its square background.
  final Color iconColor;

  /// 16pt, w600 — the primary label.
  final String title;

  /// 13pt, w400 — a secondary description. Wraps to 2 lines max.
  final String? subtitle;

  /// Anything that goes on the right edge: chevron, `Switch`,
  /// `SegmentedButton`, plain `Text`, etc. When omitted, a default
  /// chevron-right is shown if [onTap] is non-null.
  final Widget? trailing;

  /// Tap handler for the whole row. If null, the row is not interactive.
  final VoidCallback? onTap;

  /// When true, the title is rendered in [colorScheme.error].
  final bool destructive;

  /// Suppresses the hairline divider beneath the row.
  final bool last;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    final titleColor = destructive
        ? colorScheme.error
        : colorScheme.onSurface;
    final iconBg = iconColor.withValues(alpha: 0.12);
    final iconBorder = iconColor.withValues(alpha: 0.20);

    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    final minHeight = hasSubtitle ? 72.0 : 56.0;

    Widget row = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                  color: dividerColor.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading icon — 36×36 tinted square
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              border: Border.all(color: iconBorder, width: 0.5),
            ),
            alignment: Alignment.center,
            child: ExcludeSemantics(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Trailing widget
          if (trailing != null)
            trailing!
          else if (onTap != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: DesignTokens.spaceSm),
              child: Icon(
                PhosphorIconsLight.caretRight,
                size: 22,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      row = Semantics(
        label: title,
        button: true,
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!.call();
          },
          child: row,
        ),
      ),
      );
    }

    return row;
  }
}
