import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/widgets/premium_card.dart';

/// Stage-specific editorial content card (summary + tips).
class DashboardContentCard extends StatelessWidget {
  final Map<String, dynamic> stageContent;

  const DashboardContentCard({super.key, required this.stageContent});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      isGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsLight.sparkle,
                  color: context.colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                parseString(stageContent['title']) ?? 'Stage Insights',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (stageContent['summary'] != null) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              parseString(stageContent['summary']) ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
          if (stageContent['tips'] != null) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            ...parseList(stageContent['tips']).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      Expanded(
                        child: Text(
                          tip.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
