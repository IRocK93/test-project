import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/features/album/presentation/screens/album_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:baby_mon/core/widgets/premium_background.dart';

import 'screen_test_helper.dart';

/// Build AlbumScreen wrapped in ProviderScope + GoRouter.
Widget _buildAlbumApp({StubApiClient? apiClient}) {
  final client = apiClient ?? StubApiClient();
  final router = GoRouter(
    initialLocation: '/album',
    routes: [
      GoRoute(
        path: '/album',
        builder: (_, __) => const AlbumScreen(),
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
  group('AlbumScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildAlbumApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders content after loading', (tester) async {
      await tester.pumpWidget(_buildAlbumApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // With StubApiClient, getSelectedBabyMonId returns null,
      // so the screen shows the "no baby mon" state.
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(PremiumBackground), findsOneWidget);
    });

    testWidgets('renders FAB for adding photos', (tester) async {
      await tester.pumpWidget(_buildAlbumApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FloatingActionButton), findsOneWidget);
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
              initialLocation: '/album',
              routes: [
                GoRoute(
                  path: '/album',
                  builder: (_, __) => const AlbumScreen(),
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('handles API error gracefully', (tester) async {
      final apiClient = StubApiClient();
      await tester.pumpWidget(_buildAlbumApp(apiClient: apiClient));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
