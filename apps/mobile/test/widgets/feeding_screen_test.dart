import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/feeding/feeding.dart';

// ─────────────────────────────────────────────
//  Mock ApiClient implementations
// ─────────────────────────────────────────────

/// Returns no selected BabyMon (null ID).
class _NoBabyMonMock extends ApiClient {
  @override
  Future<String?> getSelectedBabyMonId() async => null;
}

/// Returns a selected BabyMon ID and custom feed logs.
class _FeedingMock extends ApiClient {
  final List<Map<String, dynamic>>? feedLogs;
  final bool shouldThrow;

  _FeedingMock({this.feedLogs, this.shouldThrow = false});

  @override
  Future<String?> getSelectedBabyMonId() async => 'baby-1';

  @override
  Future<Response> getFeedLogs(String babyMonId, {bool forceRefresh = false}) async {
    if (shouldThrow) throw Exception('API is down');
    return Response<dynamic>(
      data: feedLogs ?? [],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/test'),
    );
  }
}

// ─────────────────────────────────────────────
//  Test App Shell
// ─────────────────────────────────────────────

Widget _buildTestApp(Widget screen, {required ApiClient apiClient}) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
    ],
    child: MaterialApp(
      theme: AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.light),
      home: screen,
    ),
  );
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────
void main() {
  group('FeedingScreen (DataScreenMixin)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows loading spinner initially', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const FeedingScreen(),
        apiClient: _FeedingMock(),
      ));

      // First frame — isLoading is true (mixin default)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows welcome screen when no BabyMon selected',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const FeedingScreen(),
        apiClient: _NoBabyMonMock(),
      ));
      // Process postFrameCallback, start loadData (async)
      await tester.pump();
      // Complete loadData — getSelectedBabyMonId returns null
      await tester.pump();

      // DataScreenMixin buildNoBabyMon() is shown
      expect(find.text('Welcome to BabyMon!'), findsOneWidget);
      expect(find.text('Create one to get started.'), findsOneWidget);
    });

    testWidgets('handles API error gracefully', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const FeedingScreen(),
        apiClient: _FeedingMock(shouldThrow: true),
      ));
      // Process postFrameCallback → loadData → fetchData → API throws
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // After error: isLoading is false, no spinner.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });



    testWidgets('shows empty state when no feed logs', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const FeedingScreen(),
        apiClient: _FeedingMock(feedLogs: []),
      ));
      // Process postFrameCallback → loadData → fetchData → empty array
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Loading spinner is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Empty state from mixin is shown
      expect(find.text('No feeding logs yet'), findsOneWidget);
      expect(
        find.text('Tap the button below to log your first feeding.'),
        findsOneWidget,
      );
      expect(find.byIcon(PhosphorIconsLight.bowlFood), findsOneWidget);

      // FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
