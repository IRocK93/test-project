import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/baby_mon_summary.dart';
import 'evolution_visualizer.dart';
import 'xp_progress_bar.dart';

class BabyMonCard extends StatelessWidget {
  final BabyMonSummary babyMon;
  final VoidCallback? onTap;

  const BabyMonCard({
    super.key,
    required this.babyMon,
    this.onTap,
  });

  String _formatAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final days = difference.inDays;

    if (days < 7) {
      return '$days days old';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} old';
    } else {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} old';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        babyMon.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatAge(babyMon.birthDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Total: ${babyMon.totalXp} XP',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              EvolutionVisualizer(stage: babyMon.stage),
              const SizedBox(height: 20),
              XpProgressBar(
                level: babyMon.level,
                currentXp: babyMon.currentXp,
                xpForNextLevel: babyMon.xpForNextLevel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}