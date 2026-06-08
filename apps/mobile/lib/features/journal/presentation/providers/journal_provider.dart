import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';
import '../../domain/entities/journal_entry.dart';
import '../../../milestones/presentation/providers/milestones_provider.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

final journalProvider =
    StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>(
        (ref) {
  final repo = ref.watch(journalRepositoryProvider);
  final babyMonId = ref.watch(selectedBabyMonIdProvider);
  return JournalNotifier(repo, babyMonId);
});

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalRepository _repository;
  final String? _babyMonId;

  JournalNotifier(this._repository, this._babyMonId)
      : super(const AsyncValue.loading()) {
    if (_babyMonId != null) {
      loadJournalEntries();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadJournalEntries() async {
    final babyMonId = _babyMonId;
    if (babyMonId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final entries = await _repository.getJournalEntries(babyMonId);
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final babyMonId = _babyMonId;
    if (babyMonId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final entries = await _repository.getJournalEntries(babyMonId);
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
