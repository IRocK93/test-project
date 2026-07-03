import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../utils/json_utils.dart';
import 'package:baby_mon/core/constants/constants.dart';


/// A multi-column wheel picker shown as a bottom sheet.
/// Each column has its own set of options.
/// Supports single-column and multi-column modes (e.g., Time: Hours | Minutes | AM/PM).
///
/// Usage:
/// ```dart
/// final result = await WheelPickerBottomSheet.show<int>(
///   context: context,
///   title: 'Select Range',
///   columns: [
///     WheelColumn(label: 'Days', options: List.generate(10, (i) => WheelOption(value: i + 1, label: '${i + 1}'))),
///   ],
/// );
/// ```
class WheelPickerBottomSheet {
  /// Shows a single-column wheel picker.
  /// Returns the selected value or null if cancelled.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<WheelColumn<T>> columns,
    T? initialValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WheelPickerSheet<T>(
        title: title,
        columns: columns,
        initialValue: initialValue,
      ),
    );
  }

  /// Shows a time picker with Hours (1-12), Minutes (00-59), and AM/PM columns.
  static Future<TimeOfDay> showTime({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    final now = TimeOfDay.now();
    final init = initialTime ?? now;
    final hour12 = init.hour == 0 ? 12 : (init.hour > 12 ? init.hour - 12 : init.hour);
    final period = init.hour < 12 ? 'AM' : 'PM';

    final result = await showModalBottomSheet<List>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WheelPickerSheet<String>(
        title: context.l10n.wheelPickerSelectTime,
        columns: [
          WheelColumn<String>(
            label: context.l10n.wheelPickerHour,
            options: List.generate(12, (i) => WheelOption(value: '${i + 1}', label: '${i + 1}')),
            initialValue: '$hour12',
          ),
          WheelColumn<String>(
            label: context.l10n.wheelPickerMinute,
            options: List.generate(60, (i) => WheelOption(value: i.toString().padLeft(2, '0'), label: i.toString().padLeft(2, '0'))),
            initialValue: init.minute.toString().padLeft(2, '0'),
          ),
          WheelColumn<String>(
            label: '',
            options: ['AM', 'PM'].map((p) => WheelOption(value: p, label: p)).toList(),
            initialValue: period,
          ),
        ],
      ),
    );
    if (result == null || result.length < 3) return init;
    final h = int.parse(parseString(result[0]) ?? '1');
    final m = int.parse(parseString(result[1]) ?? '0');
    final ampm = parseString(result[2]) ?? 'AM';
    // Convert 12-hour to 24-hour
    final hour24 = ampm == 'AM' ? (h == 12 ? 0 : h) : (h == 12 ? 12 : h + 12);
    return TimeOfDay(hour: hour24, minute: m);
  }

  /// Shows a measurement wheel picker with 2 wheels: major value + decimal (.0-.9).
  /// Adapts ranges based on metric/imperial.
  /// Returns the selected value as a double.
  static Future<double?> showMeasurement({
    required BuildContext context,
    required String type,
    required bool isMetric,
    double? initialValue,
  }) async {
    int majorVal = initialValue?.floor() ?? 0;
    final int decimalVal = initialValue != null ? ((initialValue - majorVal) * 10).round() : 0;
    int maxMajor; String majorLabel;
    switch (type) {
      case 'WEIGHT':
        if (isMetric) { maxMajor = 50; majorLabel = 'kg'; } else { maxMajor = 110; majorLabel = 'lb'; }
      case 'HEIGHT':
        if (isMetric) { maxMajor = 150; majorLabel = 'cm'; } else { maxMajor = 60; majorLabel = 'in'; }
      case 'HEAD_CIRCUMFERENCE':
        if (isMetric) { maxMajor = 70; majorLabel = 'cm'; } else { maxMajor = 28; majorLabel = 'in'; }
      default:
        maxMajor = 200; majorLabel = '';
    }
    majorVal = majorVal.clamp(0, maxMajor);
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WheelPickerSheet<String>(
        title: context.l10n.wheelPickerSelectMeasurement(type, majorLabel),
        columns: [
          WheelColumn<String>(label: majorLabel, options: List.generate(maxMajor + 1, (i) => WheelOption(value: '$i', label: '$i')), initialValue: '$majorVal'),
          WheelColumn<String>(label: '.', options: List.generate(10, (i) => WheelOption(value: '$i', label: '.$i')), initialValue: '${decimalVal.clamp(0, 9)}'),
        ],
      ),
    );
    if (result == null || result.length < 2) return null;
    return (int.tryParse(result[0]) ?? 0) + (int.tryParse(result[1]) ?? 0) / 10.0;
  }
  /// Combined sleep range + unit picker in one window.
  static Future<MapEntry<int, String>?> showCombinedSleepRange({
    required BuildContext context,
    int initialRange = 3,
    String initialUnit = 'Days',
  }) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WheelPickerSheet<String>(
        title: context.l10n.wheelPickerSelectRange,
        columns: [
          WheelColumn<String>(label: context.l10n.wheelPickerRange, options: List.generate(10, (i) => WheelOption(value: '${i + 1}', label: '${i + 1}')), initialValue: '$initialRange'),
          WheelColumn<String>(label: context.l10n.wheelPickerUnit, options: [context.l10n.daysUnitLabel, context.l10n.weeksUnitLabel, context.l10n.monthsUnitLabel].map((u) => WheelOption(value: u, label: u)).toList(), initialValue: initialUnit),
        ],
      ),
    );
    if (result == null || result.length < 2) return null;
    return MapEntry(int.tryParse(result[0]) ?? initialRange, result[1]);
  }
  /// Feeding amount wheel picker: whole ml/oz + decimal (.0-.9).
  static Future<double?> showFeedingAmount({
    required BuildContext context,
    required bool isMetric,
    required String feedType,
    double? initialValue,
  }) async {
    int majorVal = initialValue?.floor() ?? 0;
    final int decimalVal = initialValue != null ? ((initialValue - majorVal) * 10).round() : 0;
    late int maxMajor;
    late String majorLabel;
    late String title;
    final l10n = context.l10n;
    if (feedType == 'SOLID') {
      maxMajor = isMetric ? 500 : 18;
      majorLabel = isMetric ? 'g' : 'oz';
      title = l10n.amountLabelG;
    } else {
      maxMajor = isMetric ? 350 : 12;
      majorLabel = isMetric ? 'ml' : 'oz';
      title = l10n.amountLabelUnit(majorLabel);
    }
    majorVal = majorVal.clamp(0, maxMajor);
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WheelPickerSheet<String>(
        title: title,
        columns: [
          WheelColumn<String>(label: majorLabel, options: List.generate(maxMajor + 1, (i) => WheelOption(value: '$i', label: '$i')), initialValue: '$majorVal'),
          WheelColumn<String>(label: context.l10n.wheelPickerUnit, options: List.generate(10, (i) => WheelOption(value: '$i', label: '.$i')), initialValue: '${decimalVal.clamp(0, 9)}'),
        ],
      ),
    );
    if (result == null || result.length < 2) return null;
    return (int.tryParse(result[0]) ?? 0) + (int.tryParse(result[1]) ?? 0) / 10.0;
  }
}

