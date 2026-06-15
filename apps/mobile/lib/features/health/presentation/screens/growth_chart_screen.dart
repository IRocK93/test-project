import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/core/utils/utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/widgets/widgets.dart';

class GrowthChartScreen extends ConsumerStatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen>
    with DataScreenMixin<GrowthChartScreen> {
  List<Map<String, dynamic>> _records = [];
  String _selectedMetric = 'WEIGHT';
  double _windowStart = 0.0;
  double _windowEnd = 1.0;
  final List<String> _metrics = ['WEIGHT', 'HEIGHT', 'HEAD_CIRCUMFERENCE'];

  @override
  bool get autoInit => true;

  @override
  Future<void> fetchData() async {
    final response = await ref
        .read(apiClientProvider)
        .getGrowthRecords(babyMonId!, type: _selectedMetric);
    final raw = response.data;
    _records = raw is List ? List<Map<String, dynamic>>.from(raw) : [];
    _windowStart = 0.0;
    _windowEnd = 1.0;
  }

  Future<bool> _deleteRecord(String recordId, int index) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Growth Record',
      message: 'Are you sure you want to delete this measurement?',
    );
    if (confirmed != true) return false;
    try {
      await ref
          .read(apiClientProvider)
          .deleteGrowthRecord(babyMonId!, recordId);
      setState(() => _records.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Growth record deleted')));
      }
      return true;
    } catch (e) {
      if (mounted) {
        showError(context, e);
      }
      return false;
    }
  }

  String _metricLabel(String m) {
    switch (m) {
      case 'WEIGHT':
        return 'Weight (kg)';
      case 'HEIGHT':
        return 'Height (cm)';
      case 'HEAD_CIRCUMFERENCE':
        return 'Head (cm)';
      default:
        return m;
    }
  }

  String _metricUnit(String m) {
    switch (m) {
      case 'WEIGHT':
        return 'kg';
      case 'HEIGHT':
        return 'cm';
      case 'HEAD_CIRCUMFERENCE':
        return 'cm';
      default:
        return '';
    }
  }

  String _metricChipLabel(String m) {
    switch (m) {
      case 'WEIGHT':
        return 'Weight';
      case 'HEIGHT':
        return 'Height';
      case 'HEAD_CIRCUMFERENCE':
        return 'Head';
      default:
        return m;
    }
  }

  List<FlSpot> get _spots {
    if (_records.isEmpty) return [];
    final sorted = List<Map<String, dynamic>>.from(_records)
      ..sort((a, b) => (DateTime.tryParse(a['measuredAt']?.toString() ?? '') ??
              DateTime.now())
          .compareTo(DateTime.tryParse(b['measuredAt']?.toString() ?? '') ??
              DateTime.now()));
    return sorted
        .map((r) => FlSpot(
            (DateTime.tryParse(r['measuredAt']?.toString() ?? '')
                    ?.millisecondsSinceEpoch
                    .toDouble() ??
                0),
            double.tryParse(r['value']?.toString() ?? '0') ?? 0))
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
    if (_records.isEmpty) {
      return const PremiumEmptyState(
        icon: PhosphorIconsLight.chartLine,
        title: 'No growth data yet',
      );
    }

    final spots = _spots;
    final fullMinX = _fullMinX;
    final fullRange = _fullRange;
    final windowLen = (_windowEnd - _windowStart).clamp(0.05, 1.0);
    final minX = fullMinX + fullRange * _windowStart;
    final maxX = minX + fullRange * windowLen;
    final visibleRange = maxX - minX;

    final visibleSpots =
        spots.where((s) => s.x >= minX && s.x <= maxX).toList();
    final values = visibleSpots.isNotEmpty
        ? visibleSpots.map((s) => s.y).toList()
        : spots.map((s) => s.y).toList();
    final minY =
        values.isEmpty ? 0 : (values.reduce((a, b) => a < b ? a : b) * 0.9);
    final maxY =
        values.isEmpty ? 10 : (values.reduce((a, b) => a > b ? a : b) * 1.1);

    const oneDayMs = 86400000.0;
    final horizontalInterval = visibleRange <= 14 * oneDayMs
        ? oneDayMs
        : visibleRange <= 60 * oneDayMs
            ? 7 * oneDayMs
            : visibleRange <= 365 * oneDayMs
                ? 30 * oneDayMs
                : 90 * oneDayMs;

    return Semantics(
      label: 'Growth chart, swipe to pan',
      child: GestureDetector(
      onHorizontalDragUpdate: (details) {
        final dragRatio =
            details.delta.dx / (MediaQuery.of(context).size.width);
        final currentLen = _windowEnd - _windowStart;
        final newStart = (_windowStart - dragRatio * currentLen)
            .clamp(0.0, 1.0 - currentLen);
        setState(() {
          _windowStart = newStart;
          _windowEnd = (newStart + currentLen).clamp(currentLen, 1.0);
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
                color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1),
            getDrawingVerticalLine: (v) {
              final d = DateTime.fromMillisecondsSinceEpoch(v.toInt());
              return FlLine(
                  color: d.day == 1
                      ? AppColors.border.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.2),
                  strokeWidth: d.day == 1 ? 1.5 : 0.5);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textCaption)))),
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
                      const s =
                          TextStyle(fontSize: 12, color: AppColors.textCaption);
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
                      color: AppColors.border.withValues(alpha: 0.5)),
                  left: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5)),
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
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).colorScheme.primary)),
                belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1)))
          ],
          lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (ts) => ts.map((t) {
                        final d =
                            DateTime.fromMillisecondsSinceEpoch(t.x.toInt());
                        return LineTooltipItem(
                            '${DateFormat('MMM d, yyyy').format(d)}\n${t.y.toStringAsFixed(1)} ${_metricUnit(_selectedMetric)}',
                            const TextStyle(color: AppColors.textOnPrimary, fontSize: 12));
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
      _windowStart = (c - l / 2).clamp(0.0, m > 0 ? m : 0.0);
      _windowEnd = (_windowStart + l).clamp(l, 1.0);
    });
  }

  void _zoomOut() {
    final l = (_windowEnd - _windowStart) * 1.5;
    final c = (_windowStart + _windowEnd) / 2;
    final m = 1.0 - l;
    setState(() {
      _windowStart = (c - l / 2).clamp(0.0, m > 0 ? m : 0.0);
      _windowEnd = (_windowStart + l).clamp(l, 1.0);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zoomLevel =
        (1.0 / (_windowEnd - _windowStart).clamp(0.05, 1.0)).toStringAsFixed(1);
    return Scaffold(
      appBar: ScreenHeader(
        title: 'Growth Chart',
        onBack: () => context.pop(),
        actions: [
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text('${zoomLevel}x',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textCaption)))),
          ThemeButton.icon(icon: PhosphorIconsLight.target, onPressed: _resetZoom, tooltip: 'Reset zoom', variant: ThemeButtonVariant.text),
        ],
      ),
      body: PremiumBackground(
        child: isLoading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : Column(
                children: [
                  StaggeredFadeSlide(
                      index: 0,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceMd,
                              vertical: DesignTokens.spaceSm),
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  children: _metrics
                                      .map((m) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: FilterChip(
                                              label: Text(_metricChipLabel(m),
                                                  style: TextStyle(
                                                      color: _selectedMetric ==
                                                              m
                                                          ? Colors.white
                                                          : null)),
                                              selected: _selectedMetric == m,
                                              onSelected: (_) {
                                                setState(() {
                                                  _selectedMetric = m;
                                                  _windowStart = 0.0;
                                                  _windowEnd = 1.0;
                                                });
                                                loadData();
                                              },
                                              selectedColor: AppColors.primary,
                                              checkmarkColor: Colors.white)))
                                      .toList())))),
                  StaggeredFadeSlide(
                      index: 1,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(children: [
                            Text(_metricLabel(_selectedMetric),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600)),
                            const Spacer(),
                            ThemeButton.icon(icon: PhosphorIconsLight.magnifyingGlassMinus, onPressed: _zoomOut, tooltip: 'Zoom out', variant: ThemeButtonVariant.text, iconSize: 20),
                            const SizedBox(width: 4),
                            ThemeButton.icon(icon: PhosphorIconsLight.magnifyingGlassPlus, onPressed: _zoomIn, tooltip: 'Zoom in', variant: ThemeButtonVariant.text, iconSize: 20)
                          ]))),
                  const SizedBox(height: 4),
                  Expanded(
                      flex: 6,
                      child: StaggeredFadeSlide(
                          index: 2,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(DesignTokens.spaceXs,
                                  0, DesignTokens.spaceMd, 0),
                              child: _buildChart()))),
                  if (_records.isNotEmpty)
                    Expanded(
                      flex: 4,
                      child: StaggeredFadeSlide(
                        index: 3,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceMd),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusLg),
                            border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.5)),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusLg),
                            child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: DesignTokens.glassBlurLight,
                                  sigmaY: DesignTokens.glassBlurLight,
                                ),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.glassDark
                                          : AppColors.glassWhite,
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusLg),
                                      border: Border.all(
                                        color: AppColors.glassBorder
                                            .withValues(alpha: 0.6),
                                        width: DesignTokens.glassBorderWidth,
                                      ),
                                    ),
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: _records.length,
                                        itemBuilder: (c, i) {
                                          final r = _records[i];
                                          final d = DateTime.tryParse(
                                              parseString(r['measuredAt']) ??
                                                  '');
                                          final v = double.tryParse(
                                                  parseString(r['value']) ??
                                                      '0') ??
                                              0;
                                          return Dismissible(
                                              key: Key(parseString(r['id']) ?? i.toString()),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding: const EdgeInsets.only(
                                                      right: 20),
                                                  color: AppColors.error,
                                                  child: const Icon(PhosphorIconsLight.trash,
                                                      color: AppColors.textOnPrimary)),                                                  confirmDismiss: (_) =>
                                                  _deleteRecord(parseString(r['id']) ?? '', i),
                                              child: ListTile(
                                                  dense: true,
                                                  leading: CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor:
                                                          AppColors.primary.withValues(
                                                              alpha: 0.15),
                                                      child: Icon(
                                                          _selectedMetric ==
                                                                  'WEIGHT'                                                                  ? PhosphorIconsLight.scales
                                                              : _selectedMetric ==
                                                                      'HEIGHT'
                                                                  ? PhosphorIconsLight.arrowsVertical
                                                                  : PhosphorIconsLight.userCircle,
                                                          size: 16,
                                                          color: AppColors
                                                              .primary)),
                                                  title: Text(
                                                      '${v.toStringAsFixed(1)} ${_metricUnit(_selectedMetric)}',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .textPrimary)),
                                                  subtitle: d != null
                                                      ? Text(DateFormat.yMMMd().format(d),
                                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4))
                                                      : null));
                                        }))), // ListView.builder
                          ), // Container
                        ), // BackdropFilter
                      ), // ClipRRect
                    ), // Expanded
                ],
              ),
      ),
      floatingActionButton: Tooltip(
        message: 'Add Record',
        preferBelow: false,
        verticalOffset: 8,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        child: FadeScaleIn(
          child: FloatingActionButton(
            heroTag: 'add_growth',
            backgroundColor: AppColors.primary,
            onPressed: _showAddRecordDialog,
            child: const Icon(PhosphorIconsLight.scales, color: AppColors.textOnPrimary),
          ),
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    final valueController = TextEditingController(),
        notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isSaving = false;
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setD) => Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Add ${_metricChipLabel(_selectedMetric)} Record',
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
                              setD(() => _selectedMetric = s.first)),
                      const SizedBox(height: 12),
                      TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                              labelText: _metricLabel(_selectedMetric),
                              hintText: _selectedMetric == 'WEIGHT'
                                  ? 'e.g., 7.5'
                                  : 'e.g., 65',
                              suffixText: _metricUnit(_selectedMetric)),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true)),
                      const SizedBox(height: 12),
                      TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              hintText: 'e.g., 2 month checkup'),
                          maxLines: 2),
                      const SizedBox(height: 12),
                      ListTile(
                          leading: const Icon(PhosphorIconsLight.calendar,
                              color: AppColors.primary),
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
                          text: 'Save',
                          onPressed: () async {
                              if (valueController.text.isEmpty) return;
                              setD(() => isSaving = true);
                              try {
                                await ref
                                    .read(apiClientProvider)
                                    .createGrowthRecord(babyMonId!, {
                                  'type': _selectedMetric,
                                  'value':
                                      double.parse(valueController.text),
                                  'unit': _metricUnit(_selectedMetric),
                                  'notes': notesController.text.isNotEmpty
                                      ? notesController.text
                                      : null,
                                  'measuredAt':
                                      selectedDate.toIso8601String()
                                });
                                await loadData();
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                setD(() => isSaving = false);
                                if (ctx.mounted) showError(ctx, e);
                              }
                            },
                          isLoading: isSaving,
                          fullWidth: true,
                          semanticLabel: 'Save growth record'),
                    ]))));
  }
}
