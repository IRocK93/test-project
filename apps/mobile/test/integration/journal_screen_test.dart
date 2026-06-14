import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/features/journal/presentation/screens/journal_screen.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen_test_helper.dart';

/// Build JournalScreen wrapped in ProviderScope.
Widget _buildJournalApp({TestApiClient? apiClient}) {
  final client = apiClient ?? TestApiClient();
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const JournalScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('JournalScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildJournalApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows Journey Journal title', (tester) async {
      await tester.pumpWidget(_buildJournalApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Journey Journal'), findsOneWidget);
    });

    testWidgets('shows filter chips', (tester) async {
      await tester.pumpWidget(_buildJournalApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('tapping filter chip changes selection', (tester) async {
      await tester.pumpWidget(_buildJournalApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the Milestones filter chip
      final milestonesChip = find.text('Milestones');
      expect(milestonesChip, findsOneWidget);
      await tester.tap(milestonesChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Screen should still render after filter change
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
            home: const JournalScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
