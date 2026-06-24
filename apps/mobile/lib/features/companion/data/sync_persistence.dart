import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists local-first pending changes so they survive app kill / crash.
/// Cleared only after confirmed successful sync.
class SyncPersistence {
  static const _routinePrefix = 'sync_routine_';
  static const _achievePrefix = 'sync_achieve_';
  static const _unachievePrefix = 'sync_unachieve_';

  // ── Routine ──

  static Future<Set<String>> loadRoutine(String babyMonId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_routinePrefix$babyMonId');
    if (json == null) return <String>{};
    try {
      return Set<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> saveRoutine(String babyMonId, Set<String> steps) async {
    final prefs = await SharedPreferences.getInstance();
    if (steps.isEmpty) {
      await prefs.remove('$_routinePrefix$babyMonId');
    } else {
      await prefs.setString('$_routinePrefix$babyMonId', jsonEncode(steps.toList()));
    }
  }

  // ── Milestones: Achieve ──

  static Future<Set<String>> loadAchievements(String babyMonId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_achievePrefix$babyMonId');
    if (json == null) return <String>{};
    try {
      return Set<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> saveAchievements(String babyMonId, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await prefs.remove('$_achievePrefix$babyMonId');
    } else {
      await prefs.setString('$_achievePrefix$babyMonId', jsonEncode(ids.toList()));
    }
  }

  // ── Milestones: Unachieve ──

  static Future<Set<String>> loadUnachievements(String babyMonId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_unachievePrefix$babyMonId');
    if (json == null) return <String>{};
    try {
      return Set<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> saveUnachievements(String babyMonId, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await prefs.remove('$_unachievePrefix$babyMonId');
    } else {
      await prefs.setString('$_unachievePrefix$babyMonId', jsonEncode(ids.toList()));
    }
  }

  /// True if any pending data exists for this baby.
  static Future<bool> hasPending(String babyMonId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_routinePrefix$babyMonId') ||
        prefs.containsKey('$_achievePrefix$babyMonId') ||
        prefs.containsKey('$_unachievePrefix$babyMonId');
  }

  /// Clear all pending data for this baby (called after successful sync).
  static Future<void> clearAll(String babyMonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_routinePrefix$babyMonId');
    await prefs.remove('$_achievePrefix$babyMonId');
    await prefs.remove('$_unachievePrefix$babyMonId');
  }
}
