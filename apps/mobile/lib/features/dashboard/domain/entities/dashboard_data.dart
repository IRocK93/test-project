import 'baby_mon_summary.dart';

class DashboardData {
  final List<BabyMonSummary> babyMons;
  final int unreadNotifications;
  final Map<String, int> todayStats; // feedingCount, healthLogs, milestones

  DashboardData({
    required this.babyMons,
    required this.unreadNotifications,
    required this.todayStats,
  });

  factory DashboardData.empty() {
    return DashboardData(
      babyMons: [],
      unreadNotifications: 0,
      todayStats: {
        'feedingCount': 0,
        'healthLogs': 0,
        'milestones': 0,
      },
    );
  }
}
