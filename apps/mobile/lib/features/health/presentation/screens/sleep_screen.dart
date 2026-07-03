import 'package:flutter/material.dart';
// ignore_for_file: unused_element
import 'package:flutter/semantics.dart' as semantics;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/features/health/domain/entities/sleep_log.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});
  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}
class _SleepScreenState extends ConsumerState<SleepScreen>
    with DataScreenMixin<SleepScreen> {
  @override
  bool get autoInit => true;
  @override
  int? get listenToTabRefresh => 4;
  @override
  Duration? get refreshCooldown => const Duration(seconds: 3);
  List<SleepLog> _sleepLogs = [];
  DateTime _selectedDate = DateTime.now();
  static const _qualities = SleepQuality.values;
  int _chartRange = 7;
  String _chartUnit = 'Days';
  String? _selectedBarDate;
  final _chartScrollController = ScrollController();
  double _chartDragStartX = 0;
  double _chartScrollStartOffset = 0;
  @override
  Future<void> fetchData() async {
    final response = await ref.read(apiClientProvider).getSleepLogs(babyMonId!);
    _sleepLogs = parseItemsTyped(response.data).map(SleepLog.fromJson).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chartScrollController.hasClients) {
        final maxScroll = _chartScrollController.position.maxScrollExtent;
        if (maxScroll > 0) _chartScrollController.jumpTo(maxScroll);
      }
    });
  }
  Future<bool> _deleteLog(String id, int index) async {
    // Capture messenger and strings upfront so we can safely use them after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final sleepLogDeletedText = context.l10n.sleepLogDeleted;
    final directionality = Directionality.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: context.l10n.sleepLogDeleteTitle,
      message: context.l10n.sleepLogDeleteMessage,
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteSleepLog(babyMonId!, id);
      setState(() => _sleepLogs.removeAt(index));
      ref.read(appRefreshProvider.notifier).state++;
      messenger.showSnackBar(SnackBar(content: Text(sleepLogDeletedText)));
      // ignore: deprecated_member_use
      semantics.SemanticsService.announce(sleepLogDeletedText, directionality);
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }
  /// Format a [DateTime] as a local date string (yyyy-MM-dd).
  String _dateStr(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  List<SleepLog> _logsForSelectedDate() {
    final dateStr = _dateStr(_selectedDate);
    return _sleepLogs.where((log) =>
        log.startTime != null && _dateStr(log.startTime!) == dateStr).toList();
  }
  List<({String date, List<SleepLog> logs, double totalMinutes})> _sleepLogsByDay() {
    final now = DateTime.now();
    DateTime cutoff;
    if (_chartUnit == 'Days') {
      cutoff = now.subtract(Duration(days: _chartRange - 1));
    } else if (_chartUnit == 'Weeks') {
      cutoff = now.subtract(Duration(days: _chartRange * 7 - 1));
    } else {
      cutoff = DateTime(now.year, now.month - (_chartRange - 1), now.day);
    }
    final cutoffMs = cutoff.millisecondsSinceEpoch;
    final dayGroups = <String, List<SleepLog>>{};
    for (final log in _sleepLogs) {
      final start = log.startTime;
      if (start == null || start.millisecondsSinceEpoch < cutoffMs) continue;
      final dayKey = _dateStr(start);
      dayGroups.putIfAbsent(dayKey, () => []);
      dayGroups[dayKey]!.add(log);
    }
    final allDays = <String, List<SleepLog>>{};
    var current = cutoff;
    while (!current.isAfter(now)) {
      final key = _dateStr(current);
      allDays[key] = dayGroups[key] ?? [];
      current = current.add(const Duration(days: 1));
    }
    return allDays.entries.map((e) => (
      date: e.key,
      logs: e.value,
      totalMinutes: e.value.fold(0.0, (sum, log) {
        return sum + (log.duration?.inMinutes.toDouble() ?? 0.0);
      }),
    )).toList();
  }
  ({int totalMinutes, int naps, double avgQuality, int count}) _dailySummary(List<SleepLog> logs) {
    int totalMinutes = 0, naps = 0;
    for (final log in logs) {
      final start = log.startTime; final end = log.endTime;
      if (start != null && end != null) { totalMinutes += end.difference(start).inMinutes; if (end.difference(start).inHours < 4 && start.hour >= 6 && start.hour < 20) naps++; }
    }
    final avgQuality = logs.isNotEmpty ? logs.map((l) => SleepQuality.resolve(l.quality).avgScoreValue).reduce((a, b) => a + b) / logs.length : 0.0;
    return (totalMinutes: totalMinutes, naps: naps, avgQuality: avgQuality, count: logs.length);
  }
  String _formatDuration(String? s, String? e) { final sd = DateTime.tryParse(s ?? ''), ed = DateTime.tryParse(e ?? ''); if (sd == null || ed == null) return ''; final d = ed.difference(sd); return d.inHours > 0 ? '${d.inHours}h ${d.inMinutes.remainder(60)}m' : '${d.inMinutes}m'; }
  String _formatTime(String? iso) { final dt = DateTime.tryParse(iso ?? ''); return dt == null ? '' : DateFormat('HH:mm').format(dt); }
  Widget _buildTimelineChart() {
    final days = _sleepLogsByDay();
    const hourHeight = 28.0;
    const dayWidth = 120.0;
    const topLabelHeight = 24.0;
    const leftLabelWidth = 44.0;
    const totalHours = 24;
    const intervalHours = 2;
    const numSlots = totalHours ~/ intervalHours;
    const chartHeight = numSlots * hourHeight + 8;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg, vertical: 4),
        child: Row(children: [
          Icon(PhosphorIconsLight.moon, size: 16, color: context.colorScheme.primary),
          const SizedBox(width: 6),
          Text(context.l10n.sleepTimelineTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Semantics(
            label: context.l10n.changeChartRange,
            button: true,
            child: GestureDetector(
            onTap: () async {
              final result = await WheelPickerBottomSheet.showCombinedSleepRange(
                context: context,
                initialRange: _chartRange,
                initialUnit: _chartUnit,
              );
              if (result != null) setState(() { _chartRange = result.key; _chartUnit = result.value; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? context.colorScheme.surface : context.colorScheme.surface, borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
              child: Text('$_chartRange $_chartUnit', style: TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            ),
          ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Padding(padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg), child: Row(children: _qualities.map((q) => Padding(padding: const EdgeInsets.only(right: DesignTokens.spaceMd), child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: q.color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),                        Text(_qualityLabel(q), style: const TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w500)),
      ]))).toList())),
      const SizedBox(height: DesignTokens.spaceSm),
      SizedBox(
        height: chartHeight + topLabelHeight + 16,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Column(children: List.generate(numSlots, (si) {
              final hour = (numSlots - 1 - si) * intervalHours;
              return Container(                                  width: leftLabelWidth, height: hourHeight, alignment: AlignmentDirectional.centerEnd, padding: const EdgeInsetsDirectional.only(end: 4),                                child: Text('${hour.toString().padLeft(2, '0')}:00', style: TextStyle(fontSize: DesignTokens.fontSm, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
              );
            })),
            const SizedBox(height: topLabelHeight),
          ]),
          Expanded(
            child: GestureDetector(
              onHorizontalDragStart: (d) {
                _chartDragStartX = d.globalPosition.dx;
                _chartScrollStartOffset = _chartScrollController.offset;
              },
              onHorizontalDragUpdate: (d) {
                final dx = _chartDragStartX - d.globalPosition.dx;
                final newOffset = (_chartScrollStartOffset + dx).clamp(
                  0.0,
                  _chartScrollController.position.maxScrollExtent,
                );
                _chartScrollController.jumpTo(newOffset);
              },
              child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              controller: _chartScrollController,
              child: Column(children: [
                SizedBox(
                  height: chartHeight,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(days.length, (di) {
                    final day = days[di];
                    final dateStr = day.date;
                    final logs = day.logs;
                    final isSelected = _selectedBarDate == dateStr;
                    return Semantics(
                      label: '${context.l10n.viewSleepDetailsFor} $dateStr',
                      button: true,
                      child: GestureDetector(
                      onTap: () => _showDaySleepDetails(day),
                      child: Container(
                        width: dayWidth, height: chartHeight,
                        decoration: BoxDecoration(
                          color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.05) : null,
                          border: Border(right: BorderSide(color: context.colorScheme.outline.withValues(alpha: DesignTokens.opacityDim))),
                        ),
                        child: Stack(children: [
                          ...List.generate(numSlots + 1, (si) => Positioned(
                            top: si * hourHeight - 0.5, left: 0, right: 0,
                            child: Container(height: 1, color: context.colorScheme.outline.withValues(alpha: DesignTokens.opacityDim)),
                          )),
                          ...logs.map((log) {
                            final start = log.startTime;
                            final end = log.endTime;
                            if (start == null || end == null) return const SizedBox.shrink();
                            final endMin = (end.hour * 60 + end.minute).clamp(0, 24 * 60);
                            final durationMin = endMin - (start.hour * 60 + start.minute);
                            const slotMin = intervalHours * 60.0;
                            final topPos = chartHeight - (endMin / slotMin * hourHeight);
                            final barHeight = (durationMin / slotMin * hourHeight).clamp(0.0, (chartHeight - topPos).clamp(2.0, chartHeight));
                            final q = SleepQuality.resolve(log.quality);
                            final startStr = _formatTime(log.startTime?.toIso8601String());
                            final endStr = _formatTime(log.endTime?.toIso8601String());
                            final dur = _formatDuration(log.startTime?.toIso8601String(), log.endTime?.toIso8601String());
                            return Positioned(
                              top: topPos, left: 2, right: 2,
                              child: Semantics(
                                label: '${_nightOrNapLabel(SleepType.fromApiKey(log.type) ?? SleepType.night)} $startStr to $endStr, $dur, ${context.l10n.sleepQuality}: ${_qualityLabel(q)}',
                                button: true,
                                child: GestureDetector(
                                  onTap: () => _showEditSleepDialog(log),
                                  child: Container(
                                    height: barHeight,
                                    decoration: BoxDecoration(color: q.color, borderRadius: BorderRadius.circular(3)),
                                    alignment: Alignment.center,
                                    child: barHeight > 18
                                        ? Text('$startStr-$endStr',
                                            style: TextStyle(color: context.colorScheme.onPrimary, fontSize: DesignTokens.fontXs, fontWeight: FontWeight.w600))
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ]),
                      ),
                    ),
                    );
                  })),
                ),
                SizedBox(
                  height: topLabelHeight,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(days.length, (di) {
                    final day = days[di];
                    final dateStr = day.date;
                    final date = DateTime.tryParse('${dateStr}T12:00:00Z'); // parse as UTC noon
                    final label = date != null ? DateFormat('d MMM').format(date) : dateStr;
                    final isToday = dateStr == _dateStr(DateTime.now());
                    final isSelected = _selectedBarDate == dateStr;
                    return Semantics(
                      label: '${context.l10n.viewSleepDetailsFor} $dateStr',
                      button: true,
                      child: GestureDetector(
                      onTap: () => _showDaySleepDetails(day),
                      child: Container(
                        width: dayWidth, height: topLabelHeight, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.1) : (isToday ? context.colorScheme.tertiary.withValues(alpha: 0.12) : null),
                          border: Border(top: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.5))),
                        ),
                        child: Text(label, style: TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600, color: isToday ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant)),
                      ),
                    ),
                  );
                })),
                ),
              ]),
            ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      if (_selectedBarDate != null) Center(child: Text(context.l10n.selectedDateTapForDetails(_selectedBarDate!), style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)))),
    ]);
  }
  void _showDaySleepDetails(({String date, List<SleepLog> logs, double totalMinutes}) day) {
    final dateStr = day.date;
    final logs = day.logs;
    final totalMin = day.totalMinutes.toInt();
    setState(() => _selectedBarDate = dateStr);
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('${context.l10n.sleep} \u2014 $dateStr'),
      content: SizedBox(width: double.maxFinite, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${context.l10n.feedDayTotal}: ${totalMin ~/ 60}h ${totalMin % 60}m | ${logs.length} ${context.l10n.sleepSessions}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const Divider(),
        ...logs.map((log) {
          final q = SleepQuality.resolve(log.quality);
          return Dismissible(
            key: Key(log.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              final confirmed = await ConfirmDeleteDialog.show(ctx, title: context.l10n.sleepLogDeleteTitle, message: context.l10n.sleepLogDeleteMessage);
              if (confirmed == true) {
                final idx = _sleepLogs.indexWhere((l) => l.id == log.id);
                if (idx != -1) {
                  try {
                    await ref.read(apiClientProvider).deleteSleepLog(babyMonId!, log.id);
                    setState(() => _sleepLogs.removeAt(idx));
                    ref.read(appRefreshProvider.notifier).state++;
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.sleepLogDeleted)));
                  } catch (e) { if (ctx.mounted) showError(ctx, e); }
                }
              }
              return false; // we handle it ourselves
            },
            background: Container(
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsetsDirectional.only(end: 16),
              color: context.colorScheme.error,
              child: Icon(PhosphorIconsLight.trash, color: context.colorScheme.onPrimary),
            ),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: q.color, shape: BoxShape.circle)),
              title: Text('${_formatTime(log.startTime?.toIso8601String())} \u2192 ${_formatTime(log.endTime?.toIso8601String())}', style: const TextStyle(fontSize: DesignTokens.fontSm)),
              subtitle: Text('${_formatDuration(log.startTime?.toIso8601String(), log.endTime?.toIso8601String())}  ·  ${_qualityLabel(q)}', style: TextStyle(fontSize: DesignTokens.font2xs, color: q.color)),
              trailing: IconButton(
                icon: Icon(PhosphorIconsLight.pencilSimple, size: 18, color: context.colorScheme.primary),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showEditSleepDialog(log);
                },
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showEditSleepDialog(log);
              },
            ),
          );
        }),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.close))],
    ));
  }
  @override
  Widget build(BuildContext context) {
    final logs = _logsForSelectedDate();
    final summary = _dailySummary(logs);
    return Scaffold(
      appBar: ScreenHeader(
        title: context.l10n.sleep,
        onBack: () => context.pop(),
      ),
      body: PremiumBackground(
        child: isLoading
          ? buildLoading()
          : !hasBabyMon
              ? buildNoBabyMon()
              : RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
              color: context.colorScheme.surface.withValues(alpha: 0.5),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ThemeButton.icon(icon: PhosphorIconsLight.caretLeft, onPressed: () => setState(() { _selectedDate = _selectedDate.subtract(const Duration(days: 1)); }), semanticLabel: context.l10n.previousDay, variant: ThemeButtonVariant.text),
                Text(_selectedDate.day == DateTime.now().day && _selectedDate.month == DateTime.now().month && _selectedDate.year == DateTime.now().year ? '${context.l10n.today} - ${DateFormat('MMM d').format(_selectedDate)}' : DateFormat('EEEE, MMM d').format(_selectedDate),        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ThemeButton.icon(icon: PhosphorIconsLight.caretRight, onPressed: () => setState(() { _selectedDate = _selectedDate.add(const Duration(days: 1)); }), semanticLabel: context.l10n.nextDay, variant: ThemeButtonVariant.text),
              ]),
            ),
            PremiumCard(
              isGlass: true,
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
              margin: const EdgeInsets.fromLTRB(DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, DesignTokens.spaceXs),
              child: Padding(padding: const EdgeInsets.all(DesignTokens.spaceLg),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _summaryStat('${summary.totalMinutes ~/ 60}h ${summary.totalMinutes % 60}m', context.l10n.totalSleep),
                _summaryStat('${summary.naps}', context.l10n.nap),
                _summaryStat(_qualityLabelText(summary.avgQuality), context.l10n.averageLabel),
                _summaryStat('${summary.count}', context.l10n.entriesLabel),
              ])),
            ),
            _buildTimelineChart(),
            ])),
          ],
        ),
      ),
            ),
      floatingActionButton: hasBabyMon
          ? Semantics(
              label: context.l10n.addSleepLogSemantic,
              button: true,
              child: FloatingActionButton(
                heroTag: 'add_sleep',
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                onPressed: _showAddSleepDialog,
                child: const Icon(PhosphorIconsLight.moon),
              ),
            )
          : null,
    );
  }
  String _sleepTypeLabel(SleepLog log) {
    final start = log.startTime; final end = log.endTime;
    if (start == null || end == null) return context.l10n.sleep;
    final duration = end.difference(start);
    if (duration.inHours >= 4) return _nightOrNapLabel(SleepType.night);
    if (start.hour >= 20 || start.hour < 6) return _nightOrNapLabel(SleepType.night);
    return _nightOrNapLabel(SleepType.nap);
  }
  String _nightOrNapLabel(SleepType t) {
    switch (t) {
      case SleepType.night: return context.l10n.nightSleepLabel;
      case SleepType.nap: return context.l10n.napLabel;
    }
  }
  String _qualityLabel(SleepQuality q) {
    switch (q) {
      case SleepQuality.great: return context.l10n.greatQualityLabel;
      case SleepQuality.good: return context.l10n.goodQualityLabel;
      case SleepQuality.fair: return context.l10n.fairQualityLabel;
      case SleepQuality.poor: return context.l10n.poorQualityLabel;
    }
  }
  String _qualityLabelText(double s) => s >= 0.5 ? _qualityLabel(SleepQuality.fromScore(s)) : context.l10n.notAvailableAbbr;
  Widget _summaryStat(String v, String l) { return Column(children: [Text(v, style: TextStyle(fontSize: DesignTokens.fontLg2, fontWeight: FontWeight.bold, color: context.colorScheme.onSurface)), Text(l, style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), height: 1.4))]); }
  void _showAddSleepDialog() {
    if (babyMonId == null) return;
    final now = DateTime.now();
    DateTime sleepDate = _selectedDate;
    DateTime startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, now.hour, 0);
    DateTime? endTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, now.hour, 0);
    SleepQuality selectedQuality = SleepQuality.good; final notesController = TextEditingController();
    bool isStillSleeping = false, isSaving = false;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => Padding(
      padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, start: DesignTokens.spaceLg, end: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.l10n.logSleepTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: DesignTokens.spaceLg),
        ListTile(leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary),        title: Text(context.l10n.selectDate, style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? context.colorScheme.onPrimary : context.colorScheme.onSurface)),  subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(sleepDate)),
          onTap: () async { final p = await showDatePicker(context: ctx, initialDate: sleepDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1))); if (p != null) setD(() { sleepDate = p; startTime = DateTime(p.year, p.month, p.day, startTime.hour, startTime.minute); if (endTime != null) endTime = DateTime(p.year, p.month, p.day, endTime!.hour, endTime!.minute); }); }),
        ListTile(leading: Icon(PhosphorIconsLight.moon, color: context.colorScheme.primary),        title: Text(context.l10n.sleepStart, style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? context.colorScheme.onPrimary : context.colorScheme.onSurface)), subtitle: Text(DateFormat('hh:mm a').format(startTime)),
          onTap: () async { final tod = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(startTime)); if (tod != null && ctx.mounted) setD(() { startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, tod.hour, tod.minute); }); }),
        SwitchListTile(secondary: Icon(PhosphorIconsLight.sun, color: context.colorScheme.primary), title: Text(context.l10n.stillSleeping), value: isStillSleeping, onChanged: (v) => setD(() { isStillSleeping = v; if (v) endTime = null; })),
        if (!isStillSleeping) ListTile(leading: Icon(PhosphorIconsLight.sun, color: context.colorScheme.primary), title: Text(context.l10n.endTime), subtitle: Text(DateFormat('hh:mm a').format(endTime!)),
          onTap: () async { final tod = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(endTime!)); if (tod != null && ctx.mounted) setD(() { endTime = DateTime(endTime!.year, endTime!.month, endTime!.day, tod.hour, tod.minute); }); }),
        const SizedBox(height: DesignTokens.spaceMd),
        Wrap(spacing: DesignTokens.spaceSm, children: _qualities.map((q) => ChoiceChip(label: Text(_qualityLabel(q)), selected: selectedQuality == q, selectedColor: q.color.withValues(alpha: DesignTokens.opacityDim), onSelected: (_) => setD(() => selectedQuality = q))).toList()),
        const SizedBox(height: DesignTokens.spaceMd),
        TextField(controller: notesController, decoration: InputDecoration(labelText: context.l10n.notesOptionalLabel), maxLines: 2), const SizedBox(height: DesignTokens.spaceLg),
        ThemeButton(text: context.l10n.save, onPressed: () async {
          setD(() => isSaving = true);
          try {
            final ee = isStillSleeping ? DateTime.now() : endTime;
            final dur = ee?.difference(startTime) ?? const Duration(hours: 1);
            final t = (dur.inHours < 4 && startTime.hour >= 6 && startTime.hour < 20) ? SleepType.nap.apiKey : SleepType.night.apiKey;
            final result = await ref.read(apiClientProvider).createSleepLog(babyMonId!, {
              'type': t, 'startTime': startTime.toIso8601String(),
              'endTime': (ee ?? DateTime.now()).toIso8601String(),
              'quality': selectedQuality.apiNumericValue,
              'notes': notesController.text.isNotEmpty ? notesController.text : null,
            });
            // Close dialog immediately
            if (ctx.mounted) Navigator.pop(ctx);
            // Optimistic: insert locally
            final newLog = SleepLog.fromJson({
              'id': parseString(result.data['id']) ?? '',
              'type': t,
              'startTime': startTime.toIso8601String(),
              'endTime': (ee ?? DateTime.now()).toIso8601String(),
              'quality': selectedQuality.apiNumericValue,
              'notes': notesController.text.isNotEmpty ? notesController.text : null,
            });
            setState(() => _sleepLogs.insert(0, newLog));
          } catch (e) { setD(() => isSaving = false); if (ctx.mounted) showError(ctx, e); }
        }, isLoading: isSaving, fullWidth: true, semanticLabel: context.l10n.saveSleepLogSemantic),
      ]),
    )));
  }
  void _showEditSleepDialog(SleepLog log) {
    if (babyMonId == null) return;
    DateTime sleepDate = log.startTime ?? DateTime.now();
    DateTime startTime = log.startTime ?? DateTime.now();
    DateTime? endTime = log.endTime;
    SleepQuality selectedQuality = SleepQuality.resolve(log.quality);
    final notesController = TextEditingController(text: log.notes ?? '');
    bool isStillSleeping = log.endTime == null;
    bool isSaving = false;
    final originalId = log.id;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => Padding(
      padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, start: DesignTokens.spaceLg, end: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.l10n.editSleepTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: DesignTokens.spaceLg),
        ListTile(leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary), title: Text(context.l10n.selectDate, style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? context.colorScheme.onPrimary : context.colorScheme.onSurface)), subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(sleepDate)),
          onTap: () async { final p = await showDatePicker(context: ctx, initialDate: sleepDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1))); if (p != null) setD(() { sleepDate = p; startTime = DateTime(p.year, p.month, p.day, startTime.hour, startTime.minute); if (endTime != null) endTime = DateTime(p.year, p.month, p.day, endTime!.hour, endTime!.minute); }); }),
        ListTile(leading: Icon(PhosphorIconsLight.moon, color: context.colorScheme.primary), title: Text(context.l10n.sleepStart, style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? context.colorScheme.onPrimary : context.colorScheme.onSurface)), subtitle: Text(DateFormat('hh:mm a').format(startTime)),
          onTap: () async { final tod = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(startTime)); if (tod != null && ctx.mounted) setD(() { startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, tod.hour, tod.minute); }); }),
        SwitchListTile(secondary: Icon(PhosphorIconsLight.sun, color: context.colorScheme.primary), title: Text(context.l10n.stillSleeping), value: isStillSleeping, onChanged: (v) => setD(() { isStillSleeping = v; if (v) endTime = null; })),
        if (!isStillSleeping) ListTile(leading: Icon(PhosphorIconsLight.sun, color: context.colorScheme.primary), title: Text(context.l10n.endTime), subtitle: Text(endTime != null ? DateFormat('hh:mm a').format(endTime!) : context.l10n.notSet),
          onTap: () async { final tod = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(endTime ?? startTime)); if (tod != null && ctx.mounted) setD(() { endTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, tod.hour, tod.minute); }); }),
        const SizedBox(height: DesignTokens.spaceMd),
        Wrap(spacing: DesignTokens.spaceSm, children: _qualities.map((q) => ChoiceChip(label: Text(_qualityLabel(q)), selected: selectedQuality == q, selectedColor: q.color.withValues(alpha: DesignTokens.opacityDim), onSelected: (_) => setD(() => selectedQuality = q))).toList()),
        const SizedBox(height: DesignTokens.spaceMd),
        TextField(controller: notesController, decoration: InputDecoration(labelText: context.l10n.notesOptionalLabel), maxLines: 2), const SizedBox(height: DesignTokens.spaceLg),
        Row(children: [
          Expanded(child: ThemeButton(text: context.l10n.delete, onPressed: () async {
            final confirmed = await ConfirmDeleteDialog.show(ctx, title: context.l10n.sleepLogDeleteTitle, message: context.l10n.sleepLogDeleteMessage);
            if (confirmed != true) return;
            try {
              await ref.read(apiClientProvider).deleteSleepLog(babyMonId!, originalId);
              setState(() => _sleepLogs.removeWhere((l) => l.id == originalId));
              ref.read(appRefreshProvider.notifier).state++;
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.sleepLogDeleted)));
            } catch (e) { if (ctx.mounted) showError(ctx, e); }
          }, variant: ThemeButtonVariant.outlined, foregroundColor: context.colorScheme.error, fullWidth: true)),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(child: ThemeButton(text: context.l10n.save, onPressed: () async {
            setD(() => isSaving = true);
            try {
              final ee = isStillSleeping ? DateTime.now() : endTime;
              final dur = ee?.difference(startTime) ?? const Duration(hours: 1);
              final t = (dur.inHours < 4 && startTime.hour >= 6 && startTime.hour < 20) ? SleepType.nap.apiKey : SleepType.night.apiKey;
              await ref.read(apiClientProvider).updateSleepLog(babyMonId!, originalId, {
                'type': t, 'startTime': startTime.toIso8601String(),
                'endTime': (ee ?? DateTime.now()).toIso8601String(),
                'quality': selectedQuality.apiNumericValue,
                'notes': notesController.text.isNotEmpty ? notesController.text : null,
              });
              // Update local state immediately
              setState(() {
                final idx = _sleepLogs.indexWhere((l) => l.id == originalId);
                if (idx != -1) {
                  _sleepLogs[idx] = log.copyWith(
                    type: t, startTime: startTime, endTime: ee,
                    quality: selectedQuality.apiNumericValue.toString(),
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );
                }
              });
              if (ctx.mounted) Navigator.pop(ctx);
              ref.read(appRefreshProvider.notifier).state++;
            } catch (e) { setD(() => isSaving = false); if (ctx.mounted) showError(ctx, e); }
          }, isLoading: isSaving, fullWidth: true, semanticLabel: context.l10n.saveSleepChangesSemantic)),
        ]),
        const SizedBox(height: DesignTokens.spaceSm),
      ]),
    )));
  }
}
