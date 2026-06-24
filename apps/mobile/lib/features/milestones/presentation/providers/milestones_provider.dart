import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/data/api_client.dart';
import '../../data/repositories/milestones_repository.dart';
import '../../domain/entities/milestone.dart';

final milestonesRepositoryProvider = Provider<MilestonesRepository>((ref) {
  return MilestonesRepository(ApiClient());
});

final selectedBabyMonIdProvider = StateProvider<String?>((ref) => null);

final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, AsyncValue<List<Milestone>>>(
        (ref) {
  final repo = ref.watch(milestonesRepositoryProvider);
  final babyMonId = ref.watch(selectedBabyMonIdProvider);
  return MilestonesNotifier(repo, babyMonId);
});

class MilestonesNotifier extends StateNotifier<AsyncValue<List<Milestone>>> {
  final MilestonesRepository _repository;
  final String? _babyMonId;

  MilestonesNotifier(this._repository, this._babyMonId)
      : super(const AsyncValue.loading()) {
    if (_babyMonId != null) {
      loadMilestones();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadMilestones() async {
    final babyMonId = _babyMonId;
    if (babyMonId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final milestones = await _repository.getMilestones(babyMonId);
      state = AsyncValue.data(milestones);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMilestone(Milestone milestone) async {
    try {
      final created = await _repository.createMilestone(_babyMonId!, milestone.toJson());
      state.whenData((milestones) {
        state = AsyncValue.data([created, ...milestones]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteMilestone(String id) async {
    try {
      await _repository.deleteMilestone(id);
      state.whenData((milestones) {
        state = AsyncValue.data(
            milestones.where((m) => m.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
