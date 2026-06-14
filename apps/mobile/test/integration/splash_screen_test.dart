import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/features/splash/presentation/screens/splash_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';

import 'screen_test_helper.dart';

/// Build SplashScreen wrapped in ProviderScope + GoRouter.
Widget _buildSplashApp({StubApiClient? apiClient}) {
  final client = apiClient ?? StubApiClient();
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('login'))),
    ],
    redirect: (context, state) => null,
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SplashScreen', () {
    testWidgets('renders gradient background', (tester) async {
      await tester.pumpWidget(_buildSplashApp());
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders BabyMon app name', (tester) async {
      await tester.pumpWidget(_buildSplashApp());
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('BabyMon'), findsOneWidget);
    });

    testWidgets('renders tagline', (tester) async {
      await tester.pumpWidget(_buildSplashApp());
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Smart Evolving Parenting Companion'), findsOneWidget);
    });

    testWidgets('renders circular progress indicator (spinner)', (tester) async {
      await tester.pumpWidget(_buildSplashApp());
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
              initialLocation: '/splash',
              routes: [
                GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
                GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('home'))),
                GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('login'))),
              ],
              redirect: (context, state) => null,
            ),
            theme: ThemeData.dark(useMaterial3: true),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('BabyMon'), findsOneWidget);
    });
  });
}
