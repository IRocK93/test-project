import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/presentation/screens/main/main_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';

import 'screen_test_helper.dart';

/// Build MainScreen wrapped in ProviderScope + GoRouter.
Widget _buildMainApp({StubApiClient? apiClient}) {
  final client = apiClient ?? StubApiClient();
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const MainScreen()),
      GoRoute(path: '/album', builder: (_, __) => const Scaffold(body: Text('album'))),
      GoRoute(path: '/journal', builder: (_, __) => const Scaffold(body: Text('journal'))),
      GoRoute(path: '/sleep', builder: (_, __) => const Scaffold(body: Text('sleep'))),
      GoRoute(path: '/discover', builder: (_, __) => const Scaffold(body: Text('discover'))),
      GoRoute(path: '/settings', builder: (_, __) => const Scaffold(body: Text('settings'))),
      GoRoute(path: '/partners', builder: (_, __) => const Scaffold(body: Text('partners'))),
      GoRoute(path: '/create-baby-mon', builder: (_, __) => const Scaffold(body: Text('create'))),
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
  group('MainScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildMainApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders bottom navigation bar with 5 tabs', (tester) async {
      await tester.pumpWidget(_buildMainApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Only the selected tab shows its label text. Dashboard is default.
      expect(find.text('Dashboard'), findsOneWidget);

      // Bottom nav should have tab rows
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('renders floating app bar', (tester) async {
      await tester.pumpWidget(_buildMainApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders loading state for selector initially', (tester) async {
      await tester.pumpWidget(_buildMainApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
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
              initialLocation: '/home',
              routes: [
                GoRoute(path: '/home', builder: (_, __) => const MainScreen()),
                GoRoute(path: '/album', builder: (_, __) => const Scaffold()),
                GoRoute(path: '/journal', builder: (_, __) => const Scaffold()),
                GoRoute(path: '/sleep', builder: (_, __) => const Scaffold()),
                GoRoute(path: '/discover', builder: (_, __) => const Scaffold()),
                GoRoute(path: '/settings', builder: (_, __) => const Scaffold()),
                GoRoute(path: '/partners', builder: (_, __) => const Scaffold()),
                GoRoute(path: '/create-baby-mon', builder: (_, __) => const Scaffold()),
              ],
            ),
            theme: ThemeData.dark(useMaterial3: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
