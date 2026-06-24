import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/data/api_client.dart';
import '../../data/repositories/health_repository.dart';
import '../../domain/entities/health_record.dart';
import '../../../milestones/presentation/providers/milestones_provider.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ApiClient());
});

final healthProvider =
    StateNotifierProvider<HealthNotifier, AsyncValue<List<HealthRecord>>>(
        (ref) {
  final repo = ref.watch(healthRepositoryProvider);
  final babyMonId = ref.watch(selectedBabyMonIdProvider);
  return HealthNotifier(repo, babyMonId);
});

class HealthNotifier extends StateNotifier<AsyncValue<List<HealthRecord>>> {
  final HealthRepository _repository;
  final String? _babyMonId;

  HealthNotifier(this._repository, this._babyMonId)
      : super(const AsyncValue.loading()) {
    if (_babyMonId != null) {
      loadHealthRecords();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadHealthRecords() async {
    final babyMonId = _babyMonId;
    if (babyMonId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final records = await _repository.getHealthRecords(babyMonId);
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      final created = await _repository.createHealthRecord(_babyMonId!, record.toJson());
      state.whenData((records) {
        state = AsyncValue.data([created, ...records]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    try {
      await _repository.deleteHealthRecord(id);
      state.whenData((records) {
        state = AsyncValue.data(
            records.where((r) => r.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Alias methods used by HealthScreen
  Future<void> loadRecords() => loadHealthRecords();
  Future<void> addRecord(HealthRecord record) => addHealthRecord(record);
  Future<void> deleteRecord(String id) => deleteHealthRecord(id);
}
