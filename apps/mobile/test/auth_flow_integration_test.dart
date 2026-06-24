import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/features/auth/auth.dart';

// ─────────────────────────────────────────────
//  Custom exception that formats cleanly
// ─────────────────────────────────────────────


// ─────────────────────────────────────────────
//  ApiClient mock for forgot-password flow
// ─────────────────────────────────────────────
class _MockApiClient extends ApiClient {
  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: <String, dynamic>{'message': 'ok'},
    );
  }
}

// ─────────────────────────────────────────────
//  Mock AuthRepository — supports full lifecycle
// ─────────────────────────────────────────────
class _MockAuthRepository extends AuthRepository {
  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    if (password == 'wrong') {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 401,
          data: {'message': 'Invalid email or password'},
        ),
      );
    }
    return (
      user: User(id: '1', email: email, createdAt: DateTime.now()),
      token: 'test-token',
    );
  }

  @override
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
  }) async {
    return (
      user: User(id: '2', email: email, name: name, createdAt: DateTime.now()),
      token: 'test-token',
    );
  }

  @override
  Future<({User user, String token})> biometricLogin() async {
    return (
      user: User(id: '1', email: 'bio@test.com', createdAt: DateTime.now()),
      token: 'bio-token',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> logout() async {}
  @override Future<String?> getAccessToken() async => null;
  @override Future<({String token, User user})> appleLogin(String idToken) async => throw UnimplementedError();
  @override Future<({String token, User user})> facebookLogin(String accessToken) async => throw UnimplementedError();
  @override Future<({String token, User user})> googleLogin(String idToken) async => throw UnimplementedError();

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<bool> checkEmailVerified() async => true;

  @override
  Future<void> sendVerificationEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {}
}

// ─────────────────────────────────────────────
//  Test App Shell
// ─────────────────────────────────────────────
Widget _buildTestApp(Widget screen) {
  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => screen,
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Home Page')),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/create-baby-mon',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Create Baby Page')),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Forgot Password Page')),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
      apiClientProvider.overrideWithValue(_MockApiClient()),
    ],
    child: MaterialApp.router(
      title: 'BabyMon Test',
      routerConfig: goRouter,
    ),
  );
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────
void main() {
  group('Auth Flow — Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // Clear any pending timers (e.g., from StaggeredFadeSlide)
      // by pumping a single frame. Not pumpAndSettle because the
      // app uses Timer.delayed which would never settle.
    });

    testWidgets('login → register navigation flow', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      // Starting on login screen
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Verify the navigation link exists
      final signupText = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Sign up'),
      );
      expect(signupText, findsOneWidget);

      // Navigate programmatically via GoRouter to verify the screen renders
      final router = GoRouter.of(
        tester.element(find.byType(LoginScreen)),
      );
      router.go('/register');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Should now be on register screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Navigate back to login via GoRouter
      router.go('/login');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Back on login screen
      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('login with valid credentials navigates to home',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      await tester.tap(find.text('Login'));
      // Use pump sequence instead of pumpAndSettle — animated_entry
      // StaggeredFadeSlide Timers delay animation starts indefinitely
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('login with wrong password shows error', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('register navigates to verification screen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name (optional)'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'newuser@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Password123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'Password123!',
      );

      await tester.tap(find.text('Sign Up'));
      // Use pump sequence — StaggeredFadeSlide Timers cause
      // pumpAndSettle to behave unpredictably
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // AuthNotifier.register always sets isEmailVerified=false
      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('newuser@example.com'), findsOneWidget);
    });

    testWidgets('forgot password opens bottom sheet and sends',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Send Reset Link'), findsOneWidget);

      // The bottom sheet TextField is inside a StatefulBuilder.
      // TextFormField (login form) creates internal TextField widgets,
      // so find only the one inside the bottom sheet's StatefulBuilder.
      final emailField = find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.byType(TextField),
      );
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();

      await tester.tap(find.text('Send Reset Link'));
      // Use pump sequence instead of pumpAndSettle — bottom sheet
      // fade animations and snackbar make pumpAndSettle time out.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Password reset link sent to your email'),
        findsOneWidget,
      );
    });

    testWidgets('verification screen renders and resends email',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const VerificationScreen(email: 'test@example.com'),
      ));
      await tester.pump();

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Resend Verification Email'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);

      await tester.tap(find.text('Resend Verification Email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      expect(
        find.text('Verification email sent! Check your inbox.'),
        findsOneWidget,
      );
    });

    testWidgets('verification back to login navigates correctly',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const VerificationScreen(email: 'test@example.com'),
      ));
      await tester.pump();

      await tester.tap(find.text('Back to Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('reset password validates mismatched passwords',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        const ResetPasswordScreen(token: 'valid-token'),
      ));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        'newpass123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different',
      );

      await tester.tap(find.widgetWithText(ThemeButton, 'Reset Password'));
      // Use pump sequence — StaggeredFadeSlide Timers cause
      // pumpAndSettle to behave unpredictably
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
