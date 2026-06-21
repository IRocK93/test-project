import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';

/// A single row in the Health screen's record list.
///
/// Flatter alternative to the previous `PremiumCard + ListTile` combo.
/// Single 14px-radius surface, type-tinted icon at 36×36, two-line
/// subtitle (value+unit on line 1, date+notes on line 2).
class HealthRecordRow extends StatelessWidget {
  final String title;
  final String? value;
  final String? unit;
  final DateTime? date;
  final String? notes;
  final IconData icon;
  final Color iconColor;
  final bool isDismissible;
  final Future<bool> Function()? onConfirmDelete;

  const HealthRecordRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.value,
    this.unit,
    this.date,
    this.notes,
    this.isDismissible = false,
    this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? context.glass.background : context.colorScheme.surface;
    final borderColor =
        isDark ? context.colorScheme.outline : context.colorScheme.outline;

    Widget child = Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                  ),
                ),
                if (value != null || date != null || notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (value != null)
                        unit != null ? '$value $unit' : '$value',
                      if (date != null) _formatDate(date!),
                      if (notes != null && notes!.isNotEmpty) notes!,
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (isDismissible && onConfirmDelete != null) {
      child = Dismissible(
        key: ValueKey(title + (date?.toIso8601String() ?? '')),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => onConfirmDelete!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: context.colorScheme.error,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Icon(PhosphorIconsLight.trash, color: context.colorScheme.onError),
        ),
        child: child,
      );
    }

    return child;
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
