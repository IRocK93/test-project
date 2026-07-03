import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/features/auth/presentation/screens/login_screen.dart';
import 'package:baby_mon/features/auth/presentation/screens/register_screen.dart';
import 'package:baby_mon/features/auth/domain/repositories/auth_repository.dart';
import 'package:baby_mon/features/auth/domain/entities/user.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// Simple fake auth repository that returns not-logged-in state.
/// Prevents AuthNotifier from hitting SharedPreferences.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async => (
    user: User(id: '1', email: email, createdAt: DateTime(2024)),
    token: 'token',
  );

  @override
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
    required DateTime dateOfBirth,
    required bool tosAccepted,
    required bool privacyAccepted,
    required bool consentToDataProcessing,
  }) async => (
    user: User(id: '2', email: email, name: name, createdAt: DateTime(2024)),
    token: 'reg-token',
  );

  @override
  Future<({User user, String token})> biometricLogin() async => (
    user: User(id: '3', email: 'bio@test.com', createdAt: DateTime(2024)),
    token: 'bio-token',
  );

  @override
  Future<void> logout() async {}
  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<User?> getCurrentUser() async => null;  @override Future<void> forgotPassword(String email) async {}
  @override Future<void> resetPassword(String token, String newPassword) async {}
  @override Future<void> sendVerificationEmail() async {}
  @override Future<bool> checkEmailVerified() async => true;
  @override Future<String?> getAccessToken() async => null;
  @override Future<({User user, String token})> googleLogin(String idToken) async => throw UnimplementedError();
  @override Future<({User user, String token})> appleLogin(String idToken) async => throw UnimplementedError();
  @override Future<({User user, String token})> facebookLogin(String accessToken) async => throw UnimplementedError();
  @override Future<void> syncLocale() async {}
}

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
      // Override authRepositoryProvider to bypass the entire
      // authRemoteDatasourceProvider → sharedPreferencesProvider chain.
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
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
      expect(find.byType(TextFormField), findsAtLeast(3));
    });
  });
}
