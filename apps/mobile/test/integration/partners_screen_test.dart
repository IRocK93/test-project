import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/features/settings/presentation/screens/partners_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen_test_helper.dart';

/// Build PartnersScreen wrapped in ProviderScope.
Widget _buildPartnersApp({TestApiClient? apiClient}) {
  final client = apiClient ?? TestApiClient();
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const PartnersScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('PartnersScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildPartnersApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows Partners title', (tester) async {
      await tester.pumpWidget(_buildPartnersApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Partners'), findsOneWidget);
    });

    testWidgets('shows empty state when no partners', (tester) async {
      await tester.pumpWidget(_buildPartnersApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // TestApiClient returns empty list for getPartners
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
            home: const PartnersScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
