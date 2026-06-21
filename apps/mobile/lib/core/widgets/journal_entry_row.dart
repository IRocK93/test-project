import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';
import 'journal_entry_type.dart';

/// A single journal entry row — used in the list section of the
/// redesigned Journal screen.
///
/// 64dp tall, 12dp horizontal padding, leading 40×40 tinted icon
/// square, title, subtitle, trailing time + more icon. Optional
/// pending-sync badge. Tap fires [onTap], the more icon fires [onMore].
class JournalEntryRow extends StatelessWidget {
  final JournalEntryType type;
  final String title;
  final String subtitle;
  final String trailingTime; // pre-formatted, e.g. "2:14 PM"
  final bool isPendingSync;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const JournalEntryRow({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.trailingTime,
    this.isPendingSync = false,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? context.colorScheme.onPrimary : context.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: title,
        button: true,
        child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!.call();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 40×40 tinted icon square
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusSm),
                  border: Border.all(
                    color: type.color.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(type.icon, size: 18, color: type.color),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPendingSync) ...[
                          const SizedBox(width: DesignTokens.spaceXs),
                          Tooltip(
                            message: 'Sync pending',
                            child: Icon(
                              PhosphorIconsLight.cloudArrowUp,
                              size: 14,
                              color: context.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: context.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              // Trailing time + more
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    trailingTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                  if (onMore != null)
                    Semantics(
                      label: 'More options',
                      button: true,
                      child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onMore!.call();
                      },
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusFull),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          PhosphorIconsLight.dotsThree,
                          size: 18,
                          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
