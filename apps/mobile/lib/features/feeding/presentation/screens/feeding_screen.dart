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

class FeedingScreen extends ConsumerStatefulWidget {
  const FeedingScreen({super.key});
  @override
  ConsumerState<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends ConsumerState<FeedingScreen>
    with DataScreenMixin<FeedingScreen> {
  List _feedLogs = [];
  bool _isMetric = true;
  int _feedChartRange = 3;
  String _feedChartUnit = 'Days';
  String? _feedSelectedDate;

  static const _typeColors = {
    'BREASTMILK': AppColors.info,
    'FORMULA': AppColors.warning,
    'SOLID': AppColors.success,
  };
  static const _typeIcons = {
    'BREASTMILK': PhosphorIconsLight.drop,
    'FORMULA': PhosphorIconsLight.jar,
    'SOLID': PhosphorIconsLight.bowlFood,
  };

  // ─────────────────────────────────────────────────
  //  DataScreenMixin overrides
  // ─────────────────────────────────────────────────

  @override
  IconData get emptyIcon => PhosphorIconsLight.bowlFood;

  @override
  String get emptyTitle => 'No feeding logs yet';

  @override
  String get emptySubtitle =>
      'Tap the button below to log your first feeding.';

  @override
  String get emptyActionLabel => 'Log feeding';

  // Listeners are wired manually in initState below (cross-tab signal),
  // so initDataScreen() is intentionally NOT called.
  @override
  int? get listenToTabRefresh => 2;

  @override
  Duration? get refreshCooldown => const Duration(seconds: 10);

  @override
  void onEmptyAction() => _showAddFeedLogDialog();

  /// Fetches feed logs + loads SharedPreferences (isMetric).
  /// Called automatically by [DataScreenMixin.loadData] after BabyMon ID
  /// is resolved, with [babyMonId] already available.
  @override
  Future<void> fetchData() async {
    if (babyMonId == null) return;

    if (mounted) {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      _isMetric = prefs.getBool('isMetric') ?? true;
    }

    final response =
        await ref.read(apiClientProvider).getFeedLogs(babyMonId!);
    _feedLogs = parseItems(response.data);
  }

  // ─────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());

    // Global refresh listener
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) loadData();
    });

    // Tab-specific refresh listener (tab index 2 = Feeding)
    ref.listenManual(tabRefreshProvider(2), (prev, next) {
      if (prev != next) loadData();
    });

    // Cross-tab signal from the Dashboard's InfoFab: open the
    // "Log Feeding" dialog when the action fires, then clear the
    // signal so it doesn't re-open on rebuild.
    ref.listenManual(pendingAddActionProvider, (prev, next) {
      if (next == AddAction.feeding) {
        ref.read(pendingAddActionProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showAddFeedLogDialog();
        });
      }
    });
  }

  // ─────────────────────────────────────────────────
  //  CRUD helpers
  // ─────────────────────────────────────────────────

  Future<bool> _deleteFeedLog(String id, int index) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemType: 'feeding log',
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteFeedLog(id);
      setState(() => _feedLogs.removeAt(index));
      messenger.showSnackBar(const SnackBar(content: Text('Feeding log deleted')));
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }

  String _getUnitForType(String type) {
    if (type == 'SOLID') return 'g';
    return _isMetric ? 'ml' : 'oz';
  }

  // ─────────────────────────────────────────────────
  //  Feeding chart
  // ─────────────────────────────────────────────────

  void _showDayFeedDetails(String dateStr, List dayLogs) {
    final total = dayLogs.fold<double>(
      0,
      (s, l) => s + (double.tryParse(l['amount']?.toString() ?? '0') ?? 0),
    );
    final typeTotals = <String, double>{};
    for (final l in dayLogs) {
      final t = parseString(l['type']) ?? 'BREASTMILK';
      typeTotals[t] =
          (typeTotals[t] ?? 0) +
          (double.tryParse(l['amount']?.toString() ?? '0') ?? 0);
    }
    setState(() => _feedSelectedDate = dateStr);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Feeding \u2014 $dateStr',
          style: TextStyle(
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: ${total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Divider(color: AppColors.border),
              ...typeTotals.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _typeIcons[e.key] ?? PhosphorIconsLight.forkKnife,
                        size: 20,
                        color: _typeColors[e.key],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.key[0]}${e.key.substring(1).toLowerCase()}: ${e.value % 1 == 0 ? e.value.toInt().toString() : e.value.toStringAsFixed(1)}',
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: AppColors.border),
              ...dayLogs.map((l) {
                final amt = double.tryParse(l['amount']?.toString() ?? '0') ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${DateTime.tryParse(l['happenedAt']?.toString() ?? '')?.hour.toString().padLeft(2, '0')}:${DateTime.tryParse(l['happenedAt']?.toString() ?? '')?.minute.toString().padLeft(2, '0') ?? ''} \u2014 ${amt % 1 == 0 ? amt.toInt().toString() : amt.toStringAsFixed(1)} ${_getUnitForType(parseString(l['type']) ?? '')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingChart() {
    if (_feedLogs.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    DateTime cutoff;
    if (_feedChartUnit == 'Days') {
      cutoff = now.subtract(Duration(days: _feedChartRange - 1));
    } else if (_feedChartUnit == 'Weeks') {
      cutoff = now.subtract(Duration(days: _feedChartRange * 7 - 1));
    } else {
      cutoff = DateTime(now.year, now.month - (_feedChartRange - 1), now.day);
    }
    final cutoffMs = cutoff.millisecondsSinceEpoch;
    final dayGroups = <String, List<dynamic>>{};
    for (final log in _feedLogs) {
      final dt = DateTime.tryParse(log['happenedAt']?.toString() ?? '');
      if (dt == null || dt.millisecondsSinceEpoch < cutoffMs) continue;
      final dayKey = DateFormat('yyyy-MM-dd').format(dt);
      dayGroups.putIfAbsent(dayKey, () => []);
      dayGroups[dayKey]!.add(log);
    }
    final allKeys = <String>[];
    var current = cutoff;
    while (!current.isAfter(now)) {
      allKeys.add(DateFormat('yyyy-MM-dd').format(current));
      current = current.add(const Duration(days: 1));
    }
    final feedTypes = ['BREASTMILK', 'FORMULA', 'SOLID'];
    double overallMax = 0;
    final typeData = <String, List<MapEntry<String, double>>>{};
    for (final t in feedTypes) {
      typeData[t] = [];
    }
    for (final k in allKeys) {
      final logs = dayGroups[k] ?? [];
      double dayTotal = 0;
      for (final t in feedTypes) {
        final sum = logs
            .where((l) => (l['type'] ?? 'BREASTMILK') == t)
            .fold<double>(
              0,
              (s, l) =>
                  s + (double.tryParse(l['amount']?.toString() ?? '0') ?? 0),
            );
        typeData[t]!.add(MapEntry(k, sum));
        dayTotal += sum;
      }
      if (dayTotal > overallMax) overallMax = dayTotal;
    }
    if (overallMax == 0) overallMax = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsLight.bowlFood,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'Feeding Chart',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Semantics(
                label: 'Change chart range',
                button: true,
                child: GestureDetector(
                  onTap: () async {
                    final result =
                        await WheelPickerBottomSheet.showCombinedSleepRange(
                      context: context,
                      initialRange: _feedChartRange,
                      initialUnit: _feedChartUnit,
                    );
                    if (result != null) {
                      setState(() {
                        _feedChartRange = result.key;
                        _feedChartUnit = result.value;
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      '$_feedChartRange $_feedChartUnit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: feedTypes
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: (_typeColors[t] ?? AppColors.textCaption)
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t == 'BREASTMILK'
                              ? 'Breast'
                              : (t == 'FORMULA' ? 'Formula' : 'Solid'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(allKeys.length, (di) {
                final dateStr = allKeys[di];
                final date = DateTime.tryParse(dateStr);
                final label =
                    date != null ? DateFormat('d/M').format(date) : dateStr;
                final isSelected = _feedSelectedDate == dateStr;
                final isToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());
                final dayLogs = dayGroups[dateStr] ?? [];
                final dayTotal = dayLogs.fold<double>(
                  0,
                  (s, l) =>
                      s + (double.tryParse(l['amount']?.toString() ?? '0') ?? 0),
                );
                double yOffset = 0;
                return Semantics(
                  label: 'View feed details for $dateStr',
                  button: true,
                  child: GestureDetector(
                    onTap: () => _showDayFeedDetails(dateStr, dayLogs),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            dayTotal % 1 == 0
                                ? '${dayTotal.toInt()}'
                                : dayTotal.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 136,
                            width: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : isToday
                                      ? AppColors.warning.withValues(alpha: 0.12)
                                      : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              children: feedTypes.map((t) {
                                final amount = typeData[t]![di].value;
                                if (amount <= 0) return const SizedBox.shrink();
                                final segHeight =
                                    (amount / overallMax * 136)
                                        .clamp(2.0, 136.0 - yOffset);
                                final segTop = yOffset;
                                yOffset += segHeight;
                                return Positioned(
                                  bottom: segTop,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: segHeight,
                                    decoration: BoxDecoration(
                                      color: (_typeColors[t] ??
                                              AppColors.textCaption)
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (_feedSelectedDate != null)
          Center(
            child: Text(
              'Selected: $_feedSelectedDate \u2014 tap for details',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textCaption,
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: isLoading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: _feedLogs.isEmpty
                        ? buildEmptyState()
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 16),
                            children: [
                              _buildFeedingChart(),
                              const Divider(color: AppColors.border),
                              ..._feedLogs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final log = entry.value;
                                final unit = parseString(log['unit']) ??
                                    _getUnitForType(
                                        parseString(log['type']) ?? '');
                                return ScrollStagger(
                                  index: index,
                                  child: Dismissible(
                                    key: Key(
                                        parseString(log['id']) ??
                                            index.toString()),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) => _deleteFeedLog(
                                        parseString(log['id']) ?? '', index),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding:
                                          const EdgeInsets.only(right: 20),
                                      color: AppColors.error,                                        child: const Icon(
                                        PhosphorIconsLight.trash,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                    child: PremiumCard(
                                      isGlass: true,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: DesignTokens.spaceMd,
                                        vertical: DesignTokens.spaceXs,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.secondary
                                              .withValues(alpha: 0.2),
                                          child: Icon(
                                            log['type'] == 'BREASTMILK'
                                                ? PhosphorIconsLight.drop
                                                : (log['type'] == 'FORMULA'
                                                    ? PhosphorIconsLight.jar
                                                    : PhosphorIconsLight
                                                        .bowlFood),
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        title: Text(
                                            parseString(log['type']) ?? ''),
                                        subtitle: Text(
                                          '${DateFormat.yMMMd().format(DateTime.parse(parseString(log['happenedAt']) ?? ''))}${log['amount'] != null ? ' - ${log['amount']} $unit' : ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                        trailing: log['syncStatus'] == 'PENDING'
                                            ? const Icon(
                                                PhosphorIconsLight.cloudArrowUp,
                                                color: AppColors.warning,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_feeding',
        backgroundColor: AppColors.warning,
        foregroundColor: AppColors.textOnPrimary,
        onPressed: _showAddFeedLogDialog,
        child: const Icon(PhosphorIconsLight.plus),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Add dialog
  // ─────────────────────────────────────────────────

  void _showAddFeedLogDialog() {
    String selectedType = 'BREASTMILK';
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.now();
    double? selectedAmount;
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log Feeding',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'BREASTMILK', label: Text('Breastmilk')),
                  ButtonSegment(value: 'FORMULA', label: Text('Formula')),
                  ButtonSegment(value: 'SOLID', label: Text('Solid')),
                ],
                selected: {selectedType},
                onSelectionChanged: (s) => setDialogState(() {
                  selectedType = s.first;
                  amountController.clear();
                  selectedAmount = null;
                }),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Select feeding amount',
                button: true,
                child: GestureDetector(
                  onTap: () async {
                    final amount =
                        await WheelPickerBottomSheet.showFeedingAmount(
                      context: ctx,
                      feedType: selectedType,
                      isMetric: _isMetric,
                      initialValue: selectedAmount,
                    );
                    if (amount != null) {
                      setDialogState(() {
                        selectedAmount = amount;
                        amountController.text = amount % 1 == 0
                            ? amount.toInt().toString()
                            : amount.toStringAsFixed(1);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Amount (${_getUnitForType(selectedType)})',
                      hintText: _getUnitForType(selectedType),
                      suffixIcon: const Icon(PhosphorIconsLight.caretUp),
                    ),
                    child: Text(
                      selectedAmount != null
                          ? '${selectedAmount! % 1 == 0 ? selectedAmount!.toInt().toString() : selectedAmount!.toStringAsFixed(1)} ${_getUnitForType(selectedType)}'
                          : '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  PhosphorIconsLight.calendar,
                  color: AppColors.primary,
                ),
                title: Text(DateFormat.yMMMd().format(selectedDate)),
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
              ListTile(
                leading: const Icon(
                  PhosphorIconsLight.clock,
                  color: AppColors.primary,
                ),
                title: Text(currentTime.format(ctx)),
                onTap: () async {
                  final picked = await WheelPickerBottomSheet.showTime(
                    context: ctx,
                    initialTime: currentTime,
                  );
                  setDialogState(() => currentTime = picked);
                },
              ),
              const SizedBox(height: 16),
              ThemeButton(
                text: 'Save',
                onPressed: () async {
                  setDialogState(() => isSaving = true);
                  try {
                    final api = ref.read(apiClientProvider);
                    if (babyMonId == null) return;
                    final result = await api.createFeedLog(babyMonId!, {
                      'type': selectedType,
                      'amount': amountController.text.isNotEmpty
                          ? amountController.text
                          : null,
                      'unit': _getUnitForType(selectedType),
                      'notes': notesController.text,
                      'happenedAt': DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        currentTime.hour,
                        currentTime.minute,
                      ).toIso8601String(),
                    });
                    final data = result.data;
                    if (data is Map && data['leveledUp'] == true) {
                      if (ctx.mounted) LevelUpCelebration.show(ctx, parseInt(data['newStage']) ?? 0);
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
                semanticLabel: 'Save feeding log',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
