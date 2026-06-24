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

  String get _stageName {
    switch (stage.toLowerCase()) {
      case 'egg':
        return 'Egg';
      case 'hatchling':
        return 'Hatchling';
      case 'juvenile':
        return 'Juvenile';
      case 'adult':
        return 'Adult';
      default:
        return 'Unknown';
    }
  }

  String get _stageDescription {
    switch (stage.toLowerCase()) {
      case 'egg':
        return 'Your BabyMon is developing in the egg. Keep the environment stable!';
      case 'hatchling':
        return 'Your BabyMon has hatched! It needs lots of care and attention.';
      case 'juvenile':
        return 'Growing fast! Your BabyMon is becoming more active.';
      case 'adult':
        return 'Your BabyMon has reached maturity. Great job raising it!';
      default:
        return 'Unknown stage';
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
            Text(_stageName),
          ],
        ),
        content: Text(_stageDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
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
        children: [
          Text(
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
              _stageName,
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
