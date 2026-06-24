import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/utils/theme_text_utils.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';

class SyncBanner extends ConsumerWidget {
  final String babyMonId;
  final VoidCallback onRetry;

  const SyncBanner({super.key, required this.babyMonId, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider(babyMonId));

    if (status == SyncStatus.idle) return const SizedBox.shrink();

    final (color, icon, text) = switch (status) {
      SyncStatus.pending => (
          context.colorScheme.surfaceContainerHighest,
          PhosphorIconsLight.cloudArrowUp,
          _pendingLabel(ref, babyMonId),
        ),
      SyncStatus.syncing => (
          context.colorScheme.primaryContainer,
          PhosphorIconsLight.arrowsClockwise,
          'Syncing…',
        ),
      SyncStatus.error => (
          context.colorScheme.errorContainer,
          PhosphorIconsLight.warningCircle,
          'Sync failed — tap to retry',
        ),
      _ => (Colors.transparent, null, ''),
    };

    return GestureDetector(
      onTap: status == SyncStatus.error ? onRetry : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceXs),
        color: color,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: context.textSecondary),
              const SizedBox(width: DesignTokens.spaceXs),
            ],
            if (status == SyncStatus.syncing)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Flexible(child: Text(text, style: TextStyle(fontSize: DesignTokens.fontXs, color: context.textSecondary))),
          ],
        ),
      ),
    );
  }

  String _pendingLabel(WidgetRef ref, String babyMonId) {
    final routine = ref.watch(pendingRoutineStepsProvider(babyMonId)).length;
    final achieve = ref.watch(pendingMilestoneAchievementsProvider(babyMonId)).length;
    final unachieve = ref.watch(pendingMilestoneUnachievementsProvider(babyMonId)).length;
    final total = routine + achieve + unachieve;
    return '$total change${total == 1 ? '' : 's'} pending';
  }
}
