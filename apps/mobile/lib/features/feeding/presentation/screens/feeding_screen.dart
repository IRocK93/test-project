import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/feeding_provider.dart';
import '../widgets/feed_log_card.dart';
import '../widgets/feed_log_form.dart';
import '../../../milestones/presentation/providers/milestones_provider.dart';

class FeedingScreen extends ConsumerWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBabyMonId = ref.watch(selectedBabyMonIdProvider);
    final logsAsync = ref.watch(feedingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feeding'), backgroundColor: Colors.transparent, elevation: 0,
        actions: [if (selectedBabyMonId != null) IconButton(icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(feedingProvider.notifier).loadFeedLogs())]),
      body: selectedBabyMonId == null
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text('👶', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16), Text('No BabyMon selected', style: TextStyle(color: Colors.grey)),
          ]))
        : logsAsync.when(loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)), SizedBox(height: 12),
            Text('Error: $err', style: const TextStyle(color: Colors.red)),
            SizedBox(height: 12), ElevatedButton(onPressed: () => ref.read(feedingProvider.notifier).loadFeedLogs(),
              child: const Text('Retry')),
          ])),
          data: (logs) {
            if (logs.isEmpty) return Center(child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🍼', style: TextStyle(fontSize: 64)), SizedBox(height: 16),
              Text('No feedings logged', style: TextStyle(color: Colors.grey)),
            ]));
            // Group by date
            final Map<DateTime, List<dynamic>> groups = {};
            for (final log in logs) {
              final key = DateTime(log.loggedAt.year, log.loggedAt.month, log.loggedAt.day);
              groups.putIfAbsent(key, () => []);
              groups[key]!.add(log);
            }
            final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
            return RefreshIndicator(
              onRefresh: () => ref.read(feedingProvider.notifier).loadFeedLogs(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16), itemCount: sortedKeys.length,
                itemBuilder: (_, i) {
                  final date = sortedKeys[i];
                  final dateStr = i == 0 ? 'Today' : i == 1 ? 'Yesterday'
                    : DateFormat('EEEE, MMM d').format(DateTime(date.year, date.month, date.day));
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.only(bottom: 8),
                      child: Text(dateStr, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600))),
                    ...groups[date]!.map((l) => FeedLogCard(feedLog: l as dynamic, onDelete: () =>
                      ref.read(feedingProvider.notifier).deleteFeedLog((l as dynamic).id))).toList(),
                  ]);
                }),
            );
          }),
      floatingActionButton: selectedBabyMonId != null
        ? FloatingActionButton(backgroundColor: Colors.deepPurple,
          onPressed: () => _showForm(context, ref), child: const Icon(Icons.add))
        : null,
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final babyMonId = ref.read(selectedBabyMonIdProvider);
    if (babyMonId == null) return;
    showModalBottomSheet(context: context, isScrollControlled: true,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => FeedLogForm(babyMonId: babyMonId,
          onSubmit: (log) async {
            await ref.read(feedingProvider.notifier).addFeedLog(log);
          },
        )).then((_) => Navigator.pop(context));
  }
}
