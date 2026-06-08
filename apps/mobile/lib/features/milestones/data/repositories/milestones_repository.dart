import 'package:dio/dio.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/milestone.dart';

class MilestonesRepository {
  final ApiService _apiService = ApiService();

  Future<List<Milestone>> getMilestones(String babyMonId) async {
    try {
      final response = await _apiService.get(
        '/milestones',
        queryParameters: {'babyMonId': babyMonId},
      );
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data.map((json) => Milestone.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load milestones: ${e.message}');
    }
  }

  Future<Milestone> createMilestone(Milestone milestone) async {
    try {
      final response = await _apiService.post(
        '/milestones',
        data: milestone.toJson(),
      );
      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create milestone: ${e.message}');
    }
  }

  Future<Milestone> updateMilestone(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/milestones/$id', data: data);
      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update milestone: ${e.message}');
    }
  }

  Future<void> deleteMilestone(String id) async {
    try {
      await _apiService.delete('/milestones/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete milestone: ${e.message}');
    }
  }
}
