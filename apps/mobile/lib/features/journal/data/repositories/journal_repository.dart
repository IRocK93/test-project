import 'package:dio/dio.dart';
import '../../../../core/data/api_client.dart';
import '../../domain/entities/journal_entry.dart';

/// @migrated — now uses ApiClient instead of deprecated ApiService
class JournalRepository {
  final ApiClient _api;

  JournalRepository(this._api);

  Future<List<JournalEntry>> getJournalEntries(String babyMonId) async {
    try {
      final results = await Future.wait([
        _fetchMilestones(babyMonId),
        _fetchFeedLogs(babyMonId),
        _fetchHealthRecords(babyMonId),
      ]);

      final List<JournalEntry> allEntries = [
        ...results[0],
        ...results[1],
        ...results[2],
      ];

      allEntries.sort((a, b) => b.date.compareTo(a.date));
      return allEntries;
    } on DioException catch (e) {
      throw Exception('Failed to load journal entries: ${e.message}');
    }
  }

  Future<List<JournalEntry>> _fetchMilestones(String babyMonId) async {
    try {
      final response = await _api.get('/api/baby-mons/$babyMonId/milestones');
      final data = response.data;
      final items = data is Map ? (data['items'] as List<dynamic>? ?? []) : (data as List<dynamic>? ?? []);
      return items.map((json) => JournalEntry.fromMilestone(json)).toList();
    } catch (_) { return []; }
  }

  Future<List<JournalEntry>> _fetchFeedLogs(String babyMonId) async {
    try {
      final response = await _api.get('/api/baby-mons/$babyMonId/feed-logs');
      final data = response.data;
      final items = data is Map ? (data['items'] as List<dynamic>? ?? []) : (data as List<dynamic>? ?? []);
      return items.map((json) => JournalEntry.fromFeedLog(json)).toList();
    } catch (_) { return []; }
  }

  Future<List<JournalEntry>> _fetchHealthRecords(String babyMonId) async {
    try {
      final response = await _api.get('/api/baby-mons/$babyMonId/health-records');
      final data = response.data;
      final items = data is Map ? (data['items'] as List<dynamic>? ?? []) : (data as List<dynamic>? ?? []);
      return items.map((json) => JournalEntry.fromHealthRecord(json)).toList();
    } catch (_) { return []; }
  }
}
