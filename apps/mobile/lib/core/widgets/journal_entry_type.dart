import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/app_colors.dart';

/// Enum of journal entry types — replaces the fragile
/// `f.split('_').map(...).join(' ')` formatter and the duplicated
/// `_iconForEntryType` / `_colorForEntryType` switches in the old
/// journal screen.
enum JournalEntryType {
  milestone(
    'Milestone',
    PhosphorIconsLight.trophy,
    Color(0xFF7C5CFC),
  ),
  feedLog(
    'Feeding',
    PhosphorIconsLight.bowlFood,
    AppColors.primary,
  ),
  healthRecord(
    'Health',
    PhosphorIconsLight.stethoscope,
    AppColors.secondary,
  ),
  system(
    'System',
    PhosphorIconsLight.info,
    Color(0xFF7C5CFC),
  );

  const JournalEntryType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Parse a backend string ("MILESTONE", "FEED_LOG", ...) into the
  /// matching enum value. Falls back to [system] for unknown strings.
  static JournalEntryType fromString(String? raw) {
    switch (raw) {
      case 'MILESTONE':
        return JournalEntryType.milestone;
      case 'FEED_LOG':
        return JournalEntryType.feedLog;
      case 'HEALTH_RECORD':
        return JournalEntryType.healthRecord;
      case 'SYSTEM':
        return JournalEntryType.system;
      default:
        return JournalEntryType.system;
    }
  }

  /// Stable string key used in API requests and chip selection.
  String get apiKey {
    switch (this) {
      case JournalEntryType.milestone:
        return 'MILESTONE';
      case JournalEntryType.feedLog:
        return 'FEED_LOG';
      case JournalEntryType.healthRecord:
        return 'HEALTH_RECORD';
      case JournalEntryType.system:
        return 'SYSTEM';
    }
  }
}
