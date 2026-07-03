import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';

class EvolutionVisualizer extends StatelessWidget {
  final String stage;
  final VoidCallback? onTap;

  const EvolutionVisualizer({
    super.key,
    required this.stage,
    this.onTap,
  });

  String get _stageEmoji {
    switch (stage.toLowerCase()) {
      case 'egg':
        return '🥚';
      case 'hatchling':
        return '🐣';
      case 'juvenile':
        return '🐥';
      case 'adult':
        return '🐓';
      default:
        return '🥚';
    }
  }

  String _stageName(BuildContext context) {
    switch (stage.toLowerCase()) {
      case 'egg':
        return context.l10n.stageEgg;
      case 'hatchling':
        return context.l10n.stageHatchling;
      case 'juvenile':
        return context.l10n.stageJuvenile;
      case 'adult':
        return context.l10n.stageAdult;
      default:
        return context.l10n.stageUnknown;
    }
  }

  String _stageDescription(BuildContext context) {
    switch (stage.toLowerCase()) {
      case 'egg':
        return context.l10n.stageEggDescription;
      case 'hatchling':
        return context.l10n.stageHatchlingDescription;
      case 'juvenile':
        return context.l10n.stageJuvenileDescription;
      case 'adult':
        return context.l10n.stageAdultDescription;
      default:
        return context.l10n.stageUnknown;
    }
  }

  void _showStageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(_stageEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Text(_stageName(context)),
          ],
        ),
        content: Text(_stageDescription(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.gotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          _showStageInfo(context);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [            Text(
              _stageEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _stageName(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
