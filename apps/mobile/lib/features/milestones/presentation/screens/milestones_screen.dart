import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' as semantics;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/features/milestones/domain/entities/milestone.dart';
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
  List<Milestone> _milestones = [];
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
  String get emptyTitle => context.l10n.noMilestones;
  @override
  String get emptySubtitle => context.l10n.noMilestonesSubtitle;
  @override
  String get emptyActionLabel => context.l10n.addMilestone;
  @override
  void onEmptyAction() => _showAddMilestoneDialog();
  @override
  Future<void> fetchData() async {
    final response = await ref.read(apiClientProvider).getMilestones(babyMonId!);
    _milestones = parseItems(response.data).whereType<Map<String, dynamic>>().map(Milestone.fromJson).toList();
  }
  Future<bool> _deleteMilestone(String id, int index) async {
    // Capture messenger and strings upfront so we can safely use them after async gaps
    // (avoids `use_build_context_synchronously` warnings if the widget
    // unmounts mid-delete).
    final messenger = ScaffoldMessenger.of(context);
    final milestoneUndoneText = context.l10n.milestoneUndone;
    final directionality = Directionality.of(context);
    final confirmed =      await ConfirmDeleteDialog.show(
      context,
      itemType: context.l10n.milestoneSingular,
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteMilestone(id);
      if (mounted) {
        final flatIdx = _milestones.indexWhere((m) => m.id == id);
        if (flatIdx != -1) setState(() => _milestones.removeAt(flatIdx));
      }
      ref.read(appRefreshProvider.notifier).state++;
      messenger.showSnackBar(SnackBar(content: Text(milestoneUndoneText)));
      // ignore: deprecated_member_use
      semantics.SemanticsService.announce(milestoneUndoneText, directionality);
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }
  List<({String month, List<Milestone> items})> _groupedByMonth() {
    final groups = <String, List<Milestone>>{};
    for (final m in _milestones) {
      final date = m.happenedAt;        final key = date != null ? DateFormat('MMMM yyyy').format(date) : context.l10n.unknownLabel;
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(m);
    }
    final sortedKeys = groups.keys.toList()..sort((a, b) {
      final da = DateFormat('MMMM yyyy').parse(a);
      final db = DateFormat('MMMM yyyy').parse(b);
      return db.compareTo(da);
    });
    return sortedKeys.map((k) => (month: k, items: groups[k]!)).toList();
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
                    padding: const EdgeInsetsDirectional.only(
                      start: DesignTokens.spaceMd,
                      top: DesignTokens.spaceSm,
                      end: DesignTokens.spaceMd,
                      bottom: 100,
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, groupIndex) {
                      final group = grouped[groupIndex];
                      final month = group.month;
                      final items = group.items;
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
                                  margin: const EdgeInsetsDirectional.only(end: DesignTokens.spaceSm),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary,
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
                                  context.l10n.milestoneCount(items.length, context.l10n.milestoneSingular, context.l10n.milestonePlural),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final m = entry.value;
                            final date = m.happenedAt;
                            return MilestoneTimelineRow(
                              title: m.title,
                              notes: m.notes,
                              date: date,
                              seed: _milestones.indexOf(m),
                              isLast: index == items.length - 1,
                              isPendingSync: m.syncStatus == 'PENDING',
                              onTap: () => _showAddMilestoneDialog(
                                  existingMilestone: m),
                              onConfirmDelete: () => _deleteMilestone(
                                  m.id, index),
                            );
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                        ],
                      );
                    },
                  ),
                ),
              ),
      floatingActionButton: hasBabyMon
          ? Semantics(
              label: context.l10n.addMilestone,
              button: true,
              child: FloatingActionButton(
                heroTag: 'add_milestone',
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                onPressed: _showAddMilestoneDialog,
                child: const Icon(PhosphorIconsLight.plus),
              ),
            )
          : null,
    );
  }
  // _buildTimelineItem was removed when milestones were migrated to the
  // MilestoneTimelineRow widget (no per-row BackdropFilter, no
  // 7-level-nested ClipRRect wrapping).
  void _showAddMilestoneDialog({Milestone? existingMilestone}) {
    final titleController = TextEditingController(text: existingMilestone?.title ?? '');
    final notesController = TextEditingController(text: existingMilestone?.notes ?? '');
    DateTime selectedDate = existingMilestone?.happenedAt ?? DateTime.now();
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
            children: [                  Text(
                isEditing ? context.l10n.editMilestoneTitle : context.l10n.addMilestoneTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.milestoneTitle,
                  hintText: context.l10n.milestoneTitleHint,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: context.l10n.notesOptionalLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              ListTile(
                leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary),
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
                text: isEditing ? context.l10n.updateLabel : context.l10n.saveLabel,
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  setDialogState(() => isSaving = true);
                  try {
                    final api = ref.read(apiClientProvider);
                    if (isEditing) {
                      await api.updateMilestone(existingMilestone.id, {
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
                      // Close dialog immediately
                      if (ctx.mounted) Navigator.pop(ctx);
                      // Optimistic: insert locally
                      final newM = Milestone.fromJson({
                        'id': parseString(result.data['id']) ?? '',
                        'title': titleController.text,
                        'notes': notesController.text,
                        'happenedAt': selectedDate.toIso8601String(),
                      });
                      setState(() => _milestones.insert(0, newM));
                      final data = result.data;
                      if (data is Map && data['leveledUp'] == true) {
                        if (mounted) LevelUpCelebration.show(context, parseInt(data['newStage']) ?? 0);
                      }
                    }
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (ctx.mounted) showError(ctx, e);
                  }
                },
                isLoading: isSaving,
                fullWidth: true,
                semanticLabel: isEditing ? context.l10n.updateMilestoneSemantic : context.l10n.saveMilestoneSemantic,
              ),
              const SizedBox(height: DesignTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
