import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:baby_mon/app.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:baby_mon/features/auth/auth.dart';

class FakeLoggedInAuthNotifier extends AuthNotifier {
  FakeLoggedInAuthNotifier()
      : super(
          _FakeLoggedInAuthRepo(),
          googleServiceFactory: () => throw UnimplementedError(),
          appleServiceFactory: () => throw UnimplementedError(),
          facebookServiceFactory: () => throw UnimplementedError(),
        ) {
    state = AuthState(
      user: User(
        id: 'test-user-1', email: 'test@example.com', name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      ),
      token: 'test-token',
    );
  }
  @override
  Future<bool> checkAuth() async => true;
}

class _FakeLoggedInAuthRepo implements AuthRepository {
  @override Future<bool> isLoggedIn() async => true;
  @override Future<User?> getCurrentUser() async => User(
    id: 'test-user-1', email: 'test@example.com', name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
  );
  @override Future<void> logout() async {}
  @override Future<({User user, String token})> login({required String email, required String password}) async => throw UnimplementedError();
  @override Future<({User user, String token})> register({
    required String email, required String password, String? name,
    required DateTime dateOfBirth, required bool tosAccepted,
    required bool privacyAccepted, required bool consentToDataProcessing,
  }) async => throw UnimplementedError();
  @override Future<({User user, String token})> biometricLogin() async => throw UnimplementedError();
  @override Future<void> forgotPassword(String email) async {}
  @override Future<void> resetPassword(String token, String newPassword) async {}
  @override Future<void> sendVerificationEmail(String email) async {}
  @override Future<bool> checkEmailVerified() async => true;
}

Widget buildTestApp({AuthNotifier? authNotifier}) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(StubApiClient()),
      if (authNotifier != null) authProvider.overrideWith((ref) => authNotifier),
    ],
    child: const BabyMonApp(),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BabyMon Integration Tests', () {
    group('Unauthenticated flow', () {
      testWidgets('App starts and renders splash screen', (tester) async {
        await tester.pumpWidget(buildTestApp());
        expect(find.text('BabyMon'), findsOneWidget);
        expect(find.text('Smart Evolving Parenting Companion'), findsOneWidget);
      });

      testWidgets('Splash screen redirects to login screen', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle(const Duration(seconds: 15));
        expect(find.text('Welcome Back!'), findsOneWidget);
      });

      testWidgets('Can type credentials into login form', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle(const Duration(seconds: 15));
        final emailField = find.widgetWithText(TextFormField, 'Email');
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        expect(emailField, findsOneWidget);
        expect(passwordField, findsOneWidget);
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'mypassword123');
        await tester.pumpAndSettle();
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('Can navigate to register and back to login', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle(const Duration(seconds: 15));
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Create Account'), findsOneWidget);
        final loginLink = find.widgetWithText(RichText, 'Already have an account?');
        await tester.tap(loginLink);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Welcome Back!'), findsOneWidget);
      });
    });

    group('Authenticated flow', () {
      testWidgets('App renders MainScreen with nav tabs when logged in', (tester) async {
        await tester.pumpWidget(buildTestApp(authNotifier: FakeLoggedInAuthNotifier()));
        await tester.pumpAndSettle(const Duration(seconds: 15));
        expect(find.text('Dashboard'), findsWidgets);
        expect(find.text('Milestones'), findsWidgets);
        expect(find.text('Feeding'), findsWidgets);
        expect(find.text('Health'), findsWidgets);
        expect(find.text('More'), findsWidgets);
      });

      testWidgets('Bottom nav tabs switch content when tapped', (tester) async {
        await tester.pumpWidget(buildTestApp(authNotifier: FakeLoggedInAuthNotifier()));
        await tester.pumpAndSettle(const Duration(seconds: 15));
        await tester.tap(find.text('Milestones'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(find.text('Feeding'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(find.text('Health'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(find.text('Dashboard'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
      });
    });
  });


  @override
  Future<({User user, String token})> googleLogin(String idToken) async =>
      throw UnimplementedError();
  @override
  Future<({User user, String token})> appleLogin(String idToken) async =>
      throw UnimplementedError();
  @override
  Future<({User user, String token})> facebookLogin(String accessToken) async =>
      throw UnimplementedError();
}
