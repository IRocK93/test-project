import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/companion/data/companion_repository.dart';
import 'package:baby_mon/features/companion/data/llm/llm_inference_service.dart';
import 'package:baby_mon/features/companion/data/llm/llamadart_engine.dart';
import 'package:baby_mon/features/companion/data/llm/model_manifest_service.dart';

final companionRepositoryProvider = Provider<CompanionRepository>((ref) {
  return CompanionRepository(ref.read(apiClientProvider));
});

final llamadartEngineProvider = Provider<LlamadartEngine>((ref) {
  return LlamadartEngine();
});

final llmInferenceServiceProvider = Provider<LlmInferenceService>((ref) {
  final repository = ref.read(companionRepositoryProvider);
  final engine = ref.read(llamadartEngineProvider);
  return LlmInferenceService(repository: repository, engine: engine);
});

final modelManifestServiceProvider = Provider<ModelManifestService>((ref) {
  return ModelManifestService(dio: ref.read(apiClientProvider).dio);
});

final dailyBriefProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, babyMonId) {
  return ref.read(companionRepositoryProvider).getDailyBrief(babyMonId);
});

final routineProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, babyMonId) {
  return ref.read(companionRepositoryProvider).getRoutine(babyMonId, forceRefresh: true);
});

final milestonesProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, babyMonId) {
  return ref.read(companionRepositoryProvider).getMilestones(babyMonId, forceRefresh: true);
});

final adviceProvider = FutureProvider.family<Map<String, dynamic>, ({String babyMonId, String? category, int skip, int take})>((ref, params) {
  return ref.read(companionRepositoryProvider).getAdvice(
    params.babyMonId,
    category: params.category,
    skip: params.skip,
    take: params.take,
  );
});

// ── Local-first pending state — survives widget disposal ──
final pendingRoutineStepsProvider = StateProvider.family<Set<String>, String>((ref, babyMonId) => <String>{});
final pendingMilestoneAchievementsProvider = StateProvider.family<Set<String>, String>((ref, babyMonId) => <String>{});
final pendingMilestoneUnachievementsProvider = StateProvider.family<Set<String>, String>((ref, babyMonId) => <String>{});

enum SyncStatus { idle, pending, syncing, error }
final syncStatusProvider = StateProvider.family<SyncStatus, String>((ref, babyMonId) => SyncStatus.idle);