/// A single column in a wheel picker.
class WheelColumn<T> {
  final String label;
  final List<WheelOption<T>> options;
  final T? initialValue;

  const WheelColumn({
    required this.label,
    required this.options,
    this.initialValue,
  });
}

/// A single option in a wheel column.
class WheelOption<T> {
  final T value;
  final String label;

  const WheelOption({required this.value, required this.label});
}

class _WheelPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<WheelColumn<T>> columns;
  final T? initialValue;

  const _WheelPickerSheet({required this.title, required this.columns, this.initialValue});

  @override
  State<_WheelPickerSheet<T>> createState() => _WheelPickerSheetState<T>();
}

class _WheelPickerSheetState<T> extends State<_WheelPickerSheet<T>> {
  late List<FixedExtentScrollController> _controllers;
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _controllers = widget.columns.map((col) {
      final initIdx = col.initialValue != null
          ? col.options.indexWhere((opt) => opt.value == col.initialValue)
          : 0;
      return FixedExtentScrollController(initialItem: initIdx >= 0 ? initIdx : 0);
    }).toList();
    _selectedIndices = _controllers.map((c) => c.initialItem).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalWidth = MediaQuery.of(context).size.width - 32;
    final colWidth = widget.columns.length > 1
        ? (totalWidth - 48) / widget.columns.length
        : totalWidth - 24;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(color: context.dividerColor, borderRadius: BorderRadius.circular(2)),
          ),
          // Title + Done button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () {
                    if (widget.columns.length == 1) {
                      final idx = _selectedIndices[0];
                      final selected = widget.columns[0].options[idx].value;
                      Navigator.pop(context, selected);
                    } else {
                      // Multi-column: return list of selected values
                      final selections = _selectedIndices.asMap().map((i, idx) =>
                        MapEntry(i, widget.columns[i].options[idx].value));
                      Navigator.pop(context, selections.values.toList());
                    }
                  },
                  child: Text(context.l10n.doneLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Wheel columns
          SizedBox(
            height: 216,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.columns.length, (ci) {
                final col = widget.columns[ci];
                return SizedBox(
                  width: colWidth,
                  child: Column(children: [
                    // Column label
                    if (col.label.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(col.label, style: TextStyle(fontSize: 11, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                      ),
                    // Wheel list
                    Expanded(
                      child: Stack(
                        children: [
                          // Selection highlight bar
                          Center(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          ListWheelScrollView(
                            controller: _controllers[ci],
                            itemExtent: 36,
                            diameterRatio: 1.5,
                            useMagnifier: false,
                            onSelectedItemChanged: (idx) {
                              setState(() => _selectedIndices[ci] = idx);
                            },
                            children: col.options.map((opt) => Center(
                              child: Text(
                                opt.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: _selectedIndices[ci] == col.options.indexOf(opt) ? FontWeight.w600 : FontWeight.normal,
                                  color: _selectedIndices[ci] == col.options.indexOf(opt) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ]),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}