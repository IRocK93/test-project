import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/data/api_client.dart';
import '../../data/repositories/feeding_repository.dart';
import '../../domain/entities/feed_log.dart';
import '../../../milestones/presentation/providers/milestones_provider.dart';

final feedingRepositoryProvider = Provider<FeedingRepository>((ref) {
  return FeedingRepository(ApiClient());
});

class FeedingNotifier extends StateNotifier<AsyncValue<List<FeedLog>>> {
  final FeedingRepository _repository;
  final String? _babyMonId;

  FeedingNotifier(this._repository, this._babyMonId) : super(const AsyncValue.loading()) {
    if (_babyMonId != null) {
      loadFeedLogs();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadFeedLogs() async {
    final babyMonId = _babyMonId;
    if (babyMonId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final logs = await _repository.getFeedLogs(babyMonId);
      logs.sort((a, b) => (b.happenedAt ?? DateTime(2000)).compareTo(a.happenedAt ?? DateTime(2000)));
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFeedLog(FeedLog feedLog) async {
    final babyMonId = _babyMonId;
    if (babyMonId == null) return;
    try {
      final created = await _repository.createFeedLog(babyMonId, feedLog);
      state.whenData((logs) {
        state = AsyncValue.data([created, ...logs]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteFeedLog(String id) async {
    try {
      await _repository.deleteFeedLog(id);
      state.whenData((logs) {
        state = AsyncValue.data(logs.where((l) => l.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final feedingProvider = StateNotifierProvider<FeedingNotifier, AsyncValue<List<FeedLog>>>((ref) {
  final repo = ref.watch(feedingRepositoryProvider);
  final babyMonId = ref.watch(selectedBabyMonIdProvider);
  return FeedingNotifier(repo, babyMonId);
});