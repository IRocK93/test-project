import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/utils/tier_required_exception.dart';
import '../../data/companion_repository.dart';
import 'companion_provider.dart';

class AdviceFeedState {
  final List<Map<String, dynamic>> cards;
  final String? selectedCategory;
  final int skip;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final bool isTierError;
  final bool isInitialLoad;
  final Set<String> bookmarkedIds;
  final Map<String, bool?> ratings;

  const AdviceFeedState({
    this.cards = const [],
    this.selectedCategory,
    this.skip = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
    this.isTierError = false,
    this.isInitialLoad = true,
    this.bookmarkedIds = const {},
    this.ratings = const {},
  });

  AdviceFeedState copyWith({
    List<Map<String, dynamic>>? cards,
    String? selectedCategory,
    int? skip,
    bool? hasMore,
    bool? isLoading,
    String? error,
    bool? isTierError,
    bool? isInitialLoad,
    Set<String>? bookmarkedIds,
    Map<String, bool?>? ratings,
  }) {
    return AdviceFeedState(
      cards: cards ?? this.cards,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      skip: skip ?? this.skip,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isTierError: isTierError ?? this.isTierError,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      ratings: ratings ?? this.ratings,
    );
  }

  /// Clears error when transitioning away from error state.
  AdviceFeedState clearError() => copyWith(error: null, isTierError: false);
}

class AdviceFeedNotifier extends StateNotifier<AdviceFeedState> {
  final CompanionRepository _repo;
  final String _babyMonId;
  static const int _take = 10;

  AdviceFeedNotifier(this._repo, this._babyMonId) : super(const AdviceFeedState());

  Future<void> loadCards() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null, isTierError: false);

    try {
      final result = await _repo.getAdvice(
        _babyMonId,
        category: state.selectedCategory,
        skip: state.skip,
        take: _take,
      );

      final items = (result['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final total = result['total'] as int? ?? 0;
      final newSkip = state.skip + items.length;

      state = state.copyWith(
        cards: [...state.cards, ...items],
        skip: newSkip,
        hasMore: newSkip < total,
        isLoading: false,
        isInitialLoad: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialLoad: false,
        isTierError: e is TierRequiredException,
        error: extractErrorMessage(e),
      );
    }
  }

  void changeCategory(String? category) {
    if (state.selectedCategory == category) return;
    state = AdviceFeedState(selectedCategory: category);
    loadCards();
  }

  Future<void> retry() async {
    state = state.clearError();
    loadCards();
  }

  void refresh() {
    state = const AdviceFeedState();
    loadCards().then((_) => loadBookmarks());
  }

  // ─── Bookmarks ─────────────────────────────────────────────────

  /// Fetches the set of bookmarked advice card IDs from the backend.
  /// Called on initial load; silently no-ops on failure.
  Future<void> loadBookmarks() async {
    try {
      final ids = await _repo.getBookmarkedAdviceIds(_babyMonId);
      state = state.copyWith(bookmarkedIds: ids.toSet());
    } catch (_) {
      // Bookmarks are non-critical — leave the set empty on failure.
    }
  }

  /// Toggles the bookmark state for [cardId].
  /// Uses optimistic UI: the icon flips immediately and is reverted on API error.
  Future<void> toggleBookmark(String cardId) async {
    final wasBookmarked = state.bookmarkedIds.contains(cardId);

    // Optimistic update
    final updated = Set<String>.from(state.bookmarkedIds);
    if (wasBookmarked) {
      updated.remove(cardId);
    } else {
      updated.add(cardId);
    }
    state = state.copyWith(bookmarkedIds: updated);

    try {
      await _repo.toggleBookmark(_babyMonId, cardId);
    } catch (_) {
      // Revert on error
      final reverted = Set<String>.from(state.bookmarkedIds);
      if (wasBookmarked) {
        reverted.add(cardId);
      } else {
        reverted.remove(cardId);
      }
      state = state.copyWith(bookmarkedIds: reverted);
    }
  }

  // ─── Rating ────────────────────────────────────────────────────

  /// Rates [cardId] as helpful or not helpful with optimistic UI.
  /// Tapping the same rating a second time clears it (local-only, no unrate
  /// endpoint exists on the backend).
  Future<void> rateCard(String cardId, bool helpful) async {
    final previousRating = state.ratings[cardId];
    final updated = Map<String, bool?>.from(state.ratings);

    // Tapping the same rating again clears it — frontend-only toggle.
    if (previousRating == helpful) {
      updated[cardId] = null;
      state = state.copyWith(ratings: updated);
      return;
    }

    // Optimistic update
    updated[cardId] = helpful;
    state = state.copyWith(ratings: updated);

    try {
      await _repo.rateAdvice(_babyMonId, cardId, helpful);
    } catch (_) {
      // Revert on error
      final reverted = Map<String, bool?>.from(state.ratings);
      reverted[cardId] = previousRating;
      state = state.copyWith(ratings: reverted);
    }
  }

  @override
  void dispose() {
    // Release any loaded card data
    state = state.copyWith(cards: [], skip: 0, hasMore: false);
    super.dispose();
  }
}

final adviceFeedProvider =
    StateNotifierProvider.family<AdviceFeedNotifier, AdviceFeedState, String>(
  (ref, babyMonId) {
    final repo = ref.read(companionRepositoryProvider);
    final notifier = AdviceFeedNotifier(repo, babyMonId);
    notifier.loadCards().then((_) => notifier.loadBookmarks());
    return notifier;
  },
);
