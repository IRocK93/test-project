import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_data.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/baby_mon_card.dart';
import '../widgets/badge_showcase.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              if (data.babyMons.isNotEmpty) ...[
                BabyMonCard(babyMon: data.babyMons.first),
                const SizedBox(height: 24),
              ],
              _TodayStats(data.todayStats),
              const SizedBox(height: 24),
              Text(
                'Recent Badges',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              BadgeShowcase(
                badges: data.babyMons.isNotEmpty
                    ? data.babyMons.first.recentBadges
                    : [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayStats extends StatelessWidget {
  final Map<String, int> stats;

  const _TodayStats(this.stats);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(
          emoji: '🍼',
          label: 'Feedings',
          value: stats['feedingCount'] ?? 0,
        ),
        _StatChip(
          emoji: '📋',
          label: 'Health',
          value: stats['healthLogs'] ?? 0,
        ),
        _StatChip(
          emoji: '🏆',
          label: 'Milestones',
          value: stats['milestones'] ?? 0,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;

  const _StatChip({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
