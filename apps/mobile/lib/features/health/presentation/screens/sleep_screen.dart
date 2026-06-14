import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
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
  Duration? get refreshCooldown => const Duration(seconds: 10);

  List<Map<String, dynamic>> _sleepLogs = [];
  DateTime _selectedDate = DateTime.now();
  final List<String> _qualities = ['GREAT', 'GOOD', 'FAIR', 'POOR'];

  int _chartRange = 3;
  String _chartUnit = 'Days';
  String? _selectedBarDate;


  @override
  Future<void> fetchData() async {
    final response = await ref.read(apiClientProvider).getSleepLogs(babyMonId!);
    _sleepLogs = parseItemsTyped(response.data);
  }

  Future<bool> _deleteLog(String id, int index) async {
    // Capture messenger upfront so we can safely use it after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Sleep Log'), content: const Text('Remove this sleep record?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.error)))],
    ));
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteSleepLog(babyMonId!, id);
      setState(() => _sleepLogs.removeAt(index));
      messenger.showSnackBar(const SnackBar(content: Text('Sleep log deleted')));
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }

  List<Map<String, dynamic>> _logsForSelectedDate() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _sleepLogs.where((log) => (log['startTime']?.toString() ?? '').startsWith(dateStr)).toList();
  }

  List<Map<String, dynamic>> _sleepLogsByDay() {
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
    final dayGroups = <String, List<Map<String, dynamic>>>{};
    for (final log in _sleepLogs) {
      final start = DateTime.tryParse(log['startTime']?.toString() ?? '');
      if (start == null || start.millisecondsSinceEpoch < cutoffMs) continue;
      final dayKey = DateFormat('yyyy-MM-dd').format(start);
      dayGroups.putIfAbsent(dayKey, () => []);
      dayGroups[dayKey]!.add(log);
    }
    final allDays = <String, List<Map<String, dynamic>>>{};
    var current = cutoff;
    while (!current.isAfter(now)) {
      final key = DateFormat('yyyy-MM-dd').format(current);
      allDays[key] = dayGroups[key] ?? [];
      current = current.add(const Duration(days: 1));
    }
    return allDays.entries.map((e) => {
      'date': e.key,
      'logs': e.value,
      'totalMinutes': e.value.fold(0.0, (sum, log) {
        final s = DateTime.tryParse(parseString(log['startTime']) ?? '');
        final e2 = DateTime.tryParse(parseString(log['endTime']) ?? '');
        return sum + (s != null && e2 != null ? e2.difference(s).inMinutes : 0.0);
      }),
    }).toList();
  }

  String _qualityLabel(String q) { switch (q) { case '5': case 'GREAT': return 'GREAT'; case '4': case 'GOOD': return 'GOOD'; case '3': case '2': case 'FAIR': return 'FAIR'; case '1': case 'POOR': default: return 'POOR'; } }
  Color _qualityColor(String q) { switch (q) { case 'GREAT': return AppColors.success; case 'GOOD': return AppColors.accent; case 'FAIR': return AppColors.warning; case 'POOR': return AppColors.error; default: return AppColors.textCaption; } }

  Map<String, dynamic> _dailySummary(List<Map<String, dynamic>> logs) {
    int totalMinutes = 0, naps = 0;
    for (final log in logs) {
      final start = DateTime.tryParse(log['startTime']?.toString() ?? ''); final end = DateTime.tryParse(log['endTime']?.toString() ?? '');
      if (start != null && end != null) { totalMinutes += end.difference(start).inMinutes; if (end.difference(start).inHours < 4 && start.hour >= 6 && start.hour < 20) naps++; }
    }
    final avgQuality = logs.isNotEmpty ? logs.map((l) => ({'GREAT': 4, 'GOOD': 3, 'FAIR': 2, 'POOR': 1})[l['quality']?.toString() ?? 'GOOD'] ?? 3).reduce((a, b) => a + b) / logs.length : 0.0;
    return {'totalMinutes': totalMinutes, 'naps': naps, 'avgQuality': avgQuality, 'count': logs.length};
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          const Icon(PhosphorIconsLight.moon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('24h Sleep Timeline', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Semantics(
            label: 'Change chart range',
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
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surfaceLight, borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
              child: Text('$_chartRange $_chartUnit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            ),
          ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: _qualities.map((q) => Padding(padding: const EdgeInsets.only(right: 12), child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: _qualityColor(q), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),                        Text(q[0] + q.substring(1).toLowerCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ]))).toList())),
      const SizedBox(height: 8),
      SizedBox(
        height: chartHeight + topLabelHeight + 16,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Column(children: List.generate(numSlots, (si) {
              final hour = (numSlots - 1 - si) * intervalHours;
              return Container(
                width: leftLabelWidth, height: hourHeight, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 4),                                child: Text('${hour.toString().padLeft(2, '0')}:00', style: const TextStyle(fontSize: 12, color: AppColors.textCaption)),
              );
            })),
            const SizedBox(height: topLabelHeight),
          ]),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(children: [
                SizedBox(
                  height: chartHeight,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(days.length, (di) {
                    final day = days[di];
                    final dateStr = parseString(day['date']) ?? '';
                    final rawLogs = day['logs'];
                    final logs = rawLogs is List ? List<Map<String, dynamic>>.from(rawLogs) : <Map<String, dynamic>>[];
                    final isSelected = _selectedBarDate == dateStr;
                    return Semantics(
                      label: 'View sleep details for $dateStr',
                      button: true,
                      child: GestureDetector(
                      onTap: () => _showDaySleepDetails(day),
                      child: Container(
                        width: dayWidth, height: chartHeight,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
                          border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
                        ),
                        child: Stack(children: [
                          ...List.generate(numSlots + 1, (si) => Positioned(
                            top: si * hourHeight - 0.5, left: 0, right: 0,
                            child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
                          )),
                          ...logs.map((log) {
                            final start = DateTime.tryParse(log['startTime']?.toString() ?? '');
                            final end = DateTime.tryParse(log['endTime']?.toString() ?? '');
                            if (start == null || end == null) return const SizedBox.shrink();
                            final endMin = (end.hour * 60 + end.minute).clamp(0, 24 * 60);
                            final durationMin = endMin - (start.hour * 60 + start.minute);
                            const slotMin = intervalHours * 60.0;
                            final topPos = chartHeight - (endMin / slotMin * hourHeight);
                            final barHeight = (durationMin / slotMin * hourHeight).clamp(2.0, chartHeight - topPos);
                            final q = _qualityLabel(parseString(log['quality']) ?? '');
                            return Positioned(
                              top: topPos, left: 2, right: 2,
                              child: Container(
                                height: barHeight,
                                decoration: BoxDecoration(color: _qualityColor(q), borderRadius: BorderRadius.circular(3)),
                                alignment: Alignment.center,
                                child: barHeight > 18
                                    ? Text('${_formatTime(log['startTime']?.toString())}-${_formatTime(log['endTime']?.toString())}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))
                                    : null,
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
                    final dateStr = parseString(day['date']) ?? '';
                    final date = DateTime.tryParse(dateStr);
                    final label = date != null ? DateFormat('d MMM').format(date) : dateStr;
                    final isToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final isSelected = _selectedBarDate == dateStr;
                    return Semantics(
                      label: 'View sleep details for $dateStr',
                      button: true,
                      child: GestureDetector(
                      onTap: () => _showDaySleepDetails(day),
                      child: Container(
                        width: dayWidth, height: topLabelHeight, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isToday ? AppColors.warning.withValues(alpha: 0.12) : null),
                          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                        ),
                        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isToday ? AppColors.primary : AppColors.textSecondary)),
                      ),
                    ),
                  );
                })),
                ),
              ]),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      if (_selectedBarDate != null) Center(child: Text('Selected: $_selectedBarDate \u2014 tap for details', style: const TextStyle(fontSize: 13, color: AppColors.textCaption))),
    ]);
  }

  void _showDaySleepDetails(Map<String, dynamic> day) {
    final dateStr = parseString(day['date']) ?? '';
    final rawLogs = day['logs'];
    final logs = rawLogs is List ? List<Map<String, dynamic>>.from(rawLogs) : <Map<String, dynamic>>[];
    final totalMin = (parseDouble(day['totalMinutes'] as Object?) ?? 0.0).toInt();
    setState(() => _selectedBarDate = dateStr);
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Sleep \u2014 $dateStr'),
      content: SizedBox(width: double.maxFinite, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total: ${totalMin ~/ 60}h ${totalMin % 60}m | ${logs.length} sessions', style: const TextStyle(fontWeight: FontWeight.w600)),
        const Divider(),
        ...logs.map((log) {
          final q = _qualityLabel(parseString(log['quality']) ?? '');
          return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: _qualityColor(q), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text('${_formatTime(parseString(log['startTime']))} \u2192 ${_formatTime(parseString(log['endTime']))} (${_formatDuration(parseString(log['startTime']), parseString(log['endTime']))})', style: const TextStyle(fontSize: 13))),
            Text(q[0] + q.substring(1).toLowerCase(), style: TextStyle(fontSize: 11, color: _qualityColor(q), fontWeight: FontWeight.w600)),
          ]));
        }),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final logs = _logsForSelectedDate();
    final summary = _dailySummary(logs);
    return Scaffold(
      appBar: ScreenHeader(
        title: 'Sleep',
        onBack: () => context.pop(),
      ),
      body: PremiumBackground(
        child: isLoading
          ? buildLoading()
          : !hasBabyMon
              ? buildNoBabyMon()
              : RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ThemeButton.icon(icon: PhosphorIconsLight.caretLeft, onPressed: () => setState(() { _selectedDate = _selectedDate.subtract(const Duration(days: 1)); }), semanticLabel: 'Previous day', variant: ThemeButtonVariant.text),
                Text(_selectedDate.day == DateTime.now().day && _selectedDate.month == DateTime.now().month && _selectedDate.year == DateTime.now().year ? 'Today - ${DateFormat('MMM d').format(_selectedDate)}' : DateFormat('EEEE, MMM d').format(_selectedDate),        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ThemeButton.icon(icon: PhosphorIconsLight.caretRight, onPressed: () => setState(() { _selectedDate = _selectedDate.add(const Duration(days: 1)); }), semanticLabel: 'Next day', variant: ThemeButtonVariant.text),
              ]),
            ),
            PremiumCard(
              isGlass: true,
              margin: const EdgeInsets.fromLTRB(DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, DesignTokens.spaceXs),
              child: Padding(padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _summaryStat('${(parseDouble(summary['totalMinutes']) ?? 0).toInt() ~/ 60}h ${(parseDouble(summary['totalMinutes']) ?? 0).toInt() % 60}m', 'Total'),
                _summaryStat('${summary['naps']}', 'Naps'),
                _summaryStat(_qualityLabelText(parseDouble(summary['avgQuality']) ?? 0.0), 'Avg'),
                _summaryStat('${summary['count']}', 'Entries'),
              ])),
            ),
            _buildTimelineChart(),
            if (logs.isEmpty) PremiumEmptyState(
                icon: PhosphorIconsLight.moon,
                title: 'No sleep logs for this day',
                subtitle: 'Tap the button below to add sleep.',
                actionLabel: 'Add sleep',
                onAction: _showAddSleepDialog,
              )
            else ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(16), itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index]; final type = _sleepTypeLabel(log);
                return ScrollStagger(
                    index: index,
                    child: Dismissible(key: Key(parseString(log['id']) ?? index.toString()), direction: DismissDirection.endToStart,                   confirmDismiss: (_) => _deleteLog(parseString(log['id']) ?? '', _sleepLogs.indexOf(log)),
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppColors.error, child: const Icon(PhosphorIconsLight.trash, color: Colors.white)),
                  child: PremiumCard(
                    isGlass: true,
                    margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                    child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.15), child: const Icon(PhosphorIconsLight.moon, color: AppColors.primary)),
                    title: Text(type),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${_formatTime(log['startTime']?.toString())} \u2192 ${_formatTime(log['endTime']?.toString())} (${_formatDuration(log['startTime']?.toString(), log['endTime']?.toString())})'),
                      const SizedBox(height: 4),
                      Row(children: _qualities.map((q) => Padding(padding: const EdgeInsets.only(right: 4), child: Icon(PhosphorIconsLight.circle, size: 10, color: log['quality']?.toString() == q ? _qualityColor(q) : AppColors.disabled))).toList()),
                    ]), isThreeLine: true,
                    trailing: log['notes'] != null && log['notes'].toString().isNotEmpty ? const Icon(PhosphorIconsLight.note, size: 16, color: AppColors.textCaption) : null,
                  )),
                ),
              );
              },
            ),
          ]),
        ),
      ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_sleep',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddSleepDialog,
        child: const Icon(PhosphorIconsLight.moon),
      ),
    );
  }

  String _sleepTypeLabel(Map<String, dynamic> log) {
    final start = DateTime.tryParse(log['startTime']?.toString() ?? ''); final end = DateTime.tryParse(log['endTime']?.toString() ?? '');
    if (start == null || end == null) return 'Sleep'; final duration = end.difference(start);
    if (duration.inHours >= 4) return 'Night sleep'; if (start.hour >= 20 || start.hour < 6) return 'Night sleep'; return 'Nap';
  }

  String _qualityLabelText(double s) { if (s >= 3.5) return 'Great'; if (s >= 2.5) return 'Good'; if (s >= 1.5) return 'Fair'; if (s >= 0.5) return 'Poor'; return 'N/A'; }
  Widget _summaryStat(String v, String l) { return Column(children: [Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(l, style: const TextStyle(fontSize: 13, color: AppColors.textCaption, height: 1.4))]); }

  void _showAddSleepDialog() {
    if (babyMonId == null) return;
    final now = DateTime.now();
    DateTime sleepDate = _selectedDate;
    DateTime startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, now.hour, 0);
    DateTime? endTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, now.hour, 0);
    String selectedQuality = 'GOOD'; final notesController = TextEditingController();
    bool isStillSleeping = false, isSaving = false;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Log Sleep', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 16),
        ListTile(leading: const Icon(PhosphorIconsLight.calendar, color: AppColors.primary),        title: Text('Date', style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.textOnDark : AppColors.textPrimary)),  subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(sleepDate)),
          onTap: () async { final p = await showDatePicker(context: ctx, initialDate: sleepDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1))); if (p != null) setD(() { sleepDate = p; startTime = DateTime(p.year, p.month, p.day, startTime.hour, startTime.minute); if (endTime != null) endTime = DateTime(p.year, p.month, p.day, endTime!.hour, endTime!.minute); }); }),
        ListTile(leading: const Icon(PhosphorIconsLight.moon, color: AppColors.primary),        title: Text('Start time', style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.textOnDark : AppColors.textPrimary)), subtitle: Text(DateFormat('hh:mm a').format(startTime)),
          onTap: () async { final tod = await WheelPickerBottomSheet.showTime(context: ctx, initialTime: TimeOfDay.fromDateTime(startTime)); if (ctx.mounted) setD(() { startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, tod.hour, tod.minute); }); }),
        SwitchListTile(secondary: const Icon(PhosphorIconsLight.sun, color: AppColors.primary), title: const Text('Still sleeping'), value: isStillSleeping, onChanged: (v) => setD(() { isStillSleeping = v; if (v) endTime = null; })),
        if (!isStillSleeping) ListTile(leading: const Icon(PhosphorIconsLight.sun, color: AppColors.primary), title: const Text('End time'), subtitle: Text(DateFormat('hh:mm a').format(endTime!)),
          onTap: () async { final tod = await WheelPickerBottomSheet.showTime(context: ctx, initialTime: TimeOfDay.fromDateTime(endTime!)); if (ctx.mounted) setD(() { endTime = DateTime(endTime!.year, endTime!.month, endTime!.day, tod.hour, tod.minute); }); }),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: _qualities.map((q) => ChoiceChip(label: Text(q[0] + q.substring(1).toLowerCase()), selected: selectedQuality == q, selectedColor: _qualityColor(q).withValues(alpha: 0.3), onSelected: (_) => setD(() => selectedQuality = q))).toList()),
        const SizedBox(height: 12),
        TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2), const SizedBox(height: 16),
        ThemeButton(text: 'Save', onPressed: () async { setD(() => isSaving = true); try { final ee = isStillSleeping ? startTime.add(const Duration(minutes: 1)) : endTime; final dur = ee?.difference(startTime) ?? const Duration(hours: 1); final t = (dur.inHours < 4 && startTime.hour >= 6 && startTime.hour < 20) ? 'NAP' : 'NIGHT';                    await ref.read(apiClientProvider).createSleepLog(babyMonId!, {'type': t, 'startTime': startTime.toIso8601String(), 'endTime': (ee ?? DateTime.now()).toIso8601String(), 'quality': {'GREAT': 5, 'GOOD': 4, 'FAIR': 2, 'POOR': 1}[selectedQuality] ?? 3, 'notes': notesController.text.isNotEmpty ? notesController.text : null}); await loadData(force: true); if (ctx.mounted) Navigator.pop(ctx); } catch (e) { setD(() => isSaving = false); if (ctx.mounted) showError(ctx, e); }}, isLoading: isSaving, fullWidth: true, semanticLabel: 'Save sleep log'),
      ]),
    )));
  }
}
