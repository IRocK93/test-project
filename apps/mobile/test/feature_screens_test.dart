import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/feeding/feeding.dart';
import 'package:baby_mon/features/journal/journal.dart';

// ─────────────────────────────────────────────
//  Mock ApiClient — returns no selected BabyMon
// ─────────────────────────────────────────────
class _MockApiClient extends ApiClient {
  @override
  Future<String?> getSelectedBabyMonId() async => null;
}

// ─────────────────────────────────────────────
//  Test App Shell (ProviderScope + GoRouter)
// ─────────────────────────────────────────────
Widget _buildTestApp(Widget screen) {
  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => screen,
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(_MockApiClient()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.light),
      title: 'BabyMon Test',
      routerConfig: goRouter,
    ),
  );
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────
void main() {
  group('FeedingScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows loading spinner initially', (tester) async {
      await tester.pumpWidget(_buildTestApp(const FeedingScreen()));
      // First frame — _isLoading is true
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows welcome screen when no BabyMon selected',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const FeedingScreen()));
      // Process postFrameCallback, start _loadData (async)
      await tester.pump();
      // Complete _loadData — getSelectedBabyMonId returns null
      await tester.pump();

      // DataScreenMixin buildNoBabyMon() is shown
      expect(find.text('Welcome to BabyMon!'), findsOneWidget);
      expect(find.text('Create one to get started.'), findsOneWidget);
      expect(find.text('Create BabyMon'), findsOneWidget);
    });
  });

  group('JournalScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows welcome screen when no BabyMon selected',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const JournalScreen()));
      await tester.pump();
      await tester.pump();

      // DataScreenMixin buildNoBabyMon() is shown
      expect(find.text('Welcome to BabyMon!'), findsOneWidget);
      expect(find.text('Create one to get started.'), findsOneWidget);
    });
  });
}
