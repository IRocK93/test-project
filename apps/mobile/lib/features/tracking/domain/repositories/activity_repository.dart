import '../entities/activity.dart';

abstract class ActivityRepository {
  Future<List<Activity>> getActivities({ActivityType? type, int limit = 50});
  Future<Activity> addActivity(Activity activity);
  Future<void> deleteActivity(String id);
  Future<Map<String, dynamic>> getStatistics(DateTime start, DateTime end);
}