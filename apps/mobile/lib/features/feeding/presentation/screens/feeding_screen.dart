import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' as semantics;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/features/feeding/domain/entities/feed_log.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/level_up_celebration.dart';
class FeedingScreen extends ConsumerStatefulWidget {
  const FeedingScreen({super.key});
  @override
  ConsumerState<FeedingScreen> createState() => _FeedingScreenState();
}
class _FeedingScreenState extends ConsumerState<FeedingScreen>
    with DataScreenMixin<FeedingScreen> {
  List<FeedLog> _feedLogs = [];
  bool _isMetric = true;
  int _feedChartRange = 7;
  String _feedChartUnit = 'Days';
  String? _feedSelectedDate;
  final _feedChartScrollController = ScrollController();
  final _feedLabelsScrollController = ScrollController();
  VoidCallback? _chartSyncListener;
  bool _chartDidInitialScroll = false;
  double _chartDragStartX = 0;
  double _chartScrollStartOffset = 0;
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
    _feedLogs = parseItems(response.data).whereType<Map<String, dynamic>>().map(FeedLog.fromJson).toList();
    _chartDidInitialScroll = false;
  }
  // ─────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Sync the labels ScrollController to the main chart controller
    _chartSyncListener = () {
      if (_feedLabelsScrollController.hasClients) {
        _feedLabelsScrollController.jumpTo(_feedChartScrollController.offset);
      }
    };
    _feedChartScrollController.addListener(_chartSyncListener!);
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
  @override
  void dispose() {
    if (_chartSyncListener != null) {
      _feedChartScrollController.removeListener(_chartSyncListener!);
    }
    _feedChartScrollController.dispose();
    _feedLabelsScrollController.dispose();
    super.dispose();
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
      ref.read(appRefreshProvider.notifier).state++;
      messenger.showSnackBar(const SnackBar(content: Text('Feeding log deleted')));
      semantics.SemanticsService.announce('Feeding log deleted', ui.TextDirection.ltr);
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }
  // ─────────────────────────────────────────────────
  //  Feeding chart
  // ─────────────────────────────────────────────────
  void _showDayFeedDetails(String dateStr, List<FeedLog> dayLogs) {
    final total = dayLogs.fold<double>(
      0,
      (s, l) => s + (l.amount ?? 0),
    );
    final defaultUnit = _isMetric ? 'ml' : 'oz';
    final typeTotals = <String, double>{};
    for (final l in dayLogs) {
      final t = l.type;
      typeTotals[t] = (typeTotals[t] ?? 0) + (l.amount ?? 0);
    }
    setState(() => _feedSelectedDate = dateStr);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Feeding \u2014 $dateStr',
          style: TextStyle(
            color: isDark ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
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
                'Total: ${total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1)} $defaultUnit',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Divider(color: context.colorScheme.outline),
              ...typeTotals.entries.map(
                (e) {
                  final ft = FeedType.fromApiKey(e.key);
                  final vt = e.value % 1 == 0 ? e.value.toInt().toString() : e.value.toStringAsFixed(1);
                  final tu = ft?.unit(_isMetric) ?? defaultUnit;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          ft?.icon ?? PhosphorIconsLight.forkKnife,
                          size: 20,
                          color: ft?.color,
                        ),
                        const SizedBox(width: DesignTokens.spaceSm),
                        Text(
                          '${ft?.label ?? e.key}: $vt $tu',
                        ),
                      ],
                    ),
                  );
                },
              ),
              Divider(color: context.colorScheme.outline),
              ...dayLogs.map((l) {
                final amt = l.amount ?? 0;
                final lu = l.unit ?? FeedType.fromApiKey(l.type)?.unit(_isMetric) ?? defaultUnit;
                final at = amt % 1 == 0 ? amt.toInt().toString() : amt.toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${l.happenedAt?.hour.toString().padLeft(2, '0')}:${l.happenedAt?.minute.toString().padLeft(2, '0') ?? ''} \u2014 $at $lu',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSm,
                      color: context.colorScheme.onSurfaceVariant,
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
  Widget _buildFeedingChart(BuildContext context) {
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
    final cutoffDate = DateTime(cutoff.year, cutoff.month, cutoff.day);
    final dayGroups = <String, List<FeedLog>>{};
    for (final log in _feedLogs) {
      final dt = log.happenedAt;
      if (dt == null) continue;
      final logDate = DateTime(dt.year, dt.month, dt.day);
      if (logDate.isBefore(cutoffDate)) continue;
      final dayKey = DateFormat('yyyy-MM-dd').format(logDate);
      dayGroups.putIfAbsent(dayKey, () => []);
      dayGroups[dayKey]!.add(log);
    }
    final allKeys = <String>[];
    var current = cutoffDate;
    final todayDate = DateTime(now.year, now.month, now.day);
    while (!current.isAfter(todayDate)) {
      allKeys.add(DateFormat('yyyy-MM-dd').format(current));
      current = current.add(const Duration(days: 1));
    }
    // Filter out days with no entries, unless today (keep it as placeholder)
    final keysWithData = allKeys.where((k) => (dayGroups[k]?.isNotEmpty ?? false) || k == DateFormat('yyyy-MM-dd').format(todayDate)).toList();
    const feedTypes = FeedType.values;
    double overallMax = 0;
    final typeData = <FeedType, List<MapEntry<String, double>>>{};
    for (final t in feedTypes) {
      typeData[t] = [];
    }
    for (final k in keysWithData) {
      final logs = dayGroups[k] ?? [];
      double dayTotal = 0;
      for (final t in feedTypes) {
        final sum = logs
            .where((l) => l.type == t.apiKey)
            .fold<double>(
              0,
              (s, l) => s + (l.amount ?? 0),
            );
        typeData[t]!.add(MapEntry(k, sum));
        dayTotal += sum;
      }
      if (dayTotal > overallMax) overallMax = dayTotal;
    }
    if (overallMax == 0) overallMax = 1.0;
    // ── Y-axis labels: 5 evenly-spaced round numbers ───
    final yStep = _niceStep(overallMax);
    var yMax = (overallMax / yStep).ceil() * yStep;
    if (yMax < overallMax) yMax = (overallMax / yStep).ceil() * yStep + yStep;
    // For small values, ensure the axis is readable
    if (yMax <= 10) yMax = 10;
    const yLabelCount = 5;
    final yLabels = List.generate(yLabelCount, (i) => (yMax * i / (yLabelCount - 1)).round());
    const barHeight = 136.0;
    const barWidth = 56.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg, vertical: 4),
          child: Row(
            children: [
              Icon(
                PhosphorIconsLight.bowlFood,
                size: 16,
                color: context.colorScheme.primary,
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
                      color: Theme.of(context).brightness == Brightness.dark ? context.colorScheme.surface : context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      '$_feedChartRange $_feedChartUnit',
                      style: TextStyle(
                        fontSize: DesignTokens.fontMd,
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
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
          child: Row(
            children: feedTypes
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: DesignTokens.spaceMd),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.shortLabel,
                          style: const TextStyle(
                            fontSize: DesignTokens.font2xs,
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
        const SizedBox(height: DesignTokens.spaceSm),
        // ── Chart body: Y-axis + bars (same height, aligned) ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis
                SizedBox(
                  width: 36,
                  height: barHeight,
                  child: Stack(
                    children: [
                      for (int i = 0; i < yLabelCount; i++)
                        Positioned(
                          bottom: barHeight * i / (yLabelCount - 1) - 8,
                          left: 0, right: 0,
                          child: Text(
                            yLabels[i] % 1000 == 0
                                ? '${yLabels[i] ~/ 1000}k'
                                : yLabels[i].toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 10, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(width: 1, height: barHeight, color: context.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(width: 4),
                // Bars + day totals — wrapped in GestureDetector for swipe
                Expanded(
                  child: SizedBox(
                    height: barHeight + 24,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        controller: _feedChartScrollController,
                        children: List.generate(keysWithData.length, (di) {
                          final dateStr = keysWithData[di];
                          final dayLogs = dayGroups[dateStr] ?? [];
                          final dayTotal = dayLogs.fold<double>(0, (s, l) => s + (l.amount ?? 0));
                          final isSelected = _feedSelectedDate == dateStr;
                          final isToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());
                          final barSegments = <Widget>[];
                          double cumulativeHeight = 0;
                          final entries = feedTypes
                            .map((t) => MapEntry(t, typeData[t]![di].value))
                            .where((e) => e.value > 0)
                            .toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          for (final e in entries) {
                            final h = (e.value / yMax * barHeight).clamp(2.0, barHeight - cumulativeHeight);
                            barSegments.add(Positioned(
                              bottom: cumulativeHeight, left: 0, right: 0,
                              child: Container(height: h, decoration: BoxDecoration(color: e.key.color.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(3))),
                            ));
                            cumulativeHeight += h;
                          }
                          return GestureDetector(
                            onTap: () => _showDayFeedDetails(dateStr, dayLogs),
                            child: Container(
                              width: barWidth,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(dayTotal % 1 == 0 ? '${dayTotal.toInt()}' : dayTotal.toStringAsFixed(1),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.05)
                                          : isToday ? context.colorScheme.tertiary.withValues(alpha: 0.12) : null,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Stack(children: barSegments),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                ),
              ],
            ),
            // ── X-axis line ──
            Padding(
              padding: const EdgeInsets.only(left: 41),
              child: Container(height: 1, color: context.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 2),
            // ── Date labels (separate row, below chart) ──
            Padding(
              padding: const EdgeInsets.only(left: 41),
              child: SizedBox(
                height: 22,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _feedLabelsScrollController,
                  children: List.generate(keysWithData.length, (di) {
                    final dateStr = keysWithData[di];
                    final date = DateTime.tryParse(dateStr);
                    final label = date != null ? DateFormat('d/M').format(date) : dateStr;
                    final isSelected = _feedSelectedDate == dateStr;
                    return SizedBox(
                      width: barWidth,
                      child: Text(label, textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: DesignTokens.fontSm,
                            color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        if (_feedSelectedDate != null)
          Center(
            child: Text(
              'Selected: $_feedSelectedDate \u2014 tap for details',
              style: TextStyle(
                fontSize: DesignTokens.fontSm2,
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        // ── Scroll to today ──
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4, top: 2),
            child: IconButton(
              icon: const Icon(PhosphorIconsLight.calendarDot, size: 18),
              tooltip: 'Scroll to today',
              onPressed: () {
                final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
                final idx = keysWithData.indexOf(todayKey);
                if (idx >= 0 && _feedChartScrollController.hasClients) {
                  _feedChartScrollController.animateTo(
                    idx * (barWidth + 8), // width + horizontal margin
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  /// Returns a "nice" step size for y-axis labels (10, 20, 50, 100, 200, 500, 1000).
  double _niceStep(double maxVal) {
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    if (maxVal <= 250) return 50;
    if (maxVal <= 500) return 100;
    if (maxVal <= 1000) return 200;
    if (maxVal <= 2000) return 500;
    return 1000;
  }
  // ─────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Auto-scroll feeding chart to today on first data load
    if (!_chartDidInitialScroll && _feedLogs.isNotEmpty) {
      _chartDidInitialScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_feedChartScrollController.hasClients) {
          final max = _feedChartScrollController.position.maxScrollExtent;
          if (max > 0) _feedChartScrollController.jumpTo(max);
        }
      });
    }
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
                            padding: const EdgeInsets.only(bottom: DesignTokens.spaceLg),
                            children: [
                              _buildFeedingChart(context),
                              Divider(color: context.colorScheme.outline),
                              ..._feedLogs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final log = entry.value;
                                final unit = log.unit ?? (FeedType.fromApiKey(log.type)?.unit(_isMetric) ?? (_isMetric ? 'ml' : 'oz'));
                                final feedColor = FeedType.fromApiKey(log.type)?.color ?? context.colorScheme.secondary;
                                return ScrollStagger(
                                  index: index,
                                  child: Dismissible(
                                    key: Key(
                                        log.id.isNotEmpty ? log.id : index.toString()),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) => _deleteFeedLog(
                                        log.id, index),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding:
                                          const EdgeInsets.only(right: 20),
                                      color: context.colorScheme.error,                                        child: Icon(
                                        PhosphorIconsLight.trash,
                                        color: context.colorScheme.onPrimary,
                                      ),
                                    ),
                                    child: PremiumCard(
                                      isGlass: true,
                                      onTap: () => _showEditFeedLogDialog(log, index),
                                      backgroundColor: feedColor.withValues(alpha: 0.08),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: DesignTokens.spaceSm,
                                        vertical: 1,
                                      ),
                                      child: Semantics(
                                        label: '${FeedType.fromApiKey(log.type)?.label ?? log.type} feeding${log.amount != null ? ', ${log.amount} $unit' : ''}${log.happenedAt != null ? ', ${DateFormat.yMMMd().format(log.happenedAt!)}' : ''}',
                                        button: true,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: DesignTokens.spaceSm,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: feedColor.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  FeedType.fromApiKey(log.type)?.icon ?? PhosphorIconsLight.bowlFood,
                                                  size: 16,
                                                  color: feedColor,
                                                ),
                                              ),
                                              const SizedBox(width: DesignTokens.spaceSm),
                                              Expanded(
                                                child: Text(
                                                  FeedType.fromApiKey(log.type)?.label ?? log.type,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: feedColor,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${log.happenedAt != null ? '${DateFormat('MMM d, h:mm a').format(log.happenedAt!)}' : '--:--'}${log.amount != null ? '  ·  ${(log.amount! % 1 == 0) ? log.amount!.toInt().toString() : log.amount!.toStringAsFixed(1)} $unit' : ''}',
                                                style: TextStyle(
                                                  fontSize: DesignTokens.fontSm,
                                                  color: context.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              if (log.syncStatus == 'PENDING')
                                                Padding(
                                                  padding: const EdgeInsets.only(left: DesignTokens.spaceXs),
                                                  child: Icon(
                                                    PhosphorIconsLight.cloudArrowUp,
                                                    color: context.colorScheme.tertiary,
                                                    size: 14,
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: DesignTokens.spaceXs),
                                                child: Icon(PhosphorIconsLight.pencilSimple, size: 16, color: context.colorScheme.primary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ),
                                  ),
                                );
                              }),
                            ],
                          ),
                  ),
      ),
      floatingActionButton: hasBabyMon
          ? Semantics(
              label: 'Log feeding',
              button: true,
              child: FloatingActionButton(
                heroTag: 'add_feeding',
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                onPressed: _showAddFeedLogDialog,
                child: const Icon(PhosphorIconsLight.plus),
              ),
            )
          : null,
    );
  }
  // ─────────────────────────────────────────────────
  //  Add dialog
  // ─────────────────────────────────────────────────
  void _showAddFeedLogDialog() {
    FeedType selectedType = FeedType.breastmilk;
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.now();
    double? selectedAmount;
    bool isSaving = false;
    String? validationError;
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
              const SizedBox(height: DesignTokens.spaceLg),
              SegmentedButton<FeedType>(
                segments: FeedType.values.map((ft) =>
                  ButtonSegment(value: ft, label: Text(ft.label)),
                ).toList(),
                selected: {selectedType},
                onSelectionChanged: (s) => setDialogState(() {
                  selectedType = s.first;
                  amountController.clear();
                  selectedAmount = null;
                  validationError = null;
                }),
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              Semantics(
                label: 'Select feeding amount',
                button: true,
                child: GestureDetector(
                  onTap: () async {
                    final amount =
                        await WheelPickerBottomSheet.showFeedingAmount(
                      context: ctx,
                      feedType: selectedType.apiKey,
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
                      labelText: 'Amount (${selectedType.unit(_isMetric)})',
                      hintText: selectedType.unit(_isMetric),
                      suffixIcon: const Icon(PhosphorIconsLight.caretUp),
                    ),
                    child: Text(
                      selectedAmount != null
                          ? '${selectedAmount! % 1 == 0 ? selectedAmount!.toInt().toString() : selectedAmount!.toStringAsFixed(1)} ${selectedType.unit(_isMetric)}'
                          : '',
                      style: const TextStyle(fontSize: DesignTokens.fontLg),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              ListTile(
                leading: Icon(
                  PhosphorIconsLight.calendar,
                  color: context.colorScheme.primary,
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
                leading: Icon(
                  PhosphorIconsLight.clock,
                  color: context.colorScheme.primary,
                ),
                title: Text(currentTime.format(ctx)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: currentTime,
                  );
                  if (picked != null) setDialogState(() => currentTime = picked);
                },
              ),
              const SizedBox(height: DesignTokens.spaceLg),                  if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                  child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
                ),
              ThemeButton(
                text: 'Save',
                onPressed: () async {
                  if (selectedAmount == null || selectedAmount! <= 0) {
                    setDialogState(() => validationError = 'Please select a feeding amount');
                    return;
                  }
                  setDialogState(() { validationError = null; isSaving = true; });
                  try {
                    final api = ref.read(apiClientProvider);
                    if (babyMonId == null) return;
                    final result = await api.createFeedLog(babyMonId!, {
                      'type': selectedType.apiKey,
                      'amount': selectedAmount,
                      'unit': selectedType.unit(_isMetric),
                      'notes': notesController.text,
                      'happenedAt': DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        currentTime.hour,
                        currentTime.minute,
                      ).toIso8601String(),
                    });
                    // Close dialog immediately
                    if (context.mounted) Navigator.pop(ctx);
                    // Optimistic: insert at top of local list
                    final newLog = FeedLog.fromJson({
                      'id': parseString(result.data['id']) ?? '',
                      'type': selectedType.apiKey,
                      'amount': selectedAmount,
                      'unit': selectedType.unit(_isMetric),
                      'notes': notesController.text,
                      'happenedAt': DateTime(selectedDate.year, selectedDate.month, selectedDate.day, currentTime.hour, currentTime.minute).toIso8601String(),
                    });
                    setState(() => _feedLogs.insert(0, newLog));
                    // Level-up celebration
                    final data = result.data;
                    if (data is Map && data['leveledUp'] == true) {
                      if (mounted) LevelUpCelebration.show(context, parseInt(data['newStage']) ?? 0);
                    }
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (context.mounted) showError(ctx, e);
                  }
                },
                isLoading: isSaving,
                fullWidth: true,
                semanticLabel: 'Save feeding log',
              ),
              const SizedBox(height: DesignTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
  void _showEditFeedLogDialog(FeedLog log, int index) {
    if (babyMonId == null) return;
    final type = FeedType.fromApiKey(log.type) ?? FeedType.values.first;
    FeedType selectedType = type;
    double? selectedAmount = log.amount;
    final notesController = TextEditingController(text: log.notes ?? '');
    DateTime logDate = log.happenedAt ?? DateTime.now();
    TimeOfDay logTime = log.happenedAt != null ? TimeOfDay.fromDateTime(log.happenedAt!) : TimeOfDay.now();
    final api = ref.read(apiClientProvider);
    bool isSaving = false;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: DesignTokens.spaceLg, right: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Edit Feeding', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: DesignTokens.spaceLg),
        SegmentedButton<FeedType>(
          segments: FeedType.values.map((ft) => ButtonSegment(value: ft, label: Text(ft.label))).toList(),
          selected: {selectedType},
          onSelectionChanged: (s) => setD(() => selectedType = s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        Row(children: [
          Expanded(child: ListTile(leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary), title: Text(DateFormat('MMM d, yyyy').format(logDate)), dense: true,
            onTap: () async { final p = await showDatePicker(context: ctx, initialDate: logDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => logDate = p); })),
          Expanded(child: ListTile(leading: Icon(PhosphorIconsLight.clock, color: context.colorScheme.primary), title: Text(logTime.format(ctx)), dense: true,
            onTap: () async { final t = await showTimePicker(context: ctx, initialTime: logTime); if (t != null) setD(() => logTime = t); })),
        ]),
        const SizedBox(height: DesignTokens.spaceMd),
        GestureDetector(
          onTap: () async { final a = await WheelPickerBottomSheet.showFeedingAmount(context: ctx, feedType: selectedType.apiKey, isMetric: _isMetric); if (a != null) setD(() => selectedAmount = a); },
          child: Container(padding: const EdgeInsets.all(DesignTokens.spaceMd), decoration: BoxDecoration(border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
            child: Text(selectedAmount != null ? '${(selectedAmount! % 1 == 0) ? selectedAmount!.toInt() : selectedAmount!.toStringAsFixed(1)} ${selectedType.unit(_isMetric)}' : 'Tap to set amount', style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600))),
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
        const SizedBox(height: DesignTokens.spaceLg),
        Row(children: [
          Expanded(child: ThemeButton(text: 'Delete', onPressed: () async {
            final c = await ConfirmDeleteDialog.show(ctx, title: 'Delete Feed Log'); if (c != true) return;
            try { await api.deleteFeedLog(log.id); setState(() => _feedLogs.removeAt(index)); ref.read(appRefreshProvider.notifier).state++; if (ctx.mounted) Navigator.pop(ctx); }
            catch (e) { if (ctx.mounted) showError(ctx, e); }
          }, variant: ThemeButtonVariant.outlined, foregroundColor: context.colorScheme.error, fullWidth: true)),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(child: ThemeButton(text: 'Save', onPressed: () async {
            setD(() => isSaving = true);
            try {
              await api.updateFeedLog(log.id, {
                'type': selectedType.apiKey, 'amount': selectedAmount?.toString(), 'unit': selectedType.unit(_isMetric),
                'happenedAt': DateTime(logDate.year, logDate.month, logDate.day, logTime.hour, logTime.minute).toIso8601String(),
                'notes': notesController.text.isNotEmpty ? notesController.text : null,
              });
              ref.read(appRefreshProvider.notifier).state++; if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) { setD(() => isSaving = false); if (ctx.mounted) showError(ctx, e); }
          }, isLoading: isSaving, fullWidth: true)),
        ]), const SizedBox(height: DesignTokens.spaceSm),
      ]),
    )));
  }
}