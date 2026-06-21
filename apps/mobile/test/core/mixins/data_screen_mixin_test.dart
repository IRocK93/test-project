import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/feeding/feeding.dart';

// ═══════════════════════════════════════════════
//  Mock API Client
// ═══════════════════════════════════════════════

/// Returns a controlled [babyMonId] from [getSelectedBabyMonId].
/// Provide `null` to simulate "no BabyMon selected".
class _MockApi extends ApiClient {
  final String? babyMonId;
  _MockApi({this.babyMonId});

  @override
  Future<String?> getSelectedBabyMonId() async => babyMonId;
}

/// A more flexible mock that also stubs [getFeedLogs] for feeding screen
/// integration tests.
class _FlexibleMock extends ApiClient {
  final String? babyMonId;
  final List<Map<String, dynamic>>? feedLogs;

  _FlexibleMock({this.babyMonId, this.feedLogs});

  @override
  Future<String?> getSelectedBabyMonId() async => babyMonId;

  @override
  Future<Response> getFeedLogs(String babyMonId, {bool forceRefresh = false}) async {
    return Response<dynamic>(
      data: feedLogs ?? [],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/test'),
    );
  }
}

// ═══════════════════════════════════════════════
//  Test Screen (state-behavior tests)
// ═══════════════════════════════════════════════

class _DataScreenTestScreen extends ConsumerStatefulWidget {
  final bool autoInitValue;
  final bool listenToAppRefreshValue;
  final Duration? cooldown;
  final bool slowFetch;
  final Completer<void>? fetchCompleter;
  final int? tabRefreshIndex;

  const _DataScreenTestScreen({
    super.key,
    this.autoInitValue = false,
    this.listenToAppRefreshValue = true,
    this.cooldown,
    this.slowFetch = false,
    this.fetchCompleter,
    this.tabRefreshIndex,
  });

  @override
  ConsumerState<_DataScreenTestScreen> createState() =>
      _DataScreenTestScreenState();
}

class _DataScreenTestScreenState
    extends ConsumerState<_DataScreenTestScreen>
    with DataScreenMixin<_DataScreenTestScreen> {
  int fetchDataCallCount = 0;

  @override
  bool get autoInit => widget.autoInitValue;

  @override
  bool get listenToAppRefresh => widget.listenToAppRefreshValue;

  @override
  Duration? get refreshCooldown => widget.cooldown;

  @override
  int? get listenToTabRefresh => widget.tabRefreshIndex;

  @override
  Future<void> fetchData() async {
    fetchDataCallCount++;
    if (widget.slowFetch) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    if (widget.fetchCompleter != null) {
      await widget.fetchCompleter!.future;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildScaffold(
        body: Center(
          child: Text('data loaded: $fetchDataCallCount'),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Test Screen (UI builder tests: empty state)
// ═══════════════════════════════════════════════

class _EmptyStateTestScreen extends ConsumerStatefulWidget {
  const _EmptyStateTestScreen();

  @override
  ConsumerState<_EmptyStateTestScreen> createState() =>
      _EmptyStateTestScreenState();
}

class _EmptyStateTestScreenState
    extends ConsumerState<_EmptyStateTestScreen>
    with DataScreenMixin<_EmptyStateTestScreen> {
  @override
  IconData get emptyIcon => PhosphorIconsLight.star;

  @override
  String get emptyTitle => 'Custom Empty Title';

  @override
  String get emptySubtitle => 'Custom Empty Subtitle';

  @override
  String get emptyActionLabel => 'Custom Action';

  @override
  Future<void> fetchData() async {
    // No-op — we just want to test the empty state UI.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildEmptyState(),
      ),
    );
  }
}

/// Test screen that overrides [customEmptyWidget] to verify the
/// override is rendered instead of the default empty state.
class _CustomEmptyWidgetTestScreen extends ConsumerStatefulWidget {
  const _CustomEmptyWidgetTestScreen();

  @override
  ConsumerState<_CustomEmptyWidgetTestScreen> createState() =>
      _CustomEmptyWidgetTestScreenState();
}

class _CustomEmptyWidgetTestScreenState
    extends ConsumerState<_CustomEmptyWidgetTestScreen>
    with DataScreenMixin<_CustomEmptyWidgetTestScreen> {
  @override
  Widget? get customEmptyWidget =>
      const Center(child: Text('Custom override widget'));

  @override
  Future<void> fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildEmptyState(),
      ),
    );
  }
}

