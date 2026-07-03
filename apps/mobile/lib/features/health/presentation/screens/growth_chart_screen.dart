// ignore_for_file: unused_element, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' as semantics;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/core/utils/utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/features/health/domain/entities/growth_record.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
class GrowthChartScreen extends ConsumerStatefulWidget {
  const GrowthChartScreen({super.key});
  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}
class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen>
    with DataScreenMixin<GrowthChartScreen> {
  List<GrowthRecord> _records = [];
  String _selectedMetric = 'WEIGHT';
  double _windowStart = 0.0;
  double _windowEnd = 1.0;
  final List<String> _metrics = ['WEIGHT', 'HEIGHT', 'HEAD_CIRCUMFERENCE'];
  bool _spotDialogOpen = false;
  @override
  bool get autoInit => true;
  @override
  Future<void> fetchData() async {
    final response = await ref
        .read(apiClientProvider)
        .getGrowthRecords(babyMonId!, type: _selectedMetric);
    final raw = response.data;
    // Backend returns paginated { items, total, skip, take }
    final items = raw is Map ? raw['items'] : raw;
    _records = items is List ? items.whereType<Map<String, dynamic>>().map(GrowthRecord.fromJson).toList() : [];
    _windowStart = 0.0;
    _windowEnd = 1.0;
  }
  Future<bool> _deleteRecord(String recordId, int index) async {
    final growthRecordDeletedText = context.l10n.growthRecordDeleted;
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: context.l10n.deleteGrowthRecordTitle,
      message: context.l10n.deleteGrowthRecordMessage,
    );
    if (confirmed != true) return false;
    try {
      await ref
          .read(apiClientProvider)
          .deleteGrowthRecord(babyMonId!, recordId);
      setState(() => _records.removeAt(index));
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(growthRecordDeletedText)));
      // ignore: deprecated_member_use
      semantics.SemanticsService.announce(growthRecordDeletedText, Directionality.of(context));
      }
      return true;
    } catch (e) {
      if (mounted) {
        showError(context, e);
      }
      return false;
    }
  }
  void _showSpotActions(GrowthRecord record) {
    _spotDialogOpen = true;
    final d = record.measuredAt;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${record.value.toStringAsFixed(1)} ${record.unit ?? _metricUnit(_selectedMetric)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        content: d != null
            ? Text(DateFormat.yMMMd().format(d),
                style: TextStyle(color: context.colorScheme.onSurfaceVariant))
            : null,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditRecordDialog(record);
            },
            icon: const Icon(PhosphorIconsLight.pencilSimple, size: 18),
            label: Text(context.l10n.editProfile),
          ),
          TextButton.icon(
            onPressed: () => _deleteSpotRecord(ctx, record),
            icon: Icon(PhosphorIconsLight.trash, size: 18, color: context.colorScheme.error),
            label: Text(context.l10n.delete, style: TextStyle(color: context.colorScheme.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    ).then((_) => _spotDialogOpen = false);
  }
  Future<void> _deleteSpotRecord(BuildContext ctx, GrowthRecord record) async {
    Navigator.pop(ctx); // close spot actions dialog
    final confirmed = await ConfirmDeleteDialog.show(
      ctx,
      title: context.l10n.deleteGrowthRecordTitle,
      message: context.l10n.deleteGrowthRecordMessage,
    );
    if (confirmed != true) return;
    try {
      await ref.read(apiClientProvider).deleteGrowthRecord(babyMonId!, record.id);
      setState(() => _records.remove(record));
      ref.read(appRefreshProvider.notifier).state++;
      if (ctx.mounted) Navigator.pop(ctx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.growthRecordDeleted)));
      }
    } catch (e) {
      if (ctx.mounted) showError(ctx, e);
    }
  }
  void _showEditRecordDialog(GrowthRecord record) {
    final valueController = TextEditingController(text: record.value.toString());
    final notesController = TextEditingController(text: record.notes ?? '');
    DateTime selectedDate = record.measuredAt ?? DateTime.now();
    String editMetric = record.type;
    bool isSaving = false;
    String? validationError;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            start: 16, end: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.editRecordTitle(_metricChipLabel(editMetric)),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
                ),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: _metricLabel(editMetric),
                  suffixText: _metricUnit(editMetric)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: context.l10n.notesOptionalLabel),
                maxLines: 2),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary),
                title: Text(DateFormat.yMMMd().format(selectedDate)),
                onTap: () async {
                  final p = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now());
                  if (p != null) setD(() => selectedDate = p);
                }),
              const SizedBox(height: 16),
              ThemeButton(
                text: context.l10n.saveChanges,
                onPressed: () async {
                  if (valueController.text.isEmpty) {
                    setD(() => validationError = context.l10n.pleaseEnterValue);
                    return;
                  }
                  setD(() { validationError = null; isSaving = true; });
                  try {
                    await ref.read(apiClientProvider).updateGrowthRecord(babyMonId!, record.id, {
                      'type': editMetric,
                      'value': double.tryParse(valueController.text) ?? 0,
                      'unit': _metricUnit(editMetric),
                      'measuredAt': selectedDate.toIso8601String(),
                      'notes': notesController.text,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      _spotDialogOpen = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.growthRecordUpdated)));
                    }
                    // Background sync
                    loadData(force: true);
                  } catch (e) {
                    setD(() { isSaving = false; });
                    if (ctx.mounted) showError(ctx, e);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  String _metricLabel(String m) {
    switch (m) {
      case 'WEIGHT':
        return context.l10n.weightLabel;
      case 'HEIGHT':
        return context.l10n.heightLabel;
      case 'HEAD_CIRCUMFERENCE':
        return context.l10n.headLabel;
      default:
        return m;
    }
  }
  String _metricUnit(String m) {
    switch (m) {
      case 'WEIGHT':
        return context.l10n.kg;
      case 'HEIGHT':
      case 'HEAD_CIRCUMFERENCE':
        return context.l10n.cm;
      default:
        return '';
    }
  }
  String _metricChipLabel(String m) {
    switch (m) {
      case 'WEIGHT':
        return context.l10n.weightLabel;
      case 'HEIGHT':
        return context.l10n.heightLabel;
      case 'HEAD_CIRCUMFERENCE':
        return context.l10n.headLabel;
      default:
        return m;
    }
  }
  List<FlSpot> get _spots {
    if (_records.isEmpty) return [];
    final sorted = List<GrowthRecord>.from(_records)
      ..sort((a, b) => (a.measuredAt ?? DateTime.now())
          .compareTo(b.measuredAt ?? DateTime.now()));
    return sorted
        .map((r) => FlSpot(
            (r.measuredAt?.millisecondsSinceEpoch.toDouble() ?? 0),
            r.value))
        .toList();
  }
  double get _fullMinX => _spots.isEmpty
      ? 0.0
      : _spots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
  double get _fullMaxX => _spots.isEmpty
      ? 1.0
      : _spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
  double get _fullRange => _fullMaxX - _fullMinX;
  Widget _buildChart() {
    final spots = _spots;
    final hasData = _records.isNotEmpty;
    final fullMinX = hasData ? _fullMinX : DateTime.now().millisecondsSinceEpoch.toDouble();
    final fullRange = hasData ? _fullRange : 86400000.0 * 30; // 30-day default range
    final windowLen = (_windowEnd - _windowStart).clamp(0.05, 1.0);
    final minX = fullMinX + fullRange * _windowStart;
    final maxX = minX + fullRange * windowLen;
    final visibleRange = maxX - minX;
    final visibleSpots =
        spots.where((s) => s.x >= minX && s.x <= maxX).toList();
    final values = visibleSpots.isNotEmpty
        ? visibleSpots.map((s) => s.y).toList()
        : <double>[0, 10]; // default range when no data
    final minY = values.isEmpty ? 0 : (values.reduce((a, b) => a < b ? a : b) * 0.9);
    final maxY = values.isEmpty ? 10 : (values.reduce((a, b) => a > b ? a : b) * 1.1);
    const oneDayMs = 86400000.0;
    final horizontalInterval = visibleRange <= 14 * oneDayMs
        ? oneDayMs
        : visibleRange <= 60 * oneDayMs
            ? 7 * oneDayMs
            : visibleRange <= 365 * oneDayMs
                ? 30 * oneDayMs
                : 90 * oneDayMs;
    return Semantics(
      label: context.l10n.growthChartSemantics(spots.length, _metricLabel(_selectedMetric)),
      child: GestureDetector(
      onHorizontalDragUpdate: (details) {
        final dragRatio =
            details.delta.dx / (MediaQuery.of(context).size.width);
        final currentLen = _windowEnd - _windowStart;
        // Allow overscroll so rightmost/leftmost points can be panned to center
        final newStart = (_windowStart - dragRatio * currentLen)
            .clamp(-0.15, 1.0 - currentLen + 0.15);
        setState(() {
          _windowStart = newStart;
          _windowEnd = (newStart + currentLen).clamp(currentLen - 0.15, 1.15);
        });
      },
      child: ClipRect(
        child: LineChart(LineChartData(
          clipData: const FlClipData.all(),
          minX: minX,
          maxX: maxX,
          minY: minY.toDouble(),
          maxY: maxY.toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: (maxY - minY) / 5,
            verticalInterval: horizontalInterval,
            getDrawingHorizontalLine: (v) => FlLine(
                color: context.colorScheme.outline.withValues(alpha: 0.3), strokeWidth: 1),
            getDrawingVerticalLine: (v) {
              final d = DateTime.fromMillisecondsSinceEpoch(v.toInt());
              return FlLine(
                  color: d.day == 1
                      ? context.colorScheme.outline.withValues(alpha: 0.5)
                      : context.colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: d.day == 1 ? 1.5 : 0.5);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: DesignTokens.fontSm, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: horizontalInterval,
                    getTitlesWidget: (v, m) {
                      if (m.appliedInterval < oneDayMs * 0.9) {
                        return const SizedBox.shrink();
                      }
                      final d = DateTime.fromMillisecondsSinceEpoch(v.toInt());
                      final s =
                          TextStyle(fontSize: DesignTokens.fontSm, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7));
                      if (visibleRange <= 3 * oneDayMs) {
                        return Text(DateFormat('MM/dd\nHH:mm').format(d),
                            style: s, textAlign: TextAlign.center);
                      }
                      if (visibleRange <= 60 * oneDayMs) {
                        return Text(DateFormat('MM/dd').format(d), style: s);
                      }
                      if (visibleRange <= 365 * oneDayMs) {
                        return d.day == 1
                            ? Text(DateFormat('MMM').format(d), style: s)
                            : const SizedBox.shrink();
                      }
                      return d.month == 1 && d.day == 1
                          ? Text(DateFormat('yyyy').format(d), style: s)
                          : const SizedBox.shrink();
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true,
              border: Border(
                  bottom: BorderSide(
                      color: context.colorScheme.outline.withValues(alpha: 0.5)),
                  left: BorderSide(
                      color: context.colorScheme.outline.withValues(alpha: 0.5)),
                  top: BorderSide.none,
                  right: BorderSide.none)),
          lineBarsData: [
            LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 7,
                        color: context.colorScheme.onPrimary,
                        strokeWidth: 2.5,
                        strokeColor: Theme.of(context).colorScheme.primary)),
                belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1)))
          ],
          lineTouchData: LineTouchData(
              touchSpotThreshold: 40,
              handleBuiltInTouches: false,
              touchCallback: (event, response) {
                if (_spotDialogOpen) return;
                if (response?.lineBarSpots == null || response!.lineBarSpots!.isEmpty) return;
                final spot = response.lineBarSpots!.first;
                // Find the matching record by timestamp
                final targetMs = spot.x.toInt();
                GrowthRecord? match;
                for (final r in _records) {
                  final rMs = r.measuredAt?.millisecondsSinceEpoch;
                  if (rMs != null && (rMs - targetMs).abs() < 60000) {
                    match = r; break;
                  }
                }
                if (match == null) return;
                _showSpotActions(match);
              },
              touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (ts) => ts.map((t) {
                        final d =
                            DateTime.fromMillisecondsSinceEpoch(t.x.toInt());
                        return LineTooltipItem(
                            '${DateFormat('MMM d, yyyy').format(d)}\n${t.y.toStringAsFixed(1)} ${_metricUnit(_selectedMetric)}',
                            TextStyle(color: context.colorScheme.onPrimary, fontSize: DesignTokens.fontSm));
                      }).toList())),
        )),
      ),
      ),
    );
  }
  void _zoomIn() {
    final l = (_windowEnd - _windowStart) / 1.5;
    final c = (_windowStart + _windowEnd) / 2;
    final m = 1.0 - l;
    setState(() {
      _windowStart = (c - l / 2).clamp(-0.15, m > -0.15 ? m + 0.15 : -0.15);
      _windowEnd = (_windowStart + l).clamp(l - 0.15, 1.15);
    });
  }
  void _zoomOut() {
    final l = (_windowEnd - _windowStart) * 1.5;
    final c = (_windowStart + _windowEnd) / 2;
    final m = 1.0 - l;
    setState(() {
      _windowStart = (c - l / 2).clamp(-0.15, m > -0.15 ? m + 0.15 : -0.15);
      _windowEnd = (_windowStart + l).clamp(l - 0.15, 1.15);
    });
  }
  void _resetZoom() {
    setState(() {
      _windowStart = 0.0;
      _windowEnd = 1.0;
    });
  }
  @override
  Widget build(BuildContext context) {
    final zoomLevel =
        (1.0 / (_windowEnd - _windowStart).clamp(0.05, 1.0)).toStringAsFixed(1);
    return Scaffold(
      appBar: ScreenHeader(
        title: context.l10n.growthChart,
        onBack: () => context.pop(),
        actions: [
          Center(
              child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4),
                  child: Text('${zoomLevel}x',
                      style: TextStyle(
                          fontSize: DesignTokens.fontSm, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))))),
          ThemeButton.icon(icon: PhosphorIconsLight.target, onPressed: _resetZoom, tooltip: context.l10n.resetZoom, variant: ThemeButtonVariant.text),
        ],
      ),
      body: PremiumBackground(
        child: isLoading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _metrics.map((m) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: FilterChip(
                                label: Text(_metricChipLabel(m),
                                  style: TextStyle(color: _selectedMetric == m ? context.colorScheme.onPrimary : null)),
                                selected: _selectedMetric == m,
                                onSelected: (_) {
                                  setState(() { _selectedMetric = m; _windowStart = 0.0; _windowEnd = 1.0; });
                                  loadData();
                                },
                                selectedColor: context.colorScheme.primary,
                                checkmarkColor: context.colorScheme.onPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        Text(_metricLabel(_selectedMetric), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        ThemeButton.icon(icon: PhosphorIconsLight.magnifyingGlassMinus, onPressed: _zoomOut, tooltip: context.l10n.zoomOut, variant: ThemeButtonVariant.text, iconSize: 20),
                        const SizedBox(width: 4),
                        ThemeButton.icon(icon: PhosphorIconsLight.magnifyingGlassPlus, onPressed: _zoomIn, tooltip: context.l10n.zoomIn, variant: ThemeButtonVariant.text, iconSize: 20),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: DesignTokens.spaceXs, top: 0, end: DesignTokens.spaceMd, bottom: 20),
                        child: _buildChart(),
                      ),
                    ),
                  ],
                ),
      ),
      floatingActionButton: hasBabyMon
          ? Semantics(
              label: context.l10n.addGrowthRecordSemantic,
              button: true,
              child: FadeScaleIn(
                child: FloatingActionButton(
                  heroTag: 'add_growth',
                  backgroundColor: context.colorScheme.primary,
                  onPressed: _showAddRecordDialog,
                  child: Icon(PhosphorIconsLight.scales, color: context.colorScheme.onPrimary),
                ),
              ),
            )
          : null,
    );
  }
  void _showAddRecordDialog() {
    final valueController = TextEditingController(),
        notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isSaving = false;
    String? validationError;
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setD) => Padding(
                padding: EdgeInsetsDirectional.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    start: 16,
                    end: 16,
                    top: 16),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.l10n.addRecordTitle(_metricChipLabel(_selectedMetric)),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                          segments: _metrics
                              .map((m) => ButtonSegment(
                                  value: m, label: Text(_metricChipLabel(m))))
                              .toList(),
                          selected: {_selectedMetric},
                          onSelectionChanged: (s) =>
                              setD(() => _selectedMetric = s.first),
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
                            ),
                          ),),
                      const SizedBox(height: 12),
                      if (validationError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
                        ),
                      TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                              labelText: _metricLabel(_selectedMetric),
                              hintText: _selectedMetric == 'WEIGHT'
                                  ? context.l10n.growthValueHintWeight
                                  : context.l10n.growthValueHintHeight,
                              suffixText: _metricUnit(_selectedMetric)),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true)),
                      const SizedBox(height: 12),
                      TextField(
                          controller: notesController,
                          decoration: InputDecoration(
                              labelText: context.l10n.notesOptionalLabel,
                              hintText: context.l10n.noteOptionalHint),
                          maxLines: 2),
                      const SizedBox(height: 12),
                      ListTile(
                          leading: Icon(PhosphorIconsLight.calendar,
                              color: context.colorScheme.primary),
                          title: Text(DateFormat.yMMMd().format(selectedDate),
                              style: TextStyle(color: ctx.textPrimary)),
                          onTap: () async {
                            final p = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now());
                            if (p != null) setD(() => selectedDate = p);
                          }),
                      const SizedBox(height: 16),
                      ThemeButton(
                          text: context.l10n.save,
                          onPressed: () async {
                              if (valueController.text.isEmpty) {
                                setD(() => validationError = context.l10n.pleaseEnterValue);
                                return;
                              }
                              setD(() { validationError = null; isSaving = true; });
                              try {
                                final result = await ref.read(apiClientProvider)
                                    .createGrowthRecord(babyMonId!, {
                                  'type': _selectedMetric,
                                  'value': double.parse(valueController.text),
                                  'unit': _metricUnit(_selectedMetric),
                                  'notes': notesController.text.isNotEmpty ? notesController.text : null,
                                  'measuredAt': selectedDate.toIso8601String()
                                });
                                // Close dialog immediately
                                if (ctx.mounted) Navigator.pop(ctx);
                                // Optimistic: add record locally
                                final newRecord = GrowthRecord.fromJson({
                                  'id': parseString(result.data['id']) ?? '',
                                  'type': _selectedMetric,
                                  'value': double.parse(valueController.text),
                                  'unit': _metricUnit(_selectedMetric),
                                  'notes': notesController.text.isNotEmpty ? notesController.text : null,
                                  'measuredAt': selectedDate.toIso8601String(),
                                });
                                setState(() => _records.add(newRecord));
                              } catch (e) {
                                setD(() => isSaving = false);
                                if (ctx.mounted) showError(ctx, e);
                              }
                            },
                          isLoading: isSaving,
                          fullWidth: true,
                          semanticLabel: context.l10n.saveGrowthRecordSemantic),
                    ]))));
  }
}
