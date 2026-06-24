import 'package:flutter/material.dart';
import '../../domain/entities/baby_mon_summary.dart';

class BadgeShowcase extends StatelessWidget {
  final List<BadgeInfo> badges;

  const BadgeShowcase({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Text(
              '🥹',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              'No badges yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep caring for your BabyMon to earn badges!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _BadgeItem(badge: badge);
        },
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeInfo badge;

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${badge.name}\n${badge.description}',
      preferBelow: true,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.iconEmoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
