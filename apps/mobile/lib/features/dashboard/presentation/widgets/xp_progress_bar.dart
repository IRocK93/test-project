import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';

class XpProgressBar extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpForNextLevel;

  const XpProgressBar({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNextLevel > 0 ? currentXp / xpForNextLevel : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.levelFallback(level),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              context.l10n.xpFormat(currentXp, xpForNextLevel, currentXp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.shade800,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
              },
            );
          },
        ),
      ],
    );
  }
}
