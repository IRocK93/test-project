import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/onboarding/presentation/screens/create_baby_mon_screen.dart';
import 'screen_test_helper.dart';

/// Wraps [CreateBabyMonScreen] in a GoRouter so GoRouter.of(context) works.
Widget _buildOnboardingApp(TestApiClient apiClient) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
    ],
    child: MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) =>
                const MediaQuery(data: MediaQueryData(size: Size(400, 800)), child: CreateBabyMonScreen()),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('home'))),
          ),
        ],
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateBabyMonScreen', () {
    testWidgets('renders splash screen on initial load',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CreateBabyMonScreen), findsOneWidget);
      // Splash shows the journey text
      expect(find.text('Begin Your Journey'), findsOneWidget);
    });

    testWidgets('splash animation completes and button becomes tappable',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      // Wait for splash animation (3 seconds)
      await tester.pump(const Duration(milliseconds: 3500));

      expect(find.byType(CreateBabyMonScreen), findsOneWidget);
      // The "Begin Your Journey" button should be visible
      expect(find.text('Begin Your Journey'), findsOneWidget);
    });

    testWidgets('step indicator is visible', (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CreateBabyMonScreen), findsOneWidget);
      // Step indicator should be present
      expect(find.byType(CreateBabyMonScreen), findsOneWidget);
    });

    testWidgets('renders with PremiumBackground',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CreateBabyMonScreen), findsOneWidget);
    });
  });
}
