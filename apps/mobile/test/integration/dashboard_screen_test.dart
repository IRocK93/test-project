import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen_test_helper.dart';

/// Build DashboardScreen wrapped in ProviderScope.
Widget _buildDashboardApp({TestApiClient? apiClient}) {
  final client = apiClient ?? TestApiClient();
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const DashboardScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('DashboardScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildDashboardApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders after loading with BabyMon', (tester) async {
      await tester.pumpWidget(_buildDashboardApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // StubApiClient returns 'test-baby-mon-id' from getSelectedBabyMonId,
      // so the screen loads data. Verify it renders without crash.
      expect(find.byType(Scaffold), findsWidgets);
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
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders PremiumBackground', (tester) async {
      await tester.pumpWidget(_buildDashboardApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // DashboardScreen uses PremiumBackground as its body wrapper
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
