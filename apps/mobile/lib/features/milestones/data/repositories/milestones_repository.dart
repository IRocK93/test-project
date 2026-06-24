import 'package:dio/dio.dart';
import '../../../../core/data/api_client.dart';
import '../../domain/entities/milestone.dart';

/// @migrated — now uses ApiClient instead of deprecated ApiService
class MilestonesRepository {
  final ApiClient _api;

  MilestonesRepository(this._api);

  Future<List<Milestone>> getMilestones(String babyMonId) async {
    try {
      final response = await _api.get(
        '/api/baby-mons/$babyMonId/milestones',
      );
      final data = response.data;
      final items = data is Map ? (data['items'] as List<dynamic>? ?? []) : (data as List<dynamic>? ?? []);
      return items.map((json) => Milestone.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load milestones: ${e.message}');
    }
  }

  Future<Milestone> createMilestone(String babyMonId, Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        '/api/baby-mons/$babyMonId/milestones',
        data: data,
      );
      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create milestone: ${e.message}');
    }
  }

  Future<Milestone> updateMilestone(String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.patch('/api/milestones/$id', data: data);
      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update milestone: ${e.message}');
    }
  }

  Future<void> deleteMilestone(String id) async {
    try {
      await _api.delete('/api/milestones/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete milestone: ${e.message}');
    }
  }
}
