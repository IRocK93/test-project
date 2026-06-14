import 'package:dio/dio.dart';
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

class _FakeAuthRepository implements AuthRepository {
  bool shouldFailLogin = false;
  bool shouldFailRegister = false;
  String? loginErrorMessage;
  String? registerErrorMessage;
  bool loginCalled = false;
  bool registerCalled = false;
  String? lastLoginEmail;
  String? lastRegisterEmail;

  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    loginCalled = true;
    lastLoginEmail = email;
    if (shouldFailLogin) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {'message': loginErrorMessage ?? 'Invalid credentials'},
        ),
      );
    }
    return (
      user: User(id: '1', email: email, createdAt: DateTime(2024)),
      token: 'test-token',
    );
  }

  @override
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
  }) async {
    registerCalled = true;
    lastRegisterEmail = email;
    if (shouldFailRegister) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 409,
          data: {'message': registerErrorMessage ?? 'Email already registered'},
        ),
      );
    }
    return (
      user: User(id: '2', email: email, name: name, createdAt: DateTime(2024)),
      token: 'reg-token',
    );
  }

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
  Future<User?> getCurrentUser() async => null;
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> resetPassword(String token, String newPassword) async {}
  @override
  Future<void> sendVerificationEmail(String email) async {}
  @override
  Future<bool> checkEmailVerified() async => true;
}

late _FakeAuthRepository _fakeRepo;

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
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
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
      authRepositoryProvider.overrideWithValue(_fakeRepo),
    ],
    child: MaterialApp.router(routerConfig: testRouter),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _fakeRepo = _FakeAuthRepository();
  });

  group('LoginScreen form validation', () {
    testWidgets('renders email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeast(2));
    });

    testWidgets('shows error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      final loginButton = find.text('Login');
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error for empty password', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('calls login with valid credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(_fakeRepo.loginCalled, isTrue);
      expect(_fakeRepo.lastLoginEmail, 'test@test.com');
    });

    testWidgets(
        'calls login with any email format (no client-side format check)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // LoginScreen only checks for empty, not format
      expect(_fakeRepo.loginCalled, isTrue);
      expect(_fakeRepo.lastLoginEmail, 'not-an-email');
    });

    testWidgets('shows server error text when login fails',
        (WidgetTester tester) async {
      _fakeRepo.shouldFailLogin = true;
      _fakeRepo.loginErrorMessage = 'Invalid credentials';

      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrong');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });

  group('RegisterScreen form validation', () {
    testWidgets('renders name, email, and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeast(3));
    });

    testWidgets('name field is optional (no validator)', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Fill required fields but leave name empty
      await tester.enterText(find.byType(TextFormField).at(1), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Should succeed without a name
      expect(_fakeRepo.registerCalled, isTrue);
    });

    testWidgets('shows error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test User');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'short');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for mismatched passwords',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(
          find.byType(TextFormField).at(3), 'different123');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('calls register with valid credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(_fakeRepo.registerCalled, isTrue);
      expect(_fakeRepo.lastRegisterEmail, 'test@test.com');
    });

    testWidgets('shows server error text when registration fails',
        (WidgetTester tester) async {
      _fakeRepo.shouldFailRegister = true;
      _fakeRepo.registerErrorMessage = 'Email already registered';

      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'existing@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Email already registered'), findsOneWidget);
    });
  });
}
