import 'package:dio/dio.dart';
import '../../../../core/data/api_client.dart';
import '../../domain/entities/health_record.dart';

/// @migrated — now uses ApiClient instead of deprecated ApiService
class HealthRepository {
  final ApiClient _api;

  HealthRepository(this._api);

  Future<List<HealthRecord>> getHealthRecords(String babyMonId) async {
    try {
      final response = await _api.get('/api/baby-mons/$babyMonId/health-records');
      final data = response.data;
      final items = data is Map ? (data['items'] as List<dynamic>? ?? []) : (data as List<dynamic>? ?? []);
      return items.map((json) => HealthRecord.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load health records: ${e.message}');
    }
  }

  Future<HealthRecord> createHealthRecord(String babyMonId, Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/api/baby-mons/$babyMonId/health-records', data: data);
      return HealthRecord.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create health record: ${e.message}');
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    try {
      await _api.delete('/api/health-records/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete health record: ${e.message}');
    }
  }
}
