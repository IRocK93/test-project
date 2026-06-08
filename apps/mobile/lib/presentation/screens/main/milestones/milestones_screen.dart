import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({super.key});

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen> {
  String? _babyMonId;
  List _milestones = [];
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
    await _fetchMilestones();
  }

  Future<void> _fetchMilestones() async {
    if (_babyMonId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getMilestones(_babyMonId!);
      setState(() {
        _milestones = (response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _deleteMilestone(String id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Milestone'),
        content: const Text('Are you sure you want to delete this milestone?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteMilestone(id);
      setState(() => _milestones.removeAt(index));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Milestone deleted')));
      return true;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _milestones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No milestones yet', style: TextStyle(color: Colors.grey)),
                      Text('Tap + to add your first milestone'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMilestones,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _milestones.length,
                    itemBuilder: (context, index) {
                      final milestone = _milestones[index];
                      return Dismissible(
                        key: Key(milestone['id'] ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _deleteMilestone(milestone['id'], index),
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
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              child: const Icon(Icons.star, color: Colors.amber),
                            ),
                            title: Text(milestone['title'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat.yMMMd().format(DateTime.parse(milestone['happenedAt']))),
                                if (milestone['notes'] != null && milestone['notes'].toString().isNotEmpty)
                                  Text(milestone['notes'], style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            trailing: milestone['syncStatus'] == 'PENDING'
                                ? const Icon(Icons.cloud_upload, color: Colors.orange, size: 16)
                                : null,
                            isThreeLine: milestone['notes'] != null && milestone['notes'].toString().isNotEmpty,
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'milestones_fab',
        onPressed: () => _showAddMilestoneDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMilestoneDialog({Map? existingMilestone}) {
    final titleController = TextEditingController(text: existingMilestone?['title'] ?? '');
    final notesController = TextEditingController(text: existingMilestone?['notes'] ?? '');
    DateTime selectedDate = existingMilestone != null ? DateTime.parse(existingMilestone['happenedAt']) : DateTime.now();
    bool isSaving = false;
    final isEditing = existingMilestone != null;

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
              Text(isEditing ? 'Edit Milestone' : 'Add Milestone', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title', hintText: 'First smile')),
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
                  if (titleController.text.isEmpty) return;
                  setDialogState(() => isSaving = true);
                  try {
                    final api = ref.read(apiClientProvider);
                    if (isEditing) {
                      await api.updateMilestone(existingMilestone!['id'], {
                        'title': titleController.text,
                        'notes': notesController.text,
                        'happenedAt': selectedDate.toIso8601String(),
                      });
                    } else {
                      if (_babyMonId == null) return;
                      await api.createMilestone(_babyMonId!, {
                        'title': titleController.text,
                        'notes': notesController.text,
                        'happenedAt': selectedDate.toIso8601String(),
                      });
                    }
                    await _fetchMilestones();
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isEditing ? 'Update' : 'Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}