import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/utils/error_handler.dart';

class CompanionRepository {
  final ApiClient _api;

  CompanionRepository(this._api);

  Future<Map<String, dynamic>> getDailyBrief(String babyMonId) async {
    try {
      final res = await _api.get('/stage-content/$babyMonId/daily-brief');
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getRoutine(String babyMonId) async {
    try {
      final res = await _api.get('/stage-content/$babyMonId/routine');
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<void> completeRoutineStep(String babyMonId, String stepLabel) async {
    try {
      await _api.post('/stage-content/$babyMonId/routine/$stepLabel/complete', data: <String, dynamic>{});
    } catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getMilestones(String babyMonId, {String? status}) async {
    try {
      final query = status != null ? '?status=$status' : '';
      final res = await _api.get('/stage-content/$babyMonId/milestones/expected$query');
      return res.data as Map<String, dynamic>;
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

  Future<Map<String, dynamic>> getAdvice(String babyMonId, {String? category, int skip = 0, int take = 10}) async {
    try {
      final query = '?skip=$skip&take=$take${category != null ? '&category=$category' : ''}';
      final res = await _api.get('/stage-content/$babyMonId/advice$query');
      return res.data as Map<String, dynamic>;
    } catch (e) {
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
