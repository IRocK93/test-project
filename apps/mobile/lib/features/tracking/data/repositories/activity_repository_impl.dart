import 'dart:convert';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import 'package:baby_mon/core/services/local_storage_service.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  static const String _activitiesKey = 'stored_activities';

  @override
  Future<List<Activity>> getActivities({ActivityType? type, int limit = 50}) async {
    var activities = await _loadActivities();
    
    if (type != null) {
      activities = activities.where((a) => a.type == type).toList();
    }
    
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(limit).toList();
  }

  @override
  Future<Activity> addActivity(Activity activity) async {
    final activities = await _loadActivities();
    activities.add(activity);
    await _saveActivities(activities);
    return activity;
  }

  @override
  Future<void> deleteActivity(String id) async {
    final activities = await _loadActivities();
    activities.removeWhere((a) => a.id == id);
    await _saveActivities(activities);
  }

  @override
  Future<Map<String, dynamic>> getStatistics(DateTime start, DateTime end) async {
    final activities = await _loadActivities();
    final filtered = activities.where((a) => 
      a.timestamp.isAfter(start) && a.timestamp.isBefore(end)
    ).toList();

    return {
      'totalFeeds': filtered.where((a) => a.type == ActivityType.feeding).length,
      'totalDiapers': filtered.where((a) => a.type == ActivityType.diaper).length,
      'totalSleepHours': filtered
          .where((a) => a.type == ActivityType.sleep)
          .fold(0.0, (sum, a) => sum + (a.data['durationMinutes'] as int? ?? 0) / 60),
    };
  }

  Future<List<Activity>> _loadActivities() async {
    final jsonString = LocalStorageService.getString(_activitiesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Activity.fromJsonMap(json)).toList();
    } catch (e) {
      // If there's an error parsing, return empty list and optionally clear corrupt data
      LocalStorageService.remove(_activitiesKey);
      return [];
    }
  }

  Future<void> _saveActivities(List<Activity> activities) async {
    final jsonList = activities.map((a) => a.toJson()).toList();
    await LocalStorageService.setString(_activitiesKey, jsonEncode(jsonList));
  }
}