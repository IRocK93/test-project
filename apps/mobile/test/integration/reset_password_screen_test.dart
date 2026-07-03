import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen_test_helper.dart';

/// Build ResetPasswordScreen wrapped in ProviderScope.
Widget _buildResetPasswordApp({TestApiClient? apiClient}) {
  final client = apiClient ?? TestApiClient();
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const ResetPasswordScreen(token: 'test-reset-token'),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('ResetPasswordScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildResetPasswordApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows Reset Password title', (tester) async {
      await tester.pumpWidget(_buildResetPasswordApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 'Reset Password' appears in both the title and the button
      expect(find.text('Reset Password'), findsWidgets);
    });

    testWidgets('shows password input fields', (tester) async {
      await tester.pumpWidget(_buildResetPasswordApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows Reset Password button', (tester) async {
      await tester.pumpWidget(_buildResetPasswordApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 'Reset Password' appears in both title and button - check for at least 2
      expect(find.text('Reset Password'), findsNWidgets(2));
    });

    testWidgets('renders on dark theme without error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(TestApiClient()),
            authProvider.overrideWith((ref) => FakeAuthNotifier()),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(useMaterial3: true),
            home: const ResetPasswordScreen(token: 'test-reset-token'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
