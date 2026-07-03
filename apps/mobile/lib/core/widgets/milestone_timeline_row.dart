import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';

/// A single row in the Milestones screen's vertical timeline.
///
/// Replaces the previous 7-level-nested widget (IntrinsicHeight →
/// Row → Column → Expanded → Dismissible → ClipRRect → BackdropFilter
/// → Container) with a flat 14px-radius card, a single colored dot
/// on the rail, and a clean two-line title/notes layout.
///
/// Color of the dot/rail is derived deterministically from [seed] so
/// the same milestone renders the same color across reloads.
class MilestoneTimelineRow extends StatelessWidget {
  static final _monthFmt = DateFormat.MMM();
  final String title;
  final String? notes;
  final DateTime? date;
  final int seed;
  final bool isLast;
  final bool isPendingSync;
  final VoidCallback? onTap;
  final Future<bool> Function()? onConfirmDelete;

  const MilestoneTimelineRow({
    super.key,
    required this.title,
    required this.seed,
    this.notes,
    this.date,
    this.isLast = false,
    this.isPendingSync = false,
    this.onTap,
    this.onConfirmDelete,
  });

  static const _palette = [
    Color(0xFF7C5CFC),
    Colors.amber,
    Color(0xFF7C5CFC),
    Colors.green,
  ];

  Color get _dotColor => _palette[seed.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? context.glass.background : context.colorScheme.surface;
    final borderColor =
        isDark ? context.colorScheme.outline : context.colorScheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Date + rail column (40dp) ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (date != null)
                  Text(
                    '${_monthFmt.format(date!)} ${date!.day}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _dotColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _dotColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : context.dividerColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          // ── Card body ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              child: _buildCard(context, cardColor, borderColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Color cardColor,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget content = Semantics(
      label: title,
      button: true,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            // Color anchor bar.
            Container(
              width: 4,
              height: 44,
              margin: const EdgeInsetsDirectional.only(end: DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: _dotColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                  if (notes != null && notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notes!,
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
            if (isPendingSync)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: DesignTokens.spaceSm),
                child: Icon(
                  PhosphorIconsLight.cloudArrowUp,
                  color: context.colorScheme.tertiary,
                  size: 16,
                ),
              ),
            Icon(
              PhosphorIconsLight.caretRight,
              color: context.colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
      ),
    );

    if (onConfirmDelete != null) {
      content = Dismissible(
        key: ValueKey('milestone-$seed-$title'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => onConfirmDelete!(),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsetsDirectional.only(end: 24),
          decoration: BoxDecoration(
            color: context.colorScheme.error,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Icon(PhosphorIconsLight.trash, color: context.colorScheme.onError),
        ),
        child: content,
      );
    }

    return content;
  }


}
