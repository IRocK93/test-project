import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/features/auth/presentation/screens/login_screen.dart';
import 'package:baby_mon/features/auth/presentation/screens/register_screen.dart';

/// Integration tests for the auth flow — verifies screen rendering, form validation,
/// navigation, and edge case states without requiring a real backend.
void main() {
  testWidgets('Login screen renders all required elements', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(2)); // email + password
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login form validates empty fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Tap sign-in with empty fields
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Validation errors should appear
    expect(find.textContaining('email'), findsWidgets);
  });

  testWidgets('Register screen renders all required elements', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsAtLeast(3)); // email, password, name
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.textContaining('Terms'), findsOneWidget);
    expect(find.textContaining('Privacy'), findsOneWidget);
  });

  testWidgets('Register form requires consent checkboxes', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Try to submit without checking consent
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    // Should show consent error
    expect(find.textContaining('accept'), findsWidgets);
  });

  testWidgets('Login screen has social login buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Social login section should be present
    expect(find.text('or continue with'), findsOneWidget);
  });

  testWidgets('Login screen has forgot password option', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Login screen navigates to register', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/register': (context) => const RegisterScreen(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
  });
}