/// Test screen that exercises [buildScaffold] routing: loading → body.
class _BuildScaffoldRoutingScreen extends ConsumerStatefulWidget {
  const _BuildScaffoldRoutingScreen();

  @override
  ConsumerState<_BuildScaffoldRoutingScreen> createState() =>
      _BuildScaffoldRoutingScreenState();
}

class _BuildScaffoldRoutingScreenState
    extends ConsumerState<_BuildScaffoldRoutingScreen>
    with DataScreenMixin<_BuildScaffoldRoutingScreen> {
  @override
  bool get autoInit => true;

  @override
  Future<void> fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(
          body: const Center(child: Text('BODY_VISIBLE')),
        ),
      ),
    );
  }
}

/// Test screen that exercises [buildScaffold] noBabyMon routing:
/// loading → noBabyMon welcome (null BabyMon ID) instead of body.
class _BuildScaffoldNoBabyMonScreen extends ConsumerStatefulWidget {
  const _BuildScaffoldNoBabyMonScreen();

  @override
  ConsumerState<_BuildScaffoldNoBabyMonScreen> createState() =>
      _BuildScaffoldNoBabyMonScreenState();
}

class _BuildScaffoldNoBabyMonScreenState
    extends ConsumerState<_BuildScaffoldNoBabyMonScreen>
    with DataScreenMixin<_BuildScaffoldNoBabyMonScreen> {
  @override
  bool get autoInit => true;

  @override
  Future<void> fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(
          body: const Center(child: Text('BODY_VISIBLE')),
        ),
      ),
    );
  }
}

/// Test screen that overrides [onEmptyAction] to track callback invocations.
class _OnEmptyActionScreen extends ConsumerStatefulWidget {
  const _OnEmptyActionScreen({super.key});

  @override
  ConsumerState<_OnEmptyActionScreen> createState() =>
      _OnEmptyActionScreenState();
}

class _OnEmptyActionScreenState
    extends ConsumerState<_OnEmptyActionScreen>
    with DataScreenMixin<_OnEmptyActionScreen> {
  int emptyActionCount = 0;

  @override
  bool get autoInit => true;

  @override
  void onEmptyAction() {
    emptyActionCount++;
  }

  @override
  Future<void> fetchData() async {
    // No-op — data stays empty so empty state is shown.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(body: buildEmptyState()),
      ),
    );
  }
}

/// Test screen whose [fetchData] always throws, verifying the error catch path
/// in [DataScreenMixin.loadData] doesn't crash and sets isLoading to false.
class _ThrowingFetchScreen extends ConsumerStatefulWidget {
  const _ThrowingFetchScreen({super.key});

  @override
  ConsumerState<_ThrowingFetchScreen> createState() =>
      _ThrowingFetchScreenState();
}

class _ThrowingFetchScreenState
    extends ConsumerState<_ThrowingFetchScreen>
    with DataScreenMixin<_ThrowingFetchScreen> {
  @override
  bool get autoInit => true;

  @override
  Future<void> fetchData() async {
    throw Exception('Simulated fetch error');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(
          body: const Center(child: Text('Error test body')),
        ),
      ),
    );
  }
}

/// Test screen whose [fetchData] throws on first call, then succeeds on retry.
/// Verifies the error→retry→success lifecycle.
class _ErrorThenSuccessScreen extends ConsumerStatefulWidget {
  const _ErrorThenSuccessScreen({super.key});

  @override
  ConsumerState<_ErrorThenSuccessScreen> createState() =>
      _ErrorThenSuccessScreenState();
}

