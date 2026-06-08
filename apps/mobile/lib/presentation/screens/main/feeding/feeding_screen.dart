import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

class FeedingScreen extends ConsumerStatefulWidget {
  const FeedingScreen({super.key});

  @override
  ConsumerState<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends ConsumerState<FeedingScreen> {
  String? _babyMonId;
  List _feedLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData();
    });
  }

  Future<void> _loadData() async {
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchFeedLogs();
  }

  Future<void> _fetchFeedLogs() async {
    if (_babyMonId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getFeedLogs(_babyMonId!);
      setState(() {
        _feedLogs = (response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _deleteFeedLog(String id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this feeding log?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteFeedLog(id);
      setState(() => _feedLogs.removeAt(index));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feeding log deleted')));
      return true;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedLogs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No feeding logs yet', style: TextStyle(color: Colors.grey)),
                      Text('Tap + to log a feeding'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchFeedLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _feedLogs.length,
                    itemBuilder: (context, index) {
                      final log = _feedLogs[index];
                      return Dismissible(
                        key: Key(log['id'] ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _deleteFeedLog(log['id'], index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                              child: Icon(
                                log['type'] == 'BREASTMILK' ? Icons.water_drop : (log['type'] == 'FORMULA' ? Icons.baby_changing_station : Icons.restaurant),
                                color: Colors.orange,
                              ),
                            ),
                            title: Text(log['type'] ?? ''),
                            subtitle: Text(
                              '${DateFormat.yMMMd().format(DateTime.parse(log['happenedAt']))}${log['amount'] != null ? ' - ${log['amount']} ${log['unit'] ?? ''}' : ''}',
                            ),
                            trailing: log['syncStatus'] == 'PENDING'
                                ? const Icon(Icons.cloud_upload, color: Colors.orange, size: 16)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'feeding_fab',
        onPressed: () => _showAddFeedLogDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFeedLogDialog() {
    String selectedType = 'BREASTMILK';
    final amountController = TextEditingController();
    final unitController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log Feeding', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'BREASTMILK', label: Text('Breastmilk')),
                  ButtonSegment(value: 'FORMULA', label: Text('Formula')),
                  ButtonSegment(value: 'SOLID', label: Text('Solid')),
                ],
                selected: {selectedType},
                onSelectionChanged: (s) => setDialogState(() => selectedType = s.first),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Amount', hintText: '120'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(labelText: 'Unit', hintText: 'ml'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat.yMMMd().format(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  try {
                    final api = ref.read(apiClientProvider);
                    if (_babyMonId == null) return;
                    await api.createFeedLog(_babyMonId!, {
                      'type': selectedType,
                      'amount': amountController.text.isNotEmpty ? amountController.text : null,
                      'unit': unitController.text.isNotEmpty ? unitController.text : null,
                      'notes': notesController.text,
                      'happenedAt': selectedDate.toIso8601String(),
                    });
                    await _fetchFeedLogs();
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}