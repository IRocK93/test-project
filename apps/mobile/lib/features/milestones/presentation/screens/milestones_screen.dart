import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/level_up_celebration.dart';

class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({super.key});

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen>
    with DataScreenMixin<MilestonesScreen> {
  @override
  Duration? get refreshCooldown => const Duration(seconds: 10);

  List _milestones = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) loadData();
    });
    ref.listenManual(tabRefreshProvider(1), (prev, next) {
      if (prev != next) loadData();
    });
    // Cross-tab signal from the Dashboard's InfoFab: open the
    // "Add Milestone" dialog when the action fires, then clear the
    // signal so it doesn't re-open on rebuild.
    ref.listenManual(pendingAddActionProvider, (prev, next) {
      if (next == AddAction.milestone) {
        ref.read(pendingAddActionProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showAddMilestoneDialog();
        });
      }
    });
  }

  @override
  IconData get emptyIcon => PhosphorIconsLight.sparkle;

  @override
  String get emptyTitle => 'No milestones yet';

  @override
  String get emptySubtitle => 'Tap the button below to add your first milestone.';

  @override
  String get emptyActionLabel => 'Add milestone';

  @override
  void onEmptyAction() => _showAddMilestoneDialog();

  @override
  Future<void> fetchData() async {
    final response = await ref.read(apiClientProvider).getMilestones(babyMonId!);
    _milestones = parseItems(response.data);
  }

  Future<bool> _deleteMilestone(String id, int index) async {
    // Capture messenger upfront so we can safely use it after async gaps
    // (avoids `use_build_context_synchronously` warnings if the widget
    // unmounts mid-delete).
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemType: 'milestone',
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteMilestone(id);
      if (mounted) setState(() => _milestones.removeAt(index));
      messenger.showSnackBar(const SnackBar(content: Text('Milestone deleted')));
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }

  List<Map<String, dynamic>> _groupedByMonth() {
    final groups = <String, List<dynamic>>{};
    for (final m in _milestones) {
      final date = DateTime.tryParse(m['happenedAt']?.toString() ?? '');
      final key = date != null ? DateFormat('MMMM yyyy').format(date) : 'Unknown';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(m);
    }
    final sortedKeys = groups.keys.toList()..sort((a, b) {
      final da = DateFormat('MMMM yyyy').parse(a);
      final db = DateFormat('MMMM yyyy').parse(b);
      return db.compareTo(da);
    });
    return sortedKeys.map((k) => {'month': k, 'items': groups[k]!}).toList();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedByMonth();

    return Scaffold(
      body: PremiumBackground(
        child: isLoading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : _milestones.isEmpty
                    ? buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spaceMd,
                      DesignTokens.spaceSm,
                      DesignTokens.spaceMd,
                      100,
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, groupIndex) {
                      final group = grouped[groupIndex];
                      final month = parseString(group['month']) ?? '';
                      final rawItems = group['items'];
                      final items = rawItems is List ? rawItems : <dynamic>[];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: DesignTokens.spaceSm,
                              horizontal: DesignTokens.spaceXs,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 20,
                                  margin: const EdgeInsets.only(right: DesignTokens.spaceSm),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Text(
                                  month,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  '${items.length} ${items.length == 1 ? 'milestone' : 'milestones'}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final milestone = entry.value;
                            final date = DateTime.tryParse(
                                milestone['happenedAt']?.toString() ?? '');
                            return MilestoneTimelineRow(
                              title: parseString(milestone['title']) ?? '',
                              notes: parseString(milestone['notes']),
                              date: date,
                              seed: _milestones.indexOf(milestone),
                              isLast: index == items.length - 1,
                              isPendingSync:
                                  milestone['syncStatus'] == 'PENDING',
                              onTap: () => _showAddMilestoneDialog(
                                  existingMilestone: parseJsonMap(milestone)),
                              onConfirmDelete: () => _deleteMilestone(
                                  parseString(milestone['id']) ?? '', index),
                            );
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                        ],
                      );
                    },
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_milestone',
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        onPressed: _showAddMilestoneDialog,
        child: const Icon(PhosphorIconsLight.plus),
      ),
    );
  }

  // _buildTimelineItem was removed when milestones were migrated to the
  // MilestoneTimelineRow widget (no per-row BackdropFilter, no
  // 7-level-nested ClipRRect wrapping).


  void _showAddMilestoneDialog({Map? existingMilestone}) {
    final titleController = TextEditingController(text: parseString(existingMilestone?['title']) ?? '');
    final notesController = TextEditingController(text: parseString(existingMilestone?['notes']) ?? '');
    DateTime selectedDate = existingMilestone != null ? DateTime.parse(parseString(existingMilestone['happenedAt']) ?? '') : DateTime.now();
    bool isSaving = false;
    final isEditing = existingMilestone != null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: DesignTokens.spaceLg, right: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Milestone' : 'Add Milestone',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'First smile',
                ),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              ListTile(
                leading: const Icon(PhosphorIconsLight.calendar, color: AppColors.primary),
                  title: Text(
                    DateFormat.yMMMd().format(selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              ThemeButton(
                text: isEditing ? 'Update' : 'Save',
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  setDialogState(() => isSaving = true);
                  try {
                    final api = ref.read(apiClientProvider);
                    if (isEditing) {
                      await api.updateMilestone(parseString(existingMilestone['id']) ?? '', {
                        'title': titleController.text,
                        'notes': notesController.text,
                        'happenedAt': selectedDate.toIso8601String(),
                      });
                    } else {
                      if (babyMonId == null) return;
                      final result = await api.createMilestone(babyMonId!, {
                        'title': titleController.text,
                        'notes': notesController.text,
                        'happenedAt': selectedDate.toIso8601String(),
                      });
                      final data = result.data;
                      if (data is Map && data['leveledUp'] == true) {
                        if (ctx.mounted) LevelUpCelebration.show(ctx, parseInt(data['newStage']) ?? 0);
                      }
                    }
                    await loadData(force: true);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (ctx.mounted) showError(ctx, e);
                  }
                },
                isLoading: isSaving,
                fullWidth: true,
                semanticLabel: isEditing ? 'Update milestone' : 'Save milestone',
              ),
              const SizedBox(height: DesignTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
