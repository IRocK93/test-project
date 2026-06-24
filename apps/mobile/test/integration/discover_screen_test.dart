import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/features/discover/presentation/screens/discover_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';

import 'screen_test_helper.dart';
import 'fake_auth_helpers.dart';

/// Build DiscoverScreen wrapped in ProviderScope + GoRouter.
Widget _buildDiscoverApp({StubApiClient? apiClient}) {
  final client = apiClient ?? StubApiClient();
  final router = GoRouter(
    initialLocation: '/discover',
    routes: [
      GoRoute(
        path: '/discover',
        builder: (_, __) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(body: Text('home')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
    ),
  );
}

void main() {
  group('DiscoverScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildDiscoverApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows COMING SOON tag', (tester) async {
      await tester.pumpWidget(_buildDiscoverApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('COMING SOON'), findsOneWidget);
    });

    testWidgets('shows Discover title', (tester) async {
      await tester.pumpWidget(_buildDiscoverApp());
      await tester.pump(const Duration(milliseconds: 500));

      // 'Discover' appears in both the title and the AppBar — find at least one
      expect(find.text('Discover'), findsWidgets);
    });

    testWidgets('shows description text', (tester) async {
      await tester.pumpWidget(_buildDiscoverApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('New features, tips, and community content coming your way.'),
        findsOneWidget,
      );
    });

    testWidgets('shows Stay tuned card', (tester) async {
      await tester.pumpWidget(_buildDiscoverApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Stay tuned!'), findsOneWidget);
      expect(find.text('We\'re working on something special'), findsOneWidget);
    });

    testWidgets('renders on dark theme without error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(StubApiClient()),
            authProvider.overrideWith((ref) => FakeAuthNotifier()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/discover',
              routes: [
                GoRoute(
                  path: '/discover',
                  builder: (_, __) => const DiscoverScreen(),
                ),
                GoRoute(
                  path: '/home',
                  builder: (_, __) => const Scaffold(body: Text('home')),
                ),
              ],
            ),
            theme: ThemeData.dark(useMaterial3: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('COMING SOON'), findsOneWidget);
    });
  });
}
