import 'package:flutter/material.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Typed enum for sleep session types, replacing hardcoded 'NIGHT'/'NAP' strings.
enum SleepType {
  night('NIGHT', 'Night sleep', PhosphorIconsLight.moon, Color(0xFF5C6BC0)),
  nap('NAP', 'Nap', PhosphorIconsLight.sun, Color(0xFFFFA726));

  const SleepType(this.apiKey, this.label, this.icon, this.color);

  /// API key sent to the backend.
  final String apiKey;

  /// Human-readable label for display.
  final String label;

  /// Icon associated with this sleep type.
  final IconData icon;

  /// Color for UI elements (tiles, chart legend).
  final Color color;

  /// Resolve a [SleepType] from its API key string.
  static SleepType? fromApiKey(String? key) {
    if (key == null) return null;
    for (final t in SleepType.values) {
      if (t.apiKey == key) return t;
    }
    return null;
  }

  /// Whether this sleep type represents a night-time sleep session.
  bool get isNight => this == SleepType.night;
}

/// Typed enum for sleep quality, replacing hardcoded 'GREAT'/'GOOD'/'FAIR'/'POOR' strings.
enum SleepQuality {
  great('GREAT', 'Great', 5, 4.0, Color(0xFF4CAF50)),
  good('GOOD', 'Good', 4, 3.0, Color(0xFF4DD0C1)),
  fair('FAIR', 'Fair', 2, 2.0, Color(0xFFFFA726)),
  poor('POOR', 'Poor', 1, 1.0, Color(0xFFE53935));

  const SleepQuality(this.apiKey, this.label, this.apiNumericValue, this.avgScoreValue, this.color);

  /// API key string sent to the backend (e.g. 'GREAT', 'GOOD').
  final String apiKey;

  /// Human-readable display label (e.g. 'Great', 'Good').
  final String label;

  /// Numeric value sent to the backend API (e.g. 5 for great).
  final int apiNumericValue;

  /// Score used when computing average quality across multiple logs.
  final double avgScoreValue;

  /// Thematic color for charts and UI elements.
  final Color color;

  /// Resolve a [SleepQuality] from its API key string.
  static SleepQuality? fromApiKey(String? key) {
    if (key == null) return null;
    for (final q in SleepQuality.values) {
      if (q.apiKey == key) return q;
    }
    return null;
  }

  /// Resolve a [SleepQuality] from a numeric value (handles both int and string).
  static SleepQuality? fromNumericValue(dynamic value) {
    final n = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (n == null) return null;
    for (final q in SleepQuality.values) {
      if (q.apiNumericValue == n) return q;
    }
    return null;
  }

  /// Resolve quality from either a string key ('GREAT') or numeric value (5).
  /// Falls back to [SleepQuality.good] if unrecognised.
  static SleepQuality resolve(String? quality) {
    if (quality == null || quality.isEmpty) return SleepQuality.good;
    // Try string match first.
    final byKey = fromApiKey(quality);
    if (byKey != null) return byKey;
    // Try numeric match.
    final byNum = fromNumericValue(quality);
    if (byNum != null) return byNum;
    return SleepQuality.good;
  }

  /// Resolve a [SleepQuality] from an average score (0.0–4.0 scale).
  /// Returns [SleepQuality.great] for scores >= 3.5, down to [SleepQuality.poor].
  static SleepQuality fromScore(double score) {
    if (score >= 3.5) return SleepQuality.great;
    if (score >= 2.5) return SleepQuality.good;
    if (score >= 1.5) return SleepQuality.fair;
    if (score >= 0.5) return SleepQuality.poor;
    return SleepQuality.good;
  }
}

class SleepLog {
  final String id;
  final String? type;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? quality;
  final String? notes;

  const SleepLog({
    required this.id,
    this.type,
    this.startTime,
    this.endTime,
    this.quality,
    this.notes,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: parseString(json['id']) ?? '',
      type: parseString(json['type']),
      startTime: parseString(json['startTime']) != null
          ? DateTime.tryParse(parseString(json['startTime'])!)
          : null,
      endTime: parseString(json['endTime']) != null
          ? DateTime.tryParse(parseString(json['endTime'])!)
          : null,
      quality: json['quality']?.toString(),
      notes: parseString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'quality': quality,
      'notes': notes,
    };
  }

  /// Duration of this sleep session.
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  /// Creates a copy with the given fields replaced.
  SleepLog copyWith({
    String? type, DateTime? startTime, DateTime? endTime,
    String? quality, String? notes,
  }) {
    return SleepLog(
      id: id, type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }

  /// Whether this is a nap (daytime, short) vs night sleep.
  bool get isNap {
    if (duration == null) return false;
    if (duration!.inHours >= 4) return false;
    if (startTime == null) return false;
    return startTime!.hour >= 6 && startTime!.hour < 20;
  }
}
