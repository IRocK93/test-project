import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/health_provider.dart';
import '../widgets/health_record_card.dart';
import '../widgets/health_record_form.dart';
import '../../../milestones/presentation/providers/milestones_provider.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBabyMonId = ref.watch(selectedBabyMonIdProvider);
    final recordsAsync = ref.watch(healthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Health'), backgroundColor: Colors.transparent, elevation: 0,
        actions: [if (selectedBabyMonId != null) IconButton(icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(healthProvider.notifier).loadRecords())]),
      body: selectedBabyMonId == null
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text('👶', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16), Text('No BabyMon selected', style: TextStyle(color: Colors.grey)),
          ]))
        : recordsAsync.when(loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)), const SizedBox(height: 12),
            Text('Error: $err', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12), ElevatedButton(onPressed: () => ref.read(healthProvider.notifier).loadRecords(),
              child: const Text('Retry')),
          ])),
          data: (records) {
            if (records.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Text('💊', style: TextStyle(fontSize: 64)), SizedBox(height: 16),
              Text('No health records yet', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8), Text('Tap + to add a record', style: TextStyle(color: Colors.grey)),
            ]));
            return RefreshIndicator(
              onRefresh: () => ref.read(healthProvider.notifier).loadRecords(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16), itemCount: records.length,
                itemBuilder: (_, i) => HealthRecordCard(record: records[i],
                  onDelete: () => ref.read(healthProvider.notifier).deleteRecord(records[i].id)),
              ),
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
        builder: (ctx) => HealthRecordForm(babyMonId: babyMonId,
          onSubmit: (record) async {
            await ref.read(healthProvider.notifier).addRecord(record);
          },
        )).then((_) => Navigator.pop(context));
  }
}
