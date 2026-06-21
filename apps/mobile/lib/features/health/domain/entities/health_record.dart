import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/utils/json_utils.dart';

/// Unified display entry for both [HealthRecord]s and flattened allergy events.
typedef HealthDisplayEntry = ({
  String id,
  String category,
  String? title,
  dynamic value,
  String? unit,
  DateTime? happenedAt,
  String? notes,
  bool isAllergyEvent,
});

/// All known health record categories with display properties.
enum HealthCategory {
  weight('WEIGHT', 'Weight', PhosphorIconsLight.scales),
  height('HEIGHT', 'Height', PhosphorIconsLight.ruler),
  headCircumference('HEAD_CIRCUMFERENCE', 'Head\nCircumference', PhosphorIconsLight.userCircle),
  temperature('TEMPERATURE', 'Body Temp', PhosphorIconsLight.thermometer),
  hospital('HOSPITAL', 'Hospital', PhosphorIconsLight.building),
  clinic('CLINIC', 'Clinic', PhosphorIconsLight.stethoscope),
  injury('INJURY', 'Injury', PhosphorIconsLight.bandaids),
  bowelMovement('BOWEL_MOVEMENT', 'Bowel Movement', PhosphorIconsLight.toilet),
  vaccination('VACCINATION', 'Vaccination', PhosphorIconsLight.syringe),
  allergy('ALLERGY', 'Allergy', PhosphorIconsLight.warningCircle),
  other('OTHER', 'Other', PhosphorIconsLight.note),
  allergyEvent('ALLERGY_EVENT', 'Allergy', PhosphorIconsLight.warning);

  const HealthCategory(this.apiKey, this.label, this.icon);

  /// The API-facing category string (e.g. 'WEIGHT').
  final String apiKey;

  /// Human-readable display label.
  final String label;

  /// Phosphor icon for this category.
  final IconData icon;

  /// Metric unit for measurement categories.
  String? get metricUnit {
    switch (this) {
      case HealthCategory.weight: return 'kg';
      case HealthCategory.height: return 'cm';
      case HealthCategory.headCircumference: return 'cm';
      case HealthCategory.temperature: return '\u00b0C';
      default: return null;
    }
  }

  /// Imperial unit for measurement categories.
  String? get imperialUnit {
    switch (this) {
      case HealthCategory.weight: return 'lbs';
      case HealthCategory.height: return 'in';
      case HealthCategory.headCircumference: return 'in';
      case HealthCategory.temperature: return '\u00b0F';
      default: return null;
    }
  }

  /// Minor (sub-unit) for the measurement dial.
  String get minorUnit {
    switch (this) {
      case HealthCategory.weight: return 'g';
      case HealthCategory.height: return 'mm';
      case HealthCategory.headCircumference: return 'mm';
      case HealthCategory.temperature: return '.0';
      default: return '';
    }
  }

  /// Maximum value for the major dial.
  int get dialMax => this == HealthCategory.temperature ? 50 : 200;

  /// Maximum value for the minor dial.
  int get dialMinorMax => this == HealthCategory.weight ? 999 : 9;

  /// Step for the minor dial.
  int get dialMinorStep => this == HealthCategory.weight ? 5 : 1;

  /// Decimal places for computed value display.
  int get decimalPlaces => this == HealthCategory.weight ? 3 : 1;

  /// Compute the measurement value from major + minor dial positions.
  double computeValue(int major, int minor) {
    switch (this) {
      case HealthCategory.weight: return major + (minor / 1000.0);
      default: return major + (minor / 10.0);
    }
  }

  /// Resolve unit from metric/imperial preference.
  String unitFor(bool isMetric) =>
      (isMetric ? metricUnit : imperialUnit) ?? '';

  /// Whether this category is a measurement (has a dial input).
  bool get isMeasurement => metricUnit != null;

  /// Whether this category is an event type (not a measurement).
  bool get isEvent => !isMeasurement;

  static HealthCategory? fromApiKey(String? key) {
    if (key == null) return null;
    for (final c in values) {
      if (c.apiKey == key) return c;
    }
    return null;
  }
}

class HealthRecord {
  final String id;
  final String category;
  final String? title;
  final dynamic value;
  final String? unit;
  final String? notes;
  final DateTime? happenedAt;

  const HealthRecord({
    required this.id,
    required this.category,
    this.title,
    this.value,
    this.unit,
    this.notes,
    this.happenedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: parseString(json['id']) ?? '',
      category: parseString(json['category']) ?? '',
      title: parseString(json['title']),
      value: json['value'],
      unit: parseString(json['unit']),
      notes: parseString(json['notes']),
      happenedAt: parseString(json['happenedAt']) != null
          ? DateTime.tryParse(parseString(json['happenedAt'])!)?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'value': value,
      'unit': unit,
      'notes': notes,
      'happenedAt': happenedAt?.toIso8601String(),
    };
  }

  /// Numeric value parsed from [value].
  double? get numericValue {
    final v = value;
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  /// Convert to a [HealthDisplayEntry] for the unified record list.
  HealthDisplayEntry toDisplayEntry() => (
    id: id,
    category: category,
    title: title,
    value: value,
    unit: unit,
    happenedAt: happenedAt,
    notes: notes,
    isAllergyEvent: false,
  );
}
