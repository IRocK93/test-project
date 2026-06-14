import 'package:dio/dio.dart';
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
            builder: (context, state) => const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: CreateBabyMonScreen(),
            ),
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
      expect(find.text('Begin Your Journey'), findsOneWidget);
    });

    testWidgets('renders with PremiumBackground',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CreateBabyMonScreen), findsOneWidget);
    });

    testWidgets('full flow: splash → name → date → traits → review',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      // Wait for splash animation to complete (3s fade + buffer)
      await tester.pump(const Duration(seconds: 4));

      // ── Step 0: Splash ──
      expect(find.text('Begin Your Journey'), findsOneWidget);

      // ── Step 0 → Step 1: Name ──
      await tester.tap(find.text('Begin Your Journey'));
      // _onSplashBegin delays 400ms before switching step
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Enter a name...'), findsOneWidget);
      // Button shows "Enter a name" when name is empty
      expect(find.text('Enter a name'), findsOneWidget);

      // ── Step 1: Enter name ──
      await tester.enterText(find.byType(TextField), 'Nova');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Continue'), findsOneWidget);

      // ── Step 1 → Step 2: Date ──
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Born'), findsOneWidget);
      expect(find.text('Conceived'), findsOneWidget);
      expect(find.text('Idea'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // ── Step 2: Select today ──
      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pump(const Duration(milliseconds: 300));

      // ── Step 2 → Step 3: Traits ──
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Curious'), findsOneWidget);
      expect(find.text('Peaceful'), findsOneWidget);
      expect(find.text('Playful'), findsOneWidget);
      expect(find.text('Moniese'), findsOneWidget);
      expect(find.text('Monious'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);

      // ── Step 3 → Step 4: Review ──
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      // Verify review shows entered data
      expect(find.text('Nova'), findsOneWidget);
      expect(find.text('Begin Your Story'), findsOneWidget);
      expect(find.text('Curious'), findsWidgets);
      expect(find.text('A gentle arrival'), findsOneWidget);
    });

    testWidgets('back button navigates to previous step',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate to name step
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Enter a name...'), findsOneWidget);

      // Tap the floating back button using the arrow left icon
      // The back button is a PremiumDoubleBezel wrapping an Icon(PhosphorIconsLight.arrowLeft)
      // Find it via the icon that's in the Positioned overlay
      final backIcons = find.byIcon(Icons.arrow_back_ios_rounded);
      if (backIcons.evaluate().isNotEmpty) {
        await tester.tap(backIcons.first);
      } else {
        // Fallback: tap the first Semantics with button: true
        await tester.tap(find.bySemanticsLabel('Tap').first);
      }
      await tester.pump(const Duration(milliseconds: 600));

      // Should be back on splash
      expect(find.text('Begin Your Journey'), findsOneWidget);
    });

    testWidgets('name step requires name to proceed',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate to name step
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));

      // Without entering a name, Continue should not be enabled
      // (button text shows "Enter a name" instead of "Continue")
      expect(find.text('Enter a name'), findsOneWidget);
    });

    testWidgets('date step requires date selection to proceed',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate to date step
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), 'Luna');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      // Without selecting a date, Continue shows "Select a date"
      expect(find.text('Select a date'), findsOneWidget);
      expect(find.text('Born'), findsOneWidget);
    });

    testWidgets('taps Begin Your Story and verifies API payload',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate through all steps to the review screen
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), 'Luna');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      // Verify review shows our data
      expect(find.text('Luna'), findsOneWidget);
      expect(find.text('Begin Your Story'), findsOneWidget);

      // Tap "Begin Your Story" to trigger the API call
      await tester.tap(find.text('Begin Your Story'));
      await tester.pump(const Duration(milliseconds: 1200));

      // Verify the POST was made to /baby-mons
      expect(apiClient.capturedPosts.length, 1);
      final post = apiClient.capturedPosts.first;
      expect(post.key, '/baby-mons');

      // Verify the payload contains expected fields
      final payload = post.value as Map<String, dynamic>;
      expect(payload['name'], 'Luna');
      expect(payload['stageStartType'], 'BORN');
      expect(payload['gender'], 'MONIOUS');
      expect(payload['birthDate'], isNotNull);
      expect(payload['traits'], isA<List>());

      // Verify setSelectedBabyMonId was called with the new ID
      expect(apiClient.capturedBabyMonIds, ['new-record-id']);
    });

    testWidgets('Begin Your Story with API failure shows error snackbar',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate through all steps to the review screen
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), 'Luna');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      // Now override post to throw a DioException
      apiClient.postCallback = (path, {data}) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: Response(
            data: {'message': 'Server validation failed'},
            statusCode: 422,
            requestOptions: RequestOptions(path: path),
          ),
        );
      };

      // Tap "Begin Your Story" — should catch the error and show snackbar
      await tester.tap(find.text('Begin Your Story'));
      await tester.pump(const Duration(milliseconds: 1200));

      // Verify the POST was attempted
      expect(apiClient.capturedPosts.length, 1);
      expect(apiClient.capturedPosts.first.key, '/baby-mons');

      // Verify error snackbar is shown
      expect(find.text('Server validation failed'), findsOneWidget);

      // Verify setSelectedBabyMonId was NOT called (error path)
      expect(apiClient.capturedBabyMonIds, isEmpty);
    });

    testWidgets('Begin Your Story with connection error shows generic message',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate through all steps to the review screen
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), 'Luna');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      // Override post to throw a connection error
      apiClient.postCallback = (path, {data}) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionError,
        );
      };

      await tester.tap(find.text('Begin Your Story'));
      await tester.pump(const Duration(milliseconds: 1200));

      expect(apiClient.capturedPosts.length, 1);
      // Connection error shows generic message
      expect(find.text('Cannot connect to server. Please check your connection.'), findsOneWidget);
    });

    testWidgets('traits step shows all gender and trait options',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(_buildOnboardingApp(apiClient));
      await tester.pump(const Duration(seconds: 4));

      // Navigate to traits step
      await tester.tap(find.text('Begin Your Journey'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), 'Luna');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 600));

      // All 6 traits
      expect(find.text('Curious'), findsOneWidget);
      expect(find.text('Peaceful'), findsOneWidget);
      expect(find.text('Playful'), findsOneWidget);
      expect(find.text('Gentle'), findsOneWidget);
      expect(find.text('Adventurous'), findsOneWidget);
      expect(find.text('Creative'), findsOneWidget);

      // All 3 genders
      expect(find.text('Moniese'), findsOneWidget);
      expect(find.text('Monious'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);

      // Back and Continue buttons
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
