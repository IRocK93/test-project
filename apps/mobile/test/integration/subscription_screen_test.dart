import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/features/settings/presentation/screens/subscription_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen_test_helper.dart';

/// Build SubscriptionScreen wrapped in ProviderScope.
Widget _buildSubscriptionApp({TestApiClient? apiClient}) {
  final client = apiClient ?? TestApiClient();
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const SubscriptionScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('SubscriptionScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildSubscriptionApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows Plans title', (tester) async {
      await tester.pumpWidget(_buildSubscriptionApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Plans'), findsOneWidget);
    });

    testWidgets('shows Free and Premium plan names', (tester) async {
      await tester.pumpWidget(_buildSubscriptionApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Premium'), findsWidgets);
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
            home: const SubscriptionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
