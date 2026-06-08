import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// E1 — Growth Chart Tracking: Visualizes baby growth metrics over time.
///
/// Displays weight (kg), height (cm), and head circumference (cm) on interactive
/// fl_chart LineCharts with date-based X-axis and metric values on the Y-axis.
/// Parents can filter between metrics via chips, add new measurements via bottom sheet,
/// and swipe-delete records. The chart auto-scales and shows tooltips on touch.
/// Growth data is also surfaced on the Dashboard as a "Latest Weight" summary card.
///
/// API: GET/POST/DELETE /api/baby-mons/:id/growth
/// Dependencies: fl_chart ^0.69.0
/// Integration points: HealthScreen (navigation card), DashboardScreen (summary card)
class GrowthChartScreen extends ConsumerStatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen> {
  /// The currently selected BabyMon ID
  String? _babyMonId;

  /// All growth records fetched from the API
  List<Map<String, dynamic>> _records = [];

  /// Whether data is currently loading
  bool _isLoading = true;

  /// Which metric is currently displayed on the chart
  String _selectedMetric = 'WEIGHT';

  /// Available metric types for the chart
  final List<String> _metrics = ['WEIGHT', 'HEIGHT', 'HEAD_CIRCUMFERENCE'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  /// Loads the BabyMon ID from storage then fetches growth records
  Future<void> _loadData() async {
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null) return;
    _babyMonId = id;
    await _fetchGrowthRecords();
  }

  /// Fetches growth records filtered by the currently selected metric type
  Future<void> _fetchGrowthRecords() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getGrowthRecords(
        _babyMonId!,
        type: _selectedMetric,
      );
      setState(() {
        _records = (response.data as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load growth data: $e')),
        );
      }
    }
  }

  /// Deletes a growth record with user confirmation
  Future<void> _deleteRecord(String recordId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Growth Record'),
        content: const Text('Are you sure you want to delete this measurement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(apiClientProvider).deleteGrowthRecord(_babyMonId!, recordId);
      setState(() => _records.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Growth record deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Returns a human-readable label for a metric type
  String _metricLabel(String metric) {
    switch (metric) {
      case 'WEIGHT':
        return 'Weight (kg)';
      case 'HEIGHT':
        return 'Height (cm)';
      case 'HEAD_CIRCUMFERENCE':
        return 'Head (cm)';
      default:
        return metric;
    }
  }

  /// Returns a unit label for a metric type
  String _metricUnit(String metric) {
    switch (metric) {
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

  /// Returns a filter chip label for a metric type
  String _metricChipLabel(String metric) {
    switch (metric) {
      case 'WEIGHT':
        return 'Weight';
      case 'HEIGHT':
        return 'Height';
      case 'HEAD_CIRCUMFERENCE':
        return 'Head';
      default:
        return metric;
    }
  }

  /// Builds the fl_chart LineChart widget from growth records
  Widget _buildChart() {
    if (_records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No growth data yet',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Extract data points sorted by date
    final sorted = List<Map<String, dynamic>>.from(_records)
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a['measuredAt']?.toString() ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['measuredAt']?.toString() ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });

    final spots = sorted.map((r) {
      final date = DateTime.tryParse(r['measuredAt']?.toString() ?? '');
      final value = double.tryParse(r['value']?.toString() ?? '0') ?? 0;
      return FlSpot(
        date?.millisecondsSinceEpoch.toDouble() ?? 0,
        value,
      );
    }).toList();

    // Calculate Y-axis range
    final values = spots.map((s) => s.y).toList();
    final minY = values.isEmpty ? 0 : (values.reduce((a, b) => a < b ? a : b) * 0.9);
    final maxY = values.isEmpty ? 10 : (values.reduce((a, b) => a > b ? a : b) * 1.1);

    // Calculate X-axis range
    final xValues = spots.map((s) => s.x).toList();
    final minX = xValues.isEmpty ? 0 : xValues.reduce((a, b) => a < b ? a : b);
    final maxX = xValues.isEmpty ? 1 : xValues.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: minX.toDouble(),
        maxX: maxX.toDouble(),
        minY: minY.toDouble(),
        maxY: maxY.toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // Only show label for every other data point to avoid crowding
                final index = spots.indexWhere((s) => s.x == value);
                if (index % 2 != 0) return const SizedBox.shrink();
                return Text(
                  DateFormat('MM/dd').format(date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.primary,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)} ${_metricUnit(_selectedMetric)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Growth Chart')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Metric selector filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _metrics.map((metric) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_metricChipLabel(metric)),
                          selected: _selectedMetric == metric,
                          onSelected: (_) {
                            setState(() => _selectedMetric = metric);
                            _fetchGrowthRecords();
                          },
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      )).toList(),
                    ),
                  ),
                ),

                // Chart area
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchGrowthRecords,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Chart title
                          Text(
                            _metricLabel(_selectedMetric),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Expanded(child: _buildChart()),
                        ],
                      ),
                    ),
                  ),
                ),

                // Record list below chart
                if (_records.isNotEmpty)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        final date = DateTime.tryParse(record['measuredAt']?.toString() ?? '');
                        final value = double.tryParse(record['value']?.toString() ?? '0') ?? 0;
                        return Dismissible(
                          key: Key(record['id'] ?? index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteRecord(record['id'], index),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              child: Icon(
                                _selectedMetric == 'WEIGHT'
                                    ? Icons.monitor_weight
                                    : _selectedMetric == 'HEIGHT'
                                        ? Icons.height
                                        : Icons.face,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              '${value.toStringAsFixed(1)} ${_metricUnit(_selectedMetric)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: date != null
                                ? Text(
                                    DateFormat.yMMMd().format(date),
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows a bottom sheet dialog for creating a new growth record
  void _showAddRecordDialog() {
    final valueController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isSaving = false;

    showModalBottomSheet(
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
              Text('Add ${_metricChipLabel(_selectedMetric)} Record',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              // Metric type selector
              SegmentedButton<String>(
                segments: _metrics.map((m) => ButtonSegment(
                  value: m,
                  label: Text(_metricChipLabel(m)),
                )).toList(),
                selected: {_selectedMetric},
                onSelectionChanged: (s) => setDialogState(() => _selectedMetric = s.first),
              ),
              const SizedBox(height: 12),
              // Value input
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: _metricLabel(_selectedMetric),
                  hintText: _selectedMetric == 'WEIGHT' ? 'e.g., 7.5' : 'e.g., 65',
                  suffixText: _metricUnit(_selectedMetric),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              // Notes input
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g., 2 month checkup',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Date picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
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
              const SizedBox(height: 16),
              // Save button
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (valueController.text.isEmpty) return;
                        setDialogState(() => isSaving = true);
                        try {
                          await ref.read(apiClientProvider).createGrowthRecord(
                            _babyMonId!,
                            {
                              'type': _selectedMetric,
                              'value': double.parse(valueController.text),
                              'unit': _metricUnit(_selectedMetric),
                              'notes': notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null,
                              'measuredAt': selectedDate.toIso8601String(),
                            },
                          );
                          await _fetchGrowthRecords();
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}