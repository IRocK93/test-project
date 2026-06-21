import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';

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
Widget _buildTestApp() {
  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/create-baby-mon',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Create BabyMon Page')),
        ),
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
  group('DashboardScreen — empty/welcome state', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows loading spinner initially', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      // First frame — _isLoading is true, postFrameCallback not yet fired
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your dashboard...'), findsOneWidget);
    });

    testWidgets('renders welcome screen when no BabyMon exists',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      // Process postFrameCallback, which starts _loadData() (async)
      await tester.pump();
      // Complete the async _loadData() — getSelectedBabyMonId returns null
      await tester.pump();

      // Welcome screen elements
      expect(find.text('Welcome to BabyMon!'), findsOneWidget);
      expect(
        find.text(
          'Create your first BabyMon to start tracking milestones, feedings, and more.',
        ),
        findsOneWidget,
      );
      expect(find.text('Create BabyMon'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsLight.baby), findsOneWidget);

      // FAB should NOT be present when no BabyMon is selected
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('create babymon button triggers navigation', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      await tester.pump();

      // Tap the "Create BabyMon" button
      await tester.tap(find.text('Create BabyMon'));
      await tester.pumpAndSettle();

      // Should navigate to /create-baby-mon
      expect(find.text('Create BabyMon Page'), findsOneWidget);
    });
  });
}