class _ErrorThenSuccessScreenState
    extends ConsumerState<_ErrorThenSuccessScreen>
    with DataScreenMixin<_ErrorThenSuccessScreen> {
  int fetchDataCallCount = 0;
  bool shouldThrow = true;

  @override
  bool get autoInit => true;

  @override
  Future<void> fetchData() async {
    fetchDataCallCount++;
    if (shouldThrow) throw Exception('First fetch fails');
    // Second fetch succeeds — no-op, just mark as loaded.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(
          body: Center(
            child: Text('loaded: $fetchDataCallCount'),
          ),
        ),
      ),
    );
  }
}

/// Test screen whose [onEmptyAction] performs slow async work.
/// Verifies rapid taps don't stack concurrent async operations.
class _AsyncOnEmptyActionScreen extends ConsumerStatefulWidget {
  const _AsyncOnEmptyActionScreen({super.key});

  @override
  ConsumerState<_AsyncOnEmptyActionScreen> createState() =>
      _AsyncOnEmptyActionScreenState();
}

class _AsyncOnEmptyActionScreenState
    extends ConsumerState<_AsyncOnEmptyActionScreen>
    with DataScreenMixin<_AsyncOnEmptyActionScreen> {
  int emptyActionCount = 0;
  int completedCount = 0;
  bool actionInProgress = false;

  @override
  bool get autoInit => true;

  @override
  void onEmptyAction() {
    if (actionInProgress) return; // guard against stacking
    actionInProgress = true;
    emptyActionCount++;
    // Simulate slow async work
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      if (mounted) {
        completedCount++;
        actionInProgress = false;
      }
    });
  }

  @override
  Future<void> fetchData() async {
    // No-op — data stays empty.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(body: buildEmptyState()),
      ),
    );
  }
}

/// Test screen that verifies [buildScaffold] → [buildEmptyState] → [customEmptyWidget]
/// pipeline: data loads, then buildScaffold shows the body which calls buildEmptyState,
/// which returns the custom widget instead of the default PremiumEmptyState.
class _BuildScaffoldCustomScreen extends ConsumerStatefulWidget {
  const _BuildScaffoldCustomScreen();

  @override
  ConsumerState<_BuildScaffoldCustomScreen> createState() =>
      _BuildScaffoldCustomScreenState();
}

