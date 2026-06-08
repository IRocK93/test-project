import 'package:dio/dio.dart';
import '../../../../data/api_client.dart';
import '../../domain/entities/feed_log.dart';

class FeedingRepository {
  final ApiClient _apiClient;

  FeedingRepository(this._apiClient);

  Future<List<FeedLog>> getFeedLogs(String babyMonId) async {
    try {
      final response = await _apiClient.get(
        '/baby-mons/$babyMonId/feed-logs',
      );
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => FeedLog.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch feed logs');
    }
  }

  Future<FeedLog> createFeedLog(String babyMonId, FeedLog feedLog) async {
    try {
      final response = await _apiClient.post(
        '/baby-mons/$babyMonId/feed-logs',
        data: feedLog.toJson(),
      );
      return FeedLog.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to create feed log');
    }
  }

  Future<FeedLog> updateFeedLog(String id, FeedLog feedLog) async {
    try {
      final response = await _apiClient.patch(
        '/feed-logs/$id',
        data: feedLog.toJson(),
      );
      return FeedLog.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to update feed log');
    }
  }

  Future<void> deleteFeedLog(String id) async {
    try {
      await _apiClient.delete('/feed-logs/$id');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to delete feed log');
    }
  }
}