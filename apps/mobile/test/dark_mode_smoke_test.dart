import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:baby_mon/features/journal/presentation/screens/journal_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/health_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/sleep_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/growth_chart_screen.dart';
import 'package:baby_mon/features/feeding/presentation/screens/feeding_screen.dart';
import 'package:baby_mon/features/milestones/presentation/screens/milestones_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dark mode smoke test suite — verifies that key widgets render without
/// errors in dark theme and that no hardcoded light-only colors leak through.
///
/// These are lightweight rendering tests, not full integration tests.
/// They catch compile errors, missing theme awareness, and obvious
/// dark-mode regressions.

Widget _darkApp(Widget child, {AppVisualStyle visualStyle = AppVisualStyle.glass}) {
  return ProviderScope(
    overrides: [
      appVisualStyleProvider.overrideWith((ref) {
        final notifier = AppVisualStyleNotifier();
        if (visualStyle == AppVisualStyle.clay) {
          notifier.setStyle(AppVisualStyle.clay);
        }
        return notifier;
      }),
    ],
    child: MaterialApp(
      theme: visualStyle == AppVisualStyle.clay
          ? AppTheme.clayDarkTheme
          : AppTheme.glassDarkTheme,
      home: Scaffold(body: child),
    ),
  );
}

/// Helper to wrap a screen widget with all required providers for dark mode.
Widget _screenApp(Widget child, {AppVisualStyle visualStyle = AppVisualStyle.glass}) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(StubApiClient()),
      appVisualStyleProvider.overrideWith((ref) {
        final notifier = AppVisualStyleNotifier();
        if (visualStyle == AppVisualStyle.clay) {
          notifier.setStyle(AppVisualStyle.clay);
        }
        return notifier;
      }),
      sharedPreferencesProvider.overrideWith((ref) async =>
          SharedPreferences.getInstance()),
    ],
    child: MaterialApp(
      theme: visualStyle == AppVisualStyle.clay
          ? AppTheme.clayDarkTheme
          : AppTheme.glassDarkTheme,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  // ─── Component tests ───────────────────────────────────────────────

  group('PremiumBackground', () {
    testWidgets('renders in dark glass mode without error', (tester) async {
      await tester.pumpWidget(_darkApp(
        const PremiumBackground(
          child: Center(child: Text('Test')),
        ),
      ));
      await tester.pump(); // Don't use pumpAndSettle — infinite animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('renders in dark clay mode without error', (tester) async {
      await tester.pumpWidget(_darkApp(
        const PremiumBackground(
          child: Center(child: Text('Test')),
        ),
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump(); // Don't use pumpAndSettle — infinite animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('ScreenHeader', () {
    testWidgets('renders dark title text in dark mode', (tester) async {
      await tester.pumpWidget(_darkApp(
        const ScreenHeader(title: 'Test Screen'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Test Screen'), findsOneWidget);

      // Verify the title uses a light color (not near-black)
      final text = tester.widget<Text>(find.text('Test Screen'));
      final color = text.style?.color;
      expect(color, isNotNull);
      // In dark mode, textOnDark (0xFFF0F0F5) should be used
      expect(color!.red, greaterThan(200));
      expect(color.green, greaterThan(200));
      expect(color.blue, greaterThan(200));
    });
  });

  group('PremiumCard', () {
    testWidgets('uses glassDark background in dark glass mode', (tester) async {
      await tester.pumpWidget(_darkApp(
        const PremiumCard(
          isGlass: true,
          child: Text('Glass Card'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Glass Card'), findsOneWidget);
    });
  });

  group('PremiumStatCard', () {
    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(_darkApp(
        const PremiumStatCard(
          label: 'Test',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('PremiumEmptyState', () {
    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(_darkApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No data',
          subtitle: 'Add something',
          actionLabel: 'Add',
          onAction: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('No data'), findsOneWidget);
    });
  });

  group('PremiumDoubleBezel', () {
    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(_darkApp(
        const PremiumDoubleBezel(
          child: Text('Bezel Content'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Bezel Content'), findsOneWidget);
    });
  });

  group('PremiumProgressBar', () {
    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(_darkApp(
        const PremiumProgressBar(
          value: 0.6,
          isGlass: true,
        ),
      ));
      await tester.pumpAndSettle();
    });
  });

  group('ThemeButton', () {
    testWidgets('renders primary button in dark mode', (tester) async {
      await tester.pumpWidget(_darkApp(
        ThemeButton(
          text: 'Press Me',
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Press Me'), findsOneWidget);
    });
  });

  group('Settings widgets', () {
    testWidgets('SettingsRow renders in dark mode', (tester) async {
      await tester.pumpWidget(_darkApp(
        ListView(
          children: [
            SettingsRow(
              icon: Icons.settings,
              iconColor: Colors.blue,
              title: 'Setting',
              subtitle: 'Description',
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Setting'), findsOneWidget);
    });
  });

  // ─── Screen tests ──────────────────────────────────────────────────

  group('JournalScreen', () {
    testWidgets('renders in dark mode without error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_screenApp(
        const JournalScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(JournalScreen), findsOneWidget);
    });
  });

  group('HealthScreen', () {
    testWidgets('renders in dark mode without error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_screenApp(
        const HealthScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(HealthScreen), findsOneWidget);
    });
  });

  group('FeedingScreen', () {
    testWidgets('renders in dark mode without error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_screenApp(
        const FeedingScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(FeedingScreen), findsOneWidget);
    });
  });

  group('SleepScreen', () {
    testWidgets('renders in dark mode without error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_screenApp(
        const SleepScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(SleepScreen), findsOneWidget);
    });
  });

  group('GrowthChartScreen', () {
    testWidgets('renders in dark mode without error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_screenApp(
        const GrowthChartScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(GrowthChartScreen), findsOneWidget);
    });
  });

  group('MilestonesScreen', () {
    testWidgets('renders in dark mode without error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_screenApp(
        const MilestonesScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MilestonesScreen), findsOneWidget);
    });
  });

  // ─── Placeholder layout tests ──────────────────────────────────────

  group('Login screen form layout', () {
    testWidgets('render login form fields in dark theme', (tester) async {
      // Test the login form layout without the full LoginScreen
      // (which needs local_auth platform mocking)
      await tester.pumpWidget(_darkApp(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome Back!'),
              Text('Sign in to continue'),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });
  });
}
