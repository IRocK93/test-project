import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/health/domain/entities/growth_record.dart';
import 'package:baby_mon/features/health/presentation/screens/growth_chart_screen.dart';

/// GrowthChartScreen widget tests.
///
/// Covers:
///  - Chart rendering with mock growth data (4 weight records)
///  - Metric filter chip switching (Weight → Height)
///  - Zoom in / zoom out / reset zoom controls
///  - Loading state rendering
///  - GrowthRecord.fromJson data computation (pure logic)

// ── Minimal ApiClient mock for GrowthChartScreen ────────────────
class _GrowthMockApiClient extends ApiClient {
  final List<Map<String, dynamic>> weightData;
  final List<Map<String, dynamic>> heightData;
  String? lastRequestedType;

  _GrowthMockApiClient({required this.weightData, required this.heightData});

  Response<dynamic> _ok(dynamic data) => Response<dynamic>(
        data: data,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

  @override
  Future<Response> getGrowthRecords(String babyMonId, {bool forceRefresh = false, String? type}) async {
    lastRequestedType = type;
    final items = type == 'HEIGHT' ? heightData : weightData;
    return _ok({'items': items, 'total': items.length});
  }

  @override
  Future<String?> getSelectedBabyMonId() async => 'test-baby-1';

  @override
  Future<Response> createGrowthRecord(String babyMonId, Map<String, dynamic> data) async =>
      _ok({'id': 'new-record', ...data});

  @override
  Future<Response> deleteGrowthRecord(String babyMonId, String recordId) async =>
      _ok({'message': 'deleted'});

  @override
  Future<Response> updateGrowthRecord(String babyMonId, String recordId, Map<String, dynamic> data) async =>
      _ok({'id': recordId, ...data});
}

void main() {
  // ── Sample data ─────────────────────────────────────────────
  final sampleWeightRecords = [
    {
      'id': 'r1', 'type': 'WEIGHT', 'value': 3.5, 'unit': 'kg',
      'measuredAt': '2026-01-15T00:00:00.000Z', 'notes': 'Birth weight',
    },
    {
      'id': 'r2', 'type': 'WEIGHT', 'value': 4.2, 'unit': 'kg',
      'measuredAt': '2026-02-15T00:00:00.000Z', 'notes': '1 month',
    },
    {
      'id': 'r3', 'type': 'WEIGHT', 'value': 5.8, 'unit': 'kg',
      'measuredAt': '2026-03-15T00:00:00.000Z', 'notes': '2 month',
    },
    {
      'id': 'r4', 'type': 'WEIGHT', 'value': 7.1, 'unit': 'kg',
      'measuredAt': '2026-04-15T00:00:00.000Z', 'notes': '3 month',
    },
  ];

  final sampleHeightRecords = [
    {
      'id': 'h1', 'type': 'HEIGHT', 'value': 50.0, 'unit': 'cm',
      'measuredAt': '2026-01-15T00:00:00.000Z',
    },
    {
      'id': 'h2', 'type': 'HEIGHT', 'value': 56.0, 'unit': 'cm',
      'measuredAt': '2026-02-15T00:00:00.000Z',
    },
  ];

  /// Builds GrowthChartScreen with mock wired via ProviderScope.
  Widget buildWidget({_GrowthMockApiClient? mock}) {
    final api = mock ?? _GrowthMockApiClient(
      weightData: sampleWeightRecords,
      heightData: sampleHeightRecords,
    );

    return ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(api)],
      child: const MaterialApp(home: GrowthChartScreen()),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Pure data computation tests (no widget needed)
  // ─────────────────────────────────────────────────────────────
  group('GrowthRecord data computation', () {
    test('fromJson parses all fields correctly', () {
      final record = GrowthRecord.fromJson(sampleWeightRecords.first);

      expect(record.id, 'r1');
      expect(record.type, 'WEIGHT');
      expect(record.value, 3.5);
      expect(record.unit, 'kg');
      expect(record.notes, 'Birth weight');
      expect(record.measuredAt, isA<DateTime>());
      expect(record.measuredAt!.year, 2026);
      expect(record.measuredAt!.month, 1);
      expect(record.measuredAt!.day, 15);
    });

    test('records sort by measuredAt ascending', () {
      final records = sampleWeightRecords.map(GrowthRecord.fromJson).toList();
      records.sort((a, b) => (a.measuredAt ?? DateTime.now())
          .compareTo(b.measuredAt ?? DateTime.now()));

      final timestamps = records.map((r) => r.measuredAt!.millisecondsSinceEpoch).toList();
      for (int i = 1; i < timestamps.length; i++) {
        expect(timestamps[i], greaterThan(timestamps[i - 1]),
            reason: 'Timestamps must be monotonically increasing');
      }
      expect(records.map((r) => r.value).toList(), [3.5, 4.2, 5.8, 7.1]);
    });

    test('HEIGHT record parses correctly', () {
      final record = GrowthRecord.fromJson(sampleHeightRecords.first);
      expect(record.type, 'HEIGHT');
      expect(record.value, 50.0);
      expect(record.unit, 'cm');
    });

    test('empty records list is valid', () {
      final records = <GrowthRecord>[];
      expect(records.isEmpty, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Widget rendering tests
  // ─────────────────────────────────────────────────────────────
  group('GrowthChartScreen widget', () {
    testWidgets('renders with weight data — title, chips, zoom, FAB', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Growth Chart'), findsOneWidget);

      // Metric filter chips
      expect(find.text('Weight'), findsWidgets);
      expect(find.text('Height'), findsWidgets);
      expect(find.text('Head'), findsWidgets);

      // Weight label
      expect(find.text('Weight (kg)'), findsOneWidget);

      // Zoom controls
      expect(find.byTooltip('Zoom in'), findsOneWidget);
      expect(find.byTooltip('Zoom out'), findsOneWidget);
      expect(find.byTooltip('Reset zoom'), findsOneWidget);

      // FAB
      expect(find.byTooltip('Add growth record'), findsOneWidget);
    });

    testWidgets('switching metric to HEIGHT updates label and calls API', (tester) async {
      final mock = _GrowthMockApiClient(
        weightData: sampleWeightRecords,
        heightData: sampleHeightRecords,
      );

      await tester.pumpWidget(buildWidget(mock: mock));
      await tester.pumpAndSettle();

      // Initially WEIGHT
      expect(find.text('Weight (kg)'), findsOneWidget);

      // Tap HEIGHT filter chip
      await tester.tap(find.text('Height'));
      await tester.pumpAndSettle();

      // Should now show Height label
      expect(find.text('Height (cm)'), findsOneWidget);

      // API was called with type HEIGHT
      expect(mock.lastRequestedType, 'HEIGHT');
    });

    testWidgets('shows loading spinner when data is loading', (tester) async {
      final slowMock = _SlowMockApiClient();

      await tester.pumpWidget(ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(slowMock)],
        child: const MaterialApp(home: GrowthChartScreen()),
      ));
      await tester.pump(); // one frame — should show loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('zoom in changes zoom level from 1.0x', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Initial zoom is 1.0x
      expect(find.text('1.0x'), findsOneWidget);

      // Tap zoom in
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pumpAndSettle();

      // Zoom level should have changed
      expect(find.text('1.0x'), findsNothing);
    });

    testWidgets('reset zoom restores 1.0x after zooming', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Zoom in twice
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pumpAndSettle();

      // Should not be 1.0x anymore
      expect(find.text('1.0x'), findsNothing);

      // Reset
      await tester.tap(find.byTooltip('Reset zoom'));
      await tester.pumpAndSettle();

      // Back to 1.0x
      expect(find.text('1.0x'), findsOneWidget);
    });

    testWidgets('zoom out works from default 1.0x', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Tap zoom out
      await tester.tap(find.byTooltip('Zoom out'));
      await tester.pumpAndSettle();

      // After zooming out, level should be different
      expect(find.text('1.0x'), findsNothing);
    });
  });
}

/// Slow mock that delays getSelectedBabyMonId to keep loading state visible.
class _SlowMockApiClient extends _GrowthMockApiClient {
  _SlowMockApiClient() : super(weightData: [], heightData: []);

  @override
  Future<String?> getSelectedBabyMonId() async {
    await Future.delayed(const Duration(seconds: 5));
    return 'test-baby-1';
  }
}
