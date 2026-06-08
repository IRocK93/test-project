import 'package:dio/dio.dart';
import '../../../../data/services/api_service.dart';
import '../../domain/entities/health_record.dart';

class HealthRepository {
  final ApiService _apiService = ApiService();

  Future<List<HealthRecord>> getHealthRecords(String babyMonId) async {
    try {
      final response = await _apiService.get(
        '/health-records',
        queryParameters: {'babyMonId': babyMonId},
      );
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data.map((json) => HealthRecord.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load health records: ${e.message}');
    }
  }

  Future<HealthRecord> createHealthRecord(HealthRecord record) async {
    try {
      final response = await _apiService.post(
        '/health-records',
        data: record.toJson(),
      );
      return HealthRecord.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create health record: ${e.message}');
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    try {
      await _apiService.delete('/health-records/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete health record: ${e.message}');
    }
  }
}