class _BuildScaffoldCustomScreenState
    extends ConsumerState<_BuildScaffoldCustomScreen>
    with DataScreenMixin<_BuildScaffoldCustomScreen> {
  @override
  bool get autoInit => true;

  @override
  Widget? get customEmptyWidget =>
      const Center(child: Text('buildScaffold custom widget'));

  @override
  Future<void> fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: buildScaffold(body: buildEmptyState()),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Test App Builders
// ═══════════════════════════════════════════════

Widget _createTestApp({
  required ApiClient apiClient,
  bool autoInitValue = false,
  Duration? cooldown,
  bool slowFetch = false,
  Completer<void>? fetchCompleter,
  Key? screenKey,
}) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
    ],
    child: MaterialApp(
      home: _DataScreenTestScreen(
        key: screenKey,
        autoInitValue: autoInitValue,
        cooldown: cooldown,
        slowFetch: slowFetch,
        fetchCompleter: fetchCompleter,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════
//  Tests
// ═══════════════════════════════════════════════

void main() {
  group('DataScreenMixin', () {
    // ─────────────── autoInit ───────────────

    group('autoInit', () {
      testWidgets('autoInit=false does NOT auto-load data',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: false,
          screenKey: key,
        ));

        // Pump to flush microtasks and frames
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchData should NOT have been called
        expect(key.currentState!.fetchDataCallCount, equals(0));
      });

      testWidgets('autoInit=true auto-loads data after init',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: true,
          screenKey: key,
        ));

        // Process postFrameCallback and start loadData
        await tester.pump();
        // Complete the async loadData (fetchData runs)
        await tester.pump(const Duration(seconds: 1));

        // fetchData should have been called once
        expect(key.currentState!.fetchDataCallCount, equals(1));
        // BabyMon ID should be resolved
        expect(key.currentState!.babyMonId, equals('baby-1'));
        // hasBabyMon should be true
        expect(key.currentState!.hasBabyMon, isTrue);
        // isLoading should be false
        expect(key.currentState!.isLoading, isFalse);
      });

      testWidgets('appRefreshProvider bump triggers reload when autoInit=true',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();

        // Use a ProviderContainer so we can access the provider from the test
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
        );
        addTearDown(() => container.dispose());

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: _DataScreenTestScreen(
                key: key,
                autoInitValue: true,
              ),
            ),
          ),
        );

        // Initial auto-load
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Bump appRefreshProvider — the listener wired by initDataScreen
        // should call loadData()
        container.read(appRefreshProvider.notifier).state++;
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchData should have been called again
        expect(key.currentState!.fetchDataCallCount, equals(2));
      });

      testWidgets('tabRefreshProvider bump triggers reload when listenToTabRefresh is set',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
        );
        addTearDown(() => container.dispose());

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: _DataScreenTestScreen(
                key: key,
                autoInitValue: true,
                tabRefreshIndex: 2,
              ),
            ),
          ),
        );

        // Initial auto-load
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Bump tabRefreshProvider(2) — should trigger loadData
        container.read(tabRefreshProvider(2).notifier).state++;
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(key.currentState!.fetchDataCallCount, equals(2));

        // Bumping a different tab should NOT trigger loadData
        container.read(tabRefreshProvider(5).notifier).state++;
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchDataCallCount should still be 2 (unrelated tab was bumped)
        expect(key.currentState!.fetchDataCallCount, equals(2));
      });

      testWidgets('listenToAppRefresh=false prevents appRefreshProvider bump from triggering reload',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
        );
        addTearDown(() => container.dispose());

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: _DataScreenTestScreen(
                key: key,
                autoInitValue: true,
                listenToAppRefreshValue: false,
              ),
            ),
          ),
        );

        // Initial auto-load still works (autoInit controls initDataScreen)
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Bump appRefreshProvider — listener should NOT be wired
        container.read(appRefreshProvider.notifier).state++;
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchDataCallCount should still be 1 (no listener fired)
        expect(key.currentState!.fetchDataCallCount, equals(1));
      });

      testWidgets('listenToTabRefresh=false (null) prevents tabRefreshProvider bump from triggering reload',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
        );
        addTearDown(() => container.dispose());

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: _DataScreenTestScreen(
                key: key,
                autoInitValue: true,
                // tabRefreshIndex defaults to null = listenToTabRefresh = null
              ),
            ),
          ),
        );

        // Initial auto-load
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Bump tabRefreshProvider(2) — listener should NOT be wired
        container.read(tabRefreshProvider(2).notifier).state++;
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchDataCallCount should still be 1 (no listener fired)
        expect(key.currentState!.fetchDataCallCount, equals(1));
      });

      testWidgets('autoInit=true with null BabyMon shows welcome',
          (tester) async {
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: null),
          autoInitValue: true,
        ));

        // Process postFrameCallback and loadData
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Should show the welcome screen from buildNoBabyMon()
        expect(find.text('Welcome to BabyMon!'), findsOneWidget);
        expect(find.text('Create one to get started.'), findsOneWidget);
        expect(find.text('Create BabyMon'), findsOneWidget);

        // fetchData should NOT have been called (no BabyMon ID)
        final state = tester.state<_DataScreenTestScreenState>(
          find.byType(_DataScreenTestScreen),
        );
        expect(state.fetchDataCallCount, equals(0));
      });
    });

    // ─────────────── Cooldown ───────────────

    group('cooldown', () {
      testWidgets('loadData skips fetch when within cooldown',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          cooldown: const Duration(minutes: 30),
          screenKey: key,
        ));

        // Initial load (not via autoInit so we control it)
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Call loadData again immediately — should be blocked by cooldown
        await key.currentState!.loadData();
        await tester.pump();
        expect(key.currentState!.fetchDataCallCount, equals(1));
      });

      testWidgets('force bypasses cooldown', (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          cooldown: const Duration(minutes: 30),
          autoInitValue: true,
          screenKey: key,
        ));

        // Wait for initial auto-load
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // force: true should bypass cooldown
        await key.currentState!.loadData(force: true);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(2));
      });

      testWidgets('onRefresh bypasses cooldown', (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          cooldown: const Duration(minutes: 30),
          autoInitValue: true,
          screenKey: key,
        ));

        // Wait for initial auto-load
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // onRefresh should bypass cooldown
        await key.currentState!.onRefresh();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(2));
      });

      testWidgets('force with null BabyMon resolves ID first, does not call fetchData',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: null),
          cooldown: const Duration(minutes: 30),
          screenKey: key,
        ));

        // Call loadData(force: true) — force bypasses cooldown check,
        // but BabyMon ID resolution still runs and finds null.
        await key.currentState!.loadData(force: true);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchData should NOT have been called (no BabyMon ID)
        expect(key.currentState!.fetchDataCallCount, equals(0));

        // isLoading should be false (loadData exited early when
        // getSelectedBabyMonId returned null)
        expect(key.currentState!.isLoading, isFalse);

        // babyMonId should still be null
        expect(key.currentState!.babyMonId, isNull);
      });

      testWidgets('force refresh resets cooldown timer', (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          cooldown: const Duration(minutes: 30),
          screenKey: key,
        ));

        // Initial load — sets _lastDataRefresh
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Force refresh — bypasses cooldown AND resets the timer
        await key.currentState!.loadData(force: true);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(key.currentState!.fetchDataCallCount, equals(2));

        // After force refresh, _lastDataRefresh was updated. A subsequent
        // non-force call should be blocked by the new cooldown window.
        await key.currentState!.loadData();
        await tester.pump();
        expect(key.currentState!.fetchDataCallCount, equals(2));
      });
    });

    // ─────────────── Re-entrancy guard ───────────────

    group('re-entrancy guard', () {
      testWidgets('concurrent loadData calls only execute once',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        final completer = Completer<void>();

        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: false,
          fetchCompleter: completer,
          slowFetch: false, // slowFetch is handled by completer
          screenKey: key,
        ));

        await tester.pump();

        // Start first loadData
        final firstFuture = key.currentState!.loadData();
        // At this point, _loadInProgress is true, fetchData awaits completer

        // Immediately start second loadData — should be skipped
        final secondFuture = key.currentState!.loadData();

        // Complete the completer to release the first call
        completer.complete();
        await Future.wait([firstFuture, secondFuture]);
        await tester.pump();

        // Only one fetchData call should have executed
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Guard should have released after completion
        expect(key.currentState!.loadInProgress, isFalse);
      });
    });

    // ─────────────── CancelToken lifecycle ───────────────

    group('cancelToken lifecycle', () {
      testWidgets('cancelToken is created on init and replaced on loadData',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: false,
          screenKey: key,
        ));

        await tester.pump();

        // cancelToken is created in initState
        expect(key.currentState!.cancelToken, isNotNull);
        final tokenBefore = key.currentState!.cancelToken;

        // loadData creates a new CancelToken
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // cancelToken should have been replaced (cancelled old, created new)
        expect(key.currentState!.cancelToken, isNotNull);
        expect(key.currentState!.cancelToken, isNot(equals(tokenBefore)));
      });

      testWidgets('previous cancelToken is cancelled when loadData starts new one',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: false,
          screenKey: key,
        ));

        await tester.pump();

        // Capture the initial cancelToken (created in initState)
        final oldToken = key.currentState!.cancelToken;
        expect(oldToken, isNotNull);
        expect(oldToken!.isCancelled, isFalse);

        // First loadData — replaces the initial token
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // The old initState token should now be cancelled
        expect(oldToken.isCancelled, isTrue);

        // Capture the current token (from first loadData)
        final secondToken = key.currentState!.cancelToken;
        expect(secondToken, isNotNull);
        expect(secondToken!.isCancelled, isFalse);

        // Second loadData — replaces the first token
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // The first token should now be cancelled
        expect(secondToken.isCancelled, isTrue);
        // Current token is fresh
        expect(key.currentState!.cancelToken, isNot(equals(secondToken)));
        expect(key.currentState!.cancelToken!.isCancelled, isFalse);
      });
    });

    // ─────────────── Dispose safety ───────────────

    group('dispose safety', () {
      testWidgets('no crash when widget is disposed mid-loadData',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        final completer = Completer<void>();

        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: false,
          fetchCompleter: completer,
          screenKey: key,
        ));

        await tester.pump();

        // Start loadData (awaits on completer inside fetchData)
        key.currentState!.loadData(); // intentional fire-and-forget

        // Dispose the widget by replacing it in the same ProviderScope
        // structure (same override count to satisfy Riverpod).
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWithValue(
                  _MockApi(babyMonId: 'baby-1')),
            ],
            child: MaterialApp(
      theme: AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.light),home: const SizedBox.shrink()),
          ),
        );

        // Widget is now unmounted. Complete the completer so the
        // in-flight loadData resumes — it should check `mounted`
        // before calling setState and skip it safely.
        completer.complete();

        // Pump to process the resumed future.
        // Importantly: this should NOT throw a "setState called after
        // dispose" error.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // If we reach here without an exception, the dispose safety works.
        // The state should no longer be accessible (widget was removed).
        expect(
          () => tester.state<_DataScreenTestScreenState>(
            find.byType(_DataScreenTestScreen),
          ),
          throwsA(isA<StateError>()),
        );
      });

      testWidgets('cancelToken is cancelled when widget disposes mid-loadData',
          (tester) async {
        final key = GlobalKey<_DataScreenTestScreenState>();
        final completer = Completer<void>();

        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: false,
          fetchCompleter: completer,
          screenKey: key,
        ));

        await tester.pump();

        // Start loadData — creates a new CancelToken internally
        key.currentState!.loadData(); // intentional fire-and-forget

        // Capture the current cancelToken (the one created by loadData)
        final token = key.currentState!.cancelToken;
        expect(token, isNotNull);
        expect(token!.isCancelled, isFalse);

        // Dispose the widget — dispose() should cancel the token
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWithValue(
                  _MockApi(babyMonId: 'baby-1')),
            ],
            child: const MaterialApp(home: SizedBox.shrink()),
          ),
        );

        // The captured token should now be cancelled
        expect(token.isCancelled, isTrue);

        // Complete the completer to allow cleanup
        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      });
    });

    // ─────────────── Error handling ───────────────

    group('error handling', () {
      testWidgets('fetchData exception is caught silently, spinner disappears',
          (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: const _ThrowingFetchScreen(),
        ));

        // Initial: loading spinner
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Process postFrameCallback → loadData → fetchData throws
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // After the exception: spinner is gone, error is silently caught
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('error then retry cycle: throws then succeeds on retry',
          (tester) async {
        final key = GlobalKey<_ErrorThenSuccessScreenState>();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: MaterialApp(
            home: _ErrorThenSuccessScreen(key: key),
          ),
        ));

        // Phase 1: autoInit → loadData → fetchData throws
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Error caught — spinner gone, guard released
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(key.currentState!.loadInProgress, isFalse);
        expect(key.currentState!.fetchDataCallCount, equals(1));

        // Phase 2: Flip shouldThrow so next fetchData succeeds
        key.currentState!.shouldThrow = false;

        // Phase 3: Retry loadData
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Success — body visible with data
        expect(key.currentState!.loadInProgress, isFalse);
        expect(key.currentState!.isLoading, isFalse);
        expect(key.currentState!.fetchDataCallCount, equals(2));
        expect(find.text('loaded: 2'), findsOneWidget);
      });

      testWidgets('loadInProgress is false after fetchData throws (re-entrancy guard releases)',
          (tester) async {
        final key = GlobalKey<_ThrowingFetchScreenState>();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: MaterialApp(
            home: _ThrowingFetchScreen(key: key),
          ),
        ));

        // autoInit=true → postFrameCallback fires loadData → fetchData throws.
        // Lightweight mocks → entire flow resolves in one pump.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // fetchData threw and was caught — guard should be released
        expect(key.currentState!.loadInProgress, isFalse);
        expect(key.currentState!.isLoading, isFalse);

        // Verify we CAN call loadData again (guard was released)
        await key.currentState!.loadData();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Second loadData also completed without crash
        expect(key.currentState!.loadInProgress, isFalse);
        expect(key.currentState!.isLoading, isFalse);
      });
    });

    // ─────────────── UI Builders ───────────────

    group('UI builders', () {
      testWidgets('buildLoading shows spinner', (tester) async {
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: null),
          autoInitValue: false,
        ));

        // With autoInit=false and no manual loadData,
        // _isLoading defaults to true → buildLoading() is shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('buildNoBabyMon shows welcome message', (tester) async {
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: null),
          autoInitValue: true,
        ));

        // Process postFrameCallback → loadData → null BabyMon → welcome
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Welcome to BabyMon!'), findsOneWidget);
        expect(find.text('Create one to get started.'), findsOneWidget);
        expect(find.text('Create BabyMon'), findsOneWidget);
      });

      testWidgets('buildEmptyState renders custom content',
          (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(_MockApi(babyMonId: 'baby-1')),
          ],
          child: const _EmptyStateTestScreen(),
        ));

        await tester.pump();

        // Custom empty state text should be rendered
        expect(find.text('Custom Empty Title'), findsOneWidget);
        expect(find.text('Custom Empty Subtitle'), findsOneWidget);
        expect(find.text('Custom Action'), findsOneWidget);

        // Custom icon should be present
        expect(find.byIcon(PhosphorIconsLight.star), findsOneWidget);
      });

      testWidgets('customEmptyWidget overrides default empty state',
          (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: const _CustomEmptyWidgetTestScreen(),
        ));

        await tester.pump();

        // The custom override widget should show, not a PremiumEmptyState
        expect(find.text('Custom override widget'), findsOneWidget);
        // Default empty state text should NOT be present
        expect(find.text('No items yet'), findsNothing);
      });

      testWidgets('buildScaffold shows body when data loaded',
          (tester) async {
        await tester.pumpWidget(_createTestApp(
          apiClient: _MockApi(babyMonId: 'baby-1'),
          autoInitValue: true,
        ));

        // Initial: loading spinner
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete loadData
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Loading spinner should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Body content should be visible
        expect(find.text('data loaded: 1'), findsOneWidget);
      });

      testWidgets('buildScaffold routing: loading → noBabyMon → body',
          (tester) async {
        // Phase 1: Loading state (autoInit=true, no pump yet)
        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: const _BuildScaffoldRoutingScreen(),
        ));

        // Loading state — spinner shown, body text not visible
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('BODY_VISIBLE'), findsNothing);

        // Phase 2: Data loads
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Data loaded — body visible, spinner gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('BODY_VISIBLE'), findsOneWidget);
      });

      testWidgets('buildScaffold routing: loading → noBabyMon shows welcome, not body',
          (tester) async {
        // Phase 1: Loading state (autoInit=true, no pump yet)
        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: null)),
          ],
          child: const _BuildScaffoldNoBabyMonScreen(),
        ));

        // Loading state — spinner shown, body text not visible
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('BODY_VISIBLE'), findsNothing);

        // Phase 2: loadData resolves null BabyMon ID → noBabyMon welcome
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Welcome screen shown (buildScaffold → hasBabyMon=false → buildNoBabyMon)
        expect(find.text('Welcome to BabyMon!'), findsOneWidget);
        // Body should NOT be visible
        expect(find.text('BODY_VISIBLE'), findsNothing);
      });

      testWidgets('onEmptyAction callback fires when empty state action is tapped',
          (tester) async {
        final key = GlobalKey<_OnEmptyActionScreenState>();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: _OnEmptyActionScreen(key: key),
        ));

        // Phase 1: Loading spinner
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Phase 2: Data loads (fetchData is no-op → items stay empty)
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Empty state shown with action button
        expect(find.text('No items yet'), findsOneWidget);
        expect(find.text('Add'), findsOneWidget);

        // Tap the action button
        await tester.tap(find.text('Add'));
        await tester.pump();

        // onEmptyAction was called
        expect(key.currentState!.emptyActionCount, equals(1));

        // Tap again — count increments
        await tester.tap(find.text('Add'));
        await tester.pump();
        expect(key.currentState!.emptyActionCount, equals(2));
      });

      testWidgets('rapid double-tap on onEmptyAction does not crash',
          (tester) async {
        final key = GlobalKey<_OnEmptyActionScreenState>();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: _OnEmptyActionScreen(key: key),
        ));

        // Wait for data to load (fetchData is no-op → empty state)
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Add'), findsOneWidget);

        // Rapid double-tap — both should fire without crash
        await tester.tap(find.text('Add'));
        await tester.tap(find.text('Add'));
        await tester.pump();

        // Both taps counted — no crash, no missed callback
        expect(key.currentState!.emptyActionCount, equals(2));

        // Triple-tap for good measure
        await tester.tap(find.text('Add'));
        await tester.tap(find.text('Add'));
        await tester.tap(find.text('Add'));
        await tester.pump();

        expect(key.currentState!.emptyActionCount, equals(5));
      });

      testWidgets('rapid taps on onEmptyAction do not stack async operations',
          (tester) async {
        final key = GlobalKey<_AsyncOnEmptyActionScreenState>();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: _AsyncOnEmptyActionScreen(key: key),
        ));

        // Wait for data to load → empty state shown
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Add'), findsOneWidget);

        // Rapid triple-tap — only the first should start async work
        await tester.tap(find.text('Add'));
        await tester.tap(find.text('Add'));
        await tester.tap(find.text('Add'));
        await tester.pump();

        // Only 1 action started (the guard blocked the other 2)
        expect(key.currentState!.emptyActionCount, equals(1));

        // Wait for the async work to complete
        await tester.pump(const Duration(milliseconds: 200));
        expect(key.currentState!.completedCount, equals(1));
        expect(key.currentState!.actionInProgress, isFalse);

        // Now tap again — should work since the guard is released
        await tester.tap(find.text('Add'));
        await tester.pump();
        expect(key.currentState!.emptyActionCount, equals(2));

        // Flush any remaining timers/microtasks before test teardown
        await tester.pumpAndSettle();
      });

      testWidgets('buildScaffold with customEmptyWidget renders custom widget through full pipeline',
          (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
                _MockApi(babyMonId: 'baby-1')),
          ],
          child: const _BuildScaffoldCustomScreen(),
        ));

        // Phase 1: Loading spinner (buildScaffold → buildLoading)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Phase 2: Data loads
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Loading spinner gone
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Custom widget shown through full pipeline:
        // buildScaffold → body → buildEmptyState → customEmptyWidget
        expect(
          find.text('buildScaffold custom widget'),
          findsOneWidget,
        );

        // Default empty state should NOT be rendered
        expect(find.text('No items yet'), findsNothing);
      });
    });

    // ─────────────── Integration: Feeding screen lifecycle ───────────────

    group('feeding screen integration', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      testWidgets('full lifecycle: loading → empty state → provider bump',
          (tester) async {
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(
              _FlexibleMock(babyMonId: 'baby-1', feedLogs: []),
            ),
          ],
        );
        addTearDown(() => container.dispose());

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: FeedingScreen()),
          ),
        );

        // Phase 1: Loading spinner (mixin's _isLoading = true on init)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Phase 2: postFrameCallback → loadData → fetchData → empty
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('No feeding logs yet'), findsOneWidget);
        expect(
          find.text(
              'Tap the button below to log your first feeding.'),
          findsOneWidget,
        );
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Phase 3: Bump appRefreshProvider — cooldown (10s) is active,
        // so the bump should be absorbed by the cooldown guard
        container.read(appRefreshProvider.notifier).state++;
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Empty state persists (no data added, but cooldown prevented
        // a redundant fetch). The important thing: no crash, no error.
        expect(find.text('No feeding logs yet'), findsOneWidget);

        // Phase 4: Force refresh bypasses cooldown via pull-to-refresh
        // Swipe down to trigger RefreshIndicator
        await tester.fling(
          find.text('No feeding logs yet'),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Still empty state (no new data) — no crash
        expect(find.text('No feeding logs yet'), findsOneWidget);
      });
    });
  });
}
