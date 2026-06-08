import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/milestones_provider.dart';
import '../widgets/milestone_card.dart';
import '../widgets/milestone_form.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBabyMonId = ref.watch(selectedBabyMonIdProvider);
    final milestonesAsync = ref.watch(milestonesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (selectedBabyMonId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(milestonesProvider.notifier).loadMilestones(),
            ),
        ],
      ),
      body: selectedBabyMonId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👶', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No BabyMon selected', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Create one from the Dashboard', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : milestonesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text('Error: $err', style: TextStyle(color: Colors.red[300]), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(milestonesProvider.notifier).loadMilestones(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (milestones) {
                if (milestones.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text('No milestones yet', style: TextStyle(color: Colors.grey[300], fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first!', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(milestonesProvider.notifier).loadMilestones(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: milestones.length,
                    itemBuilder: (context, index) {
                      return MilestoneCard(
                        milestone: milestones[index],
                        onDelete: () => ref.read(milestonesProvider.notifier).deleteMilestone(milestones[index].id),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: selectedBabyMonId != null
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () => _showAddForm(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddForm(BuildContext context, WidgetRef ref) {
    final babyMonId = ref.read(selectedBabyMonIdProvider);
    if (babyMonId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MilestoneForm(
        babyMonId: babyMonId,
        onSubmit: (milestone) async {
          await ref.read(milestonesProvider.notifier).addMilestone(milestone);
        },
      ),
    ).then((_) => Navigator.pop(context));
  }
}
