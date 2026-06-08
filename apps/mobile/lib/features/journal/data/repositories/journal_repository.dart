import 'package:dio/dio.dart';
import '../../../../data/services/api_service.dart';
import '../../domain/entities/journal_entry.dart';

class JournalRepository {
  final ApiService _apiService = ApiService();

  Future<List<JournalEntry>> getJournalEntries(String babyMonId) async {
    try {
      // Fetch all three sources in parallel
      final results = await Future.wait([
        _fetchMilestones(babyMonId),
        _fetchFeedLogs(babyMonId),
        _fetchHealthRecords(babyMonId),
      ]);

      // Flatten and merge all entries
      final List<JournalEntry> allEntries = [
        ...results[0], // milestones
        ...results[1], // feed logs
        ...results[2], // health records
      ];

      // Sort by date descending (newest first)
      allEntries.sort((a, b) => b.date.compareTo(a.date));

      return allEntries;
    } on DioException catch (e) {
      throw Exception('Failed to load journal entries: ${e.message}');
    }
  }

  Future<List<JournalEntry>> _fetchMilestones(String babyMonId) async {
    try {
      final response = await _apiService.get(
        '/milestones',
        queryParameters: {'babyMonId': babyMonId},
      );
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data.map((json) => JournalEntry.fromMilestone(json)).toList();
    } catch (e) {
      // Return empty list if milestones fetch fails
      return [];
    }
  }

  Future<List<JournalEntry>> _fetchFeedLogs(String babyMonId) async {
    try {
      final response = await _apiService.get(
        '/feed-logs',
        queryParameters: {'babyMonId': babyMonId},
      );
      final List<dynamic> data = response.data is List 
          ? response.data 
          : (response.data['data'] ?? []);
      return data.map((json) => JournalEntry.fromFeedLog(json)).toList();
    } catch (e) {
      // Return empty list if feed logs fetch fails
      return [];
    }
  }

  Future<List<JournalEntry>> _fetchHealthRecords(String babyMonId) async {
    try {
      final response = await _apiService.get(
        '/health-records',
        queryParameters: {'babyMonId': babyMonId},
      );
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data.map((json) => JournalEntry.fromHealthRecord(json)).toList();
    } catch (e) {
      // Return empty list if health records fetch fails
      return [];
    }
  }
}
