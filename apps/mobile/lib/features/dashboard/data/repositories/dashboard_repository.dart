import 'package:dio/dio.dart';
import 'package:baby_mon/core/data/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  /// Get all baby mons for the current user
  Future<List<Map<String, dynamic>>> getBabyMons() async {
    try {
      final response = await _apiClient.getBabyMons();
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch baby mons');
    }
  }

  /// Get a specific baby mon by ID
  Future<Map<String, dynamic>> getBabyMon(String id) async {
    try {
      final response = await _apiClient.getBabyMon(id);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch baby mon');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch baby mon');
    }
  }

  /// Get evolution data for a baby mon
  Future<Map<String, dynamic>> getEvolution(String babyMonId) async {
    try {
      final response = await _apiClient.getEvolution(babyMonId);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch evolution data');
    }
  }

  /// Get badges for a baby mon
  Future<List<Map<String, dynamic>>> getBadges(String babyMonId) async {
    try {
      final response = await _apiClient.getBadges(babyMonId);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch badges');
    }
  }

  /// Get baby mon stage information
  Future<Map<String, dynamic>> getBabyMonStage(String id) async {
    try {
      final response = await _apiClient.getBabyMonStage(id);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch stage info');
    }
  }

  /// Get subscription status
  Future<Map<String, dynamic>> getSubscription() async {
    try {
      final response = await _apiClient.getSubscription();
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch subscription');
    }
  }
}