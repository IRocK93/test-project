import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:dio/dio.dart';

/// Shared behavior mixin for all tab/CRUD screens in the app.
///
/// Standardizes the common pattern used across every data screen:
/// - BabyMon ID loading from secure storage
/// - Loading / empty / no-BabyMon states
/// - Re-entrancy guard to prevent concurrent load calls
/// - Pull-to-refresh
/// - Swipe-to-delete with confirmation
///
/// Usage:
/// ```dart
/// class _MyScreenState extends ConsumerState<MyScreen> with DataScreenMixin<MyScreen> {
///   List _items = [];
///
///   @override
///   String get emptyTitle => 'No items yet';
///
///   @override
///   Future<void> fetchData() async {
///     final response = await ref.read(apiClientProvider).getSomething(babyMonId!);
///     _items = parseItems(response.data);
///   }
/// }
/// ```
///
/// This replaces the manual `_babyMonId`, `_isLoading`, `_loadInProgress`
/// boilerplate that every screen previously duplicated.
mixin DataScreenMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Shared cache so all tab screens resolve the BabyMon ID with a single
  /// API call instead of each making an independent network round-trip.
  static String? _cachedBabyMonId;

  // ── Core State ──
  String? _babyMonId;
  bool _isLoading = true;
  bool _loadInProgress = false;
  CancelToken? _cancelToken;

  // ── Override Points (subclasses customize these) ──

  /// The icon shown in the empty state (e.g., PhosphorIconsLight.inbox).
  IconData get emptyIcon => Icons.inbox;

  /// The title shown in the empty state.
  String get emptyTitle => 'No items yet';

  /// The subtitle shown in the empty state.
  String get emptySubtitle => 'Tap the button below to add your first one.';

  /// The label for the action button in the empty state.
  String get emptyActionLabel => 'Add';

  /// Override to provide custom empty state widget instead of the default.
  Widget? get customEmptyWidget => null;

  /// Called when the empty state action button is tapped.
  void onEmptyAction() {}

  /// The main data fetch method — subclass MUST override this.
  ///
  /// Called by [_loadData] after babyMonId is resolved. Use [babyMonId] to
  /// make API calls, then call [setState] to update local state.
  Future<void> fetchData() async {
    // Subclasses override this
  }

  /// Whether this screen should listen to [appRefreshProvider] for global refreshes.
  /// Default: false. Only enable for screens that need to react to global events
  /// (BabyMon creation/deletion, partner changes, settings changes).
  /// Routine data mutations should use [listenToTabRefresh] instead.
  bool get listenToAppRefresh => false;

  /// Whether this screen should listen to its [tabRefreshProvider] for tab-specific refreshes.
  int? get listenToTabRefresh => null;

  /// When `true`, [initDataScreen] is called automatically from [initState].
  ///
  /// Set this to `true` for screens that only need standard listener wiring
  /// (appRefreshProvider + tabRefreshProvider) and don't have any custom
  /// logic in their [initState]. The mixin handles everything, so the screen
  /// class can omit the [initState] override entirely.
  ///
  /// Keep this `false` (the default) for screens with custom [initState]
  /// logic (e.g., additional listeners like [pendingAddActionProvider]), and
  /// call [initDataScreen] manually from their [initState] instead.
  bool get autoInit => false;

  // ── Cooldown Support ──

  /// Optional cooldown duration to prevent rapid re-fetches from duplicate
  /// provider notifications. Override to a non-null value (e.g.,
  /// `const Duration(seconds: 10)`) to enable cooldown.
  ///
  /// When enabled, [loadData] will skip re-fetching if called within the
  /// cooldown window. Pass `force: true` to bypass the cooldown (e.g., after
  /// a user-initiated save or pull-to-refresh).
  Duration? get refreshCooldown => null;

  /// Timestamp of the last successful data fetch.
  DateTime? _lastDataRefresh;

  // ── Public Getters ──

  /// The current BabyMon ID, or null if none is selected.
  String? get babyMonId => _babyMonId;

  /// Whether data is currently loading.
  bool get isLoading => _isLoading;

  /// Whether a load is already in progress (re-entrancy guard).
  bool get loadInProgress => _loadInProgress;

  /// CancelToken for the current load operation. Pass this to API calls in
  /// [fetchData] to cancel in-flight requests when the screen disposes.
  CancelToken? get cancelToken => _cancelToken;

  /// Whether a BabyMon has been selected.
  bool get hasBabyMon => _babyMonId != null && _babyMonId!.isNotEmpty;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  // ── Standard Methods ──

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    if (autoInit) initDataScreen();
  }

  /// Initialize listeners. Call from initState when [autoInit] is `false`.
  void initDataScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
    if (listenToAppRefresh) {
      ref.listenManual(appRefreshProvider, (prev, next) {
        if (prev != next && mounted) loadData(force: true);
      });
    }
    final tabIndex = listenToTabRefresh;
    if (tabIndex != null) {
      ref.listenManual(tabRefreshProvider(tabIndex), (prev, next) {
        if (prev != next && mounted) loadData();
      });
    }
  }

  /// Load data: resolve BabyMon ID then call [fetchData].
  ///
  /// Safe to call from any lifecycle event (addPostFrameCallback, listener, refresh).
  /// Uses [_loadInProgress] to prevent concurrent calls, and [refreshCooldown] to
  /// prevent rapid re-fetches from duplicate provider notifications.
  ///
  /// Pass [force] = `true` to bypass the cooldown (e.g., after a user save or
  /// pull-to-refresh).
  Future<void> loadData({bool force = false}) async {
    // Cooldown check: skip if data was fetched recently (unless forced)
    if (!force &&
        refreshCooldown != null &&
        _lastDataRefresh != null &&
        _babyMonId != null) {
      final elapsed = DateTime.now().difference(_lastDataRefresh!);
      if (elapsed < refreshCooldown!) return;
    }

    if (_loadInProgress) {
      // Don't stack concurrent loads — the first call is already in progress
      return;
    }
    _loadInProgress = true;
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      if (_babyMonId == null) {
        if (_cachedBabyMonId != null) {
          _babyMonId = _cachedBabyMonId;
        } else {
          final api = ref.read(apiClientProvider);
          final id = await api.getSelectedBabyMonId();
          if (id == null || id.isEmpty) {
            if (mounted) setState(() => _isLoading = false);
            _loadInProgress = false;
            return;
          }
          // Validate the stored ID — it may point to a deleted BabyMon.
          try {
            await api.getBabyMon(id);
          } catch (_) {
            // Stale ID — clear storage so the no-BabyMon prompt shows.
            await api.setSelectedBabyMonId('');
            if (mounted) setState(() => _isLoading = false);
            _loadInProgress = false;
            return;
          }
          _cachedBabyMonId = id;
          _babyMonId = id;
        }
      }

      if (mounted && _isLoading == false) {
        setState(() => _isLoading = true);
      }

      await fetchData();
      _lastDataRefresh = DateTime.now();
      
      // Ensure loading state is cleared after data loads successfully
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    } finally {
      _loadInProgress = false;
    }
  }

  /// Refresh data (for pull-to-refresh). Bypasses cooldown so user-initiated
  /// refreshes always fetch fresh data.
  Future<void> onRefresh() => loadData(force: true);

  // ── Standard UI Builders ──

  /// Standard loading state.
  Widget buildLoading() => PremiumLoading.spinner();

  /// Standard "no BabyMon" state — prompts the user to create one.
  Widget buildNoBabyMon() {
    return PremiumEmptyState(
      icon: Icons.child_care,
      title: 'Welcome to BabyMon!',
      subtitle: 'Create your first BabyMon to start tracking milestones, feedings, and more.',
      actionLabel: 'Create BabyMon',
      onAction: () => GoRouter.of(context).push('/create-baby-mon'),
    );
  }

  /// Standard empty state with an action button.
  Widget buildEmptyState() {
    if (customEmptyWidget != null) return customEmptyWidget!;
    return PremiumEmptyState(
      icon: emptyIcon,
      title: emptyTitle,
      subtitle: emptySubtitle,
      actionLabel: emptyActionLabel,
      onAction: onEmptyAction,
    );
  }

  /// Main content scaffold with loading/no-baby-mon/data states.
  ///
  /// Override [buildContent] for the data state, or use [buildLoading],
  /// [buildNoBabyMon], [buildEmptyState] individually.
  Widget buildScaffold({required Widget body}) {
    if (_isLoading) return buildLoading();
    if (!hasBabyMon) return buildNoBabyMon();
    return body;
  }
}
