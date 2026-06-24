import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/data/api_client.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/baby_mon_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ApiClient());
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  try {
    final babyMonsData = await repo.getBabyMons();
    final babyMons = babyMonsData.map((json) => BabyMonSummary.fromJson(json)).toList();
    return DashboardData(
      babyMons: babyMons,
      unreadNotifications: 0,
      todayStats: {
        'feedingCount': 0,
        'healthLogs': 0,
        'milestones': 0,
      },
    );
  } catch (e) {
    return DashboardData.empty();
  }
});

final babyMonsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBabyMons();
});

final evolutionProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, babyMonId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getEvolution(babyMonId);
});

final badgesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, babyMonId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBadges(babyMonId);
});
