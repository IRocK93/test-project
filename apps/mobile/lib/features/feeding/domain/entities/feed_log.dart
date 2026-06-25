import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/utils/json_utils.dart';

/// All known feed types with display properties.
enum FeedType {
  breastmilk('BREASTMILK', 'Breastmilk', 'Breast', PhosphorIconsLight.drop, Color(0xFF42A5F5)),
  formula('FORMULA', 'Formula', 'Formula', PhosphorIconsLight.jar, Color(0xFFFFA726)),
  solid('SOLID', 'Solid', 'Solid', PhosphorIconsLight.bowlFood, Color(0xFF4CAF50));

  const FeedType(this.apiKey, this.label, this.shortLabel, this.icon, this.color);

  /// The API-facing type string (e.g. 'BREASTMILK').
  final String apiKey;

  /// Human-readable display label.
  final String label;

  /// Short label for chart legends.
  final String shortLabel;

  /// Phosphor icon for this type.
  final IconData icon;

  /// Display color for this type.
  final Color color;

  /// Unit for this feed type (given metric/imperial preference).
  String unit(bool isMetric) {
    switch (this) {
      case FeedType.solid: return 'g';
      default: return isMetric ? 'ml' : 'oz';
    }
  }

  static FeedType? fromApiKey(String? key) {
    if (key == null) return null;
    for (final t in values) {
      if (t.apiKey == key) return t;
    }
    return null;
  }
}

class FeedLog {
  final String id;
  final String type;
  final double? amount;
  final String? unit;
  final String? notes;
  final DateTime? happenedAt;
  final String? syncStatus;

  const FeedLog({
    required this.id,
    required this.type,
    this.amount,
    this.unit,
    this.notes,
    this.happenedAt,
    this.syncStatus,
  });

  factory FeedLog.fromJson(Map<String, dynamic> json) {
    return FeedLog(
      id: parseString(json['id']) ?? '',
      type: parseString(json['type']) ?? 'BREASTMILK',
      amount: parseDouble(json['amount']),
      unit: parseString(json['unit']),
      notes: parseString(json['notes']),
      happenedAt: parseString(json['happenedAt']) != null
          ? DateTime.tryParse(parseString(json['happenedAt'])!)
          : null,
      syncStatus: parseString(json['syncStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'unit': unit,
      'notes': notes,
      'happenedAt': happenedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }
}
