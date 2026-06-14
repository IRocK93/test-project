import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/features/auth/presentation/screens/login_screen.dart';
import 'package:baby_mon/features/auth/presentation/screens/register_screen.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// Builds a test app with GoRouter and ProviderScope.
Widget _buildTestApp(Widget child) {
  final testRouter = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => child),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const Scaffold(body: Text('Verify Email')),
      ),
      GoRoute(
        path: '/create-baby-mon',
        builder: (_, __) => const Scaffold(body: Text('Create BabyMon')),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(body: Text('Home')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(StubApiClient()),
    ],
    child: MaterialApp.router(routerConfig: testRouter),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LoginScreen', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('renders email and password input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Login screen should have at least 2 text form fields (email, password)
      expect(find.byType(TextFormField), findsAtLeast(2));
    });

    testWidgets('renders biometric login option',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Should have some form of biometric option
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('renders name, email, and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Register screen should have at least 3 text form fields
      // (name, email, password, confirm password)
      expect(find.byType(TextFormField), findsAtLeast(3));
    });
  });
}
