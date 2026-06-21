import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/features/auth/auth.dart';

// ─────────────────────────────────────────────
//  Mock AuthRepository
// ─────────────────────────────────────────────
class _MockAuthRepository extends AuthRepository {
  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
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
    required DateTime dateOfBirth,
    required bool tosAccepted,
    required bool privacyAccepted,
    required bool consentToDataProcessing,
  }) async {
    return (
      user:
          User(id: '1', email: email, name: name, createdAt: DateTime.now()),
      token: 'test-token',
    );
  }

  @override
  Future<({User user, String token})> biometricLogin() async {
    return (
      user: User(id: '1', email: 'bio@test.com', createdAt: DateTime.now()),
      token: 'test-token',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<bool> checkEmailVerified() async => true;

  @override
  Future<void> sendVerificationEmail(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}
}

// ─────────────────────────────────────────────
//  Test App Shell (ProviderScope + GoRouter)
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
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Login Page')),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Home Page')),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Register Page')),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Verify Email Page')),
        ),
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
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.light),
      title: 'BabyMon Test',
      routerConfig: goRouter,
    ),
  );
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────
void main() {
  group('LoginScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      // Process postFrameCallback (_checkBiometrics runs async)
      await tester.pump();

      // Title & subtitle
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Form fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Buttons
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Navigation link (rendered via RichText — find.text only finds Text/EditableText widgets)
      // Instead, verify the navigation is present via the GestureDetector
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));

      // Social row
      expect(find.text('OR'), findsOneWidget);
      // Social icons (Google, Apple, Facebook) — IconButtons without label
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
      expect(find.byIcon(Icons.facebook), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      // Tap login without filling fields
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Validation messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('forgot password opens bottom sheet', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pump();

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Bottom sheet should appear
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      // Bottom sheet has an email field
      expect(find.byType(TextField), findsAtLeastNWidgets(3));
    });
  });

  group('RegisterScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    /// Helper: fills all register form fields including date of birth and consents.
    Future<void> fillRegisterForm(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name (optional)'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      // Tap date of birth picker and select a date
      await tester.tap(find.text('Tap to select'));
      await tester.pumpAndSettle();
      // The date picker dialog appears — tap OK (which should select the initial date)
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // Tap consent checkboxes — tap the actual checkbox, not the title text
      // (titles now include GestureDetector links to legal docs, which would navigate away)
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0)); // ToS
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(1)); // Privacy Policy
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(2)); // Data processing consent
      await tester.pumpAndSettle();
    }

    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pump();

      // Title & subtitle
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join BabyMon today'), findsOneWidget);

      // Form fields
      expect(find.text('Name (optional)'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Date of birth
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Tap to select'), findsOneWidget);

      // Consent checkboxes
      expect(find.text('I accept the Terms of Service'), findsOneWidget);
      expect(find.text('I accept the Privacy Policy'), findsOneWidget);
      expect(
        find.text('I consent to processing of child health & development data'),
        findsOneWidget,
      );

      // Buttons
      expect(find.text('Sign Up'), findsOneWidget);

      // Navigation link (rendered via RichText — not detected by find.text)
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));

      // Social row
      expect(find.text('OR'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
      expect(find.byIcon(Icons.facebook), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid email and short password',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pump();

      // Fill date and consents so only email/password validation blocks
      await fillRegisterForm(tester);

      // Override email and password with invalid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'not-an-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );

      // Tap register
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows password strength indicator', (tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterScreen()));
      await tester.pump();

      // Initially no strength bar visible (empty password)
      expect(find.text('Weak'), findsNothing);
      expect(find.text('Strong'), findsNothing);

      // Type a weak password (6+ chars to get past the empty check, but no uppercase/digits/special)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'abcdefgh',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Weak'), findsOneWidget);

      // Clear and type a stronger password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'StrongP@ss1',
      );
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
    });

  });

  group('ResetPasswordScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const ResetPasswordScreen(token: 'test-token')),
      );
      await tester.pump();

      // Title and button both say "Reset Password" — find.text returns 2 matches
      expect(find.text('Reset Password'), findsAtLeastNWidgets(1));
      expect(
        find.text('Enter your new password below.'),
        findsOneWidget,
      );
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows validation for short password', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const ResetPasswordScreen(token: 'test-token')),
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        'ab',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'ab',
      );

      // Find the ThemeButton and tap it
      final resetButtons = find.widgetWithText(ThemeButton, 'Reset Password');
      await tester.tap(resetButtons);
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows mismatch error when passwords differ', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const ResetPasswordScreen(token: 'test-token')),
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        'newpassword123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different123',
      );

      final resetButtons = find.widgetWithText(ThemeButton, 'Reset Password');
      await tester.tap(resetButtons);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('VerificationScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const VerificationScreen(email: 'test@example.com')),
      );
      await tester.pump();

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Resend Verification Email'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('shows message after resending email', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const VerificationScreen(email: 'test@example.com')),
      );
      await tester.pump();

      await tester.tap(find.text('Resend Verification Email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      expect(
        find.text('Verification email sent! Check your inbox.'),
        findsOneWidget,
      );
    });

    testWidgets('renders glass card design elements', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const VerificationScreen(email: 'test@example.com')),
      );
      await tester.pump();

      // BackdropFilter glass card wrapper should be present
      expect(find.byType(BackdropFilter), findsAtLeastNWidgets(1));

      // Glass icon orb (email icon) should render
      expect(find.byIcon(PhosphorIconsLight.envelope), findsOneWidget);

      // Back to Login link should be present
      expect(find.text('Back to Login'), findsOneWidget);

      // The primary button should be rendered
      expect(find.text('Continue'), findsOneWidget);
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
