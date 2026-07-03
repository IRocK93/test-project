import 'package:dio/dio.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/utils/tier_required_exception.dart';

class CompanionRepository {
  final ApiClient _api;

  CompanionRepository(this._api);

  Future<Map<String, dynamic>> getDailyBrief(String babyMonId, {String? locale}) async {
    try {
      final res = await _api.get(
        '/stage-content/$babyMonId/daily-brief',
        queryParameters: locale != null ? {'locale': locale} : null,
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      if (isTierRequiredError(e)) throw const TierRequiredException();
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getRoutine(String babyMonId, {bool forceRefresh = false, String? locale}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (locale != null) queryParams['locale'] = locale;
      final res = await _api.get(
        '/stage-content/$babyMonId/routine',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        forceRefresh: forceRefresh,
        options: Options(extra: {'forceRefresh': forceRefresh}),
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      if (isTierRequiredError(e)) throw const TierRequiredException();
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<void> syncRoutine(String babyMonId, List<String> completedSteps) async {
    try {
      await _api.put(
        '/stage-content/$babyMonId/routine/sync',
        data: {'completedSteps': completedSteps},
      );
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<void> completeRoutineStep(String babyMonId, String stepLabel) async {
    try {
      await _api.post(
        '/stage-content/$babyMonId/routine/${Uri.encodeComponent(stepLabel)}/complete',
        data: <String, dynamic>{},
      );
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getMilestones(String babyMonId, {String? status, bool forceRefresh = false, String? locale}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (locale != null) queryParams['locale'] = locale;
      final res = await _api.get(
        '/stage-content/$babyMonId/milestones/expected',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        forceRefresh: forceRefresh,
        options: Options(extra: {'forceRefresh': forceRefresh}),
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      if (isTierRequiredError(e)) throw const TierRequiredException();
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<void> unachieveMilestone(String babyMonId, String expectationId) async {
    try {
      await _api.delete('/stage-content/$babyMonId/milestones/$expectationId/achieve');
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> achieveMilestone(String babyMonId, String expectationId) async {
    try {
      final res = await _api.post('/stage-content/$babyMonId/milestones/$expectationId/achieve', data: <String, dynamic>{});
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getAdvice(String babyMonId, {String? category, int skip = 0, int take = 10, String? locale}) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'take': take,
      };
      if (category != null) queryParams['category'] = category;
      if (locale != null) queryParams['locale'] = locale;
      final res = await _api.get('/stage-content/$babyMonId/advice', queryParameters: queryParams);
      return res.data as Map<String, dynamic>;
    } catch (e) {
      if (isTierRequiredError(e)) throw const TierRequiredException();
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> toggleBookmark(String babyMonId, String adviceCardId) async {
    try {
      final res = await _api.post('/stage-content/$babyMonId/advice/$adviceCardId/bookmark', data: <String, dynamic>{});
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<List<String>> getBookmarkedAdviceIds(String babyMonId) async {
    try {
      final res = await _api.get('/stage-content/$babyMonId/advice/bookmarked');
      final data = res.data;
      if (data is List) return data.cast<String>();
      if (data is Map && data['ids'] is List) return (data['ids'] as List).cast<String>();
      return [];
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> rateAdvice(String babyMonId, String adviceCardId, bool helpful) async {
    try {
      final res = await _api.post('/stage-content/$babyMonId/advice/$adviceCardId/rate', data: {'helpful': helpful});
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }
}
