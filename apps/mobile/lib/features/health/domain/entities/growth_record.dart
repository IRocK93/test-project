import 'package:baby_mon/core/utils/json_utils.dart';

class GrowthRecord {
  final String id;
  final String type;
  final double value;
  final String? unit;
  final String? notes;
  final DateTime? measuredAt;

  const GrowthRecord({
    required this.id,
    required this.type,
    required this.value,
    this.unit,
    this.notes,
    this.measuredAt,
  });

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    return GrowthRecord(
      id: parseString(json['id']) ?? '',
      type: parseString(json['type']) ?? 'WEIGHT',
      value: parseDouble(json['value']) ?? 0.0,
      unit: parseString(json['unit']),
      notes: parseString(json['notes']),
      measuredAt: parseString(json['measuredAt']) != null
          ? DateTime.tryParse(parseString(json['measuredAt'])!)?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'unit': unit,
      'notes': notes,
      'measuredAt': measuredAt?.toIso8601String(),
    };
  }
}
