import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

/// Stage Insights — inviting gateway to the AI Companion.
class DashboardContentCard extends StatelessWidget {
  final Map<String, dynamic> stageContent;
  final VoidCallback? onReflectionTap;
  final VoidCallback? onOpenChat;
  final VoidCallback? onViewMilestones;

  const DashboardContentCard({
    super.key,
    required this.stageContent,
    this.onReflectionTap,
    this.onOpenChat,
    this.onViewMilestones,
  });

  @override
  Widget build(BuildContext context) {
    final summary = parseString(stageContent['summaryText']);
    final stageTitle = parseString(stageContent['title']) ?? context.l10n.stageInsights;
    final tips = stageContent['expertTips'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    context.colorScheme.primary,
                    context.colorScheme.tertiary,
                  ]),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: const Icon(PhosphorIconsLight.sparkle,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stageTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.onSurface),
                    ),
                    Text(
                      context.l10n.poweredByEnasAi,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spaceLg),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(
                  color: context.colorScheme.outline.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summary != null) ...[
                  Text(
                    summary,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            height: 1.5),
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                ],
                if (tips.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(PhosphorIconsLight.lightbulb,
                          size: 14, color: context.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          parseString(tips.first) ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: PhosphorIconsLight.chatCircleDots,
                        label: context.l10n.askEnas,
                        subtitle: context.l10n.askCompanion,
                        color: context.colorScheme.primary,
                        onTap: onOpenChat,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Expanded(
                      child: _ActionButton(
                        icon: PhosphorIconsLight.target,
                        label: context.l10n.milestones,
                        subtitle: context.l10n.trackProgress,
                        color: context.colorScheme.tertiary,
                        onTap: onViewMilestones,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceMd),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: DesignTokens.spaceSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: DesignTokens.fontSm,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: DesignTokens.font2xs,
                        color: context.textCaption),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
