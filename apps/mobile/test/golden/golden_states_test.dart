@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart' hide AppThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'golden_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setupPlatformMocks();

  // ---------------------------------------------------------------------------
  // Interactive state goldens — dark glass
  // ---------------------------------------------------------------------------
  group('Interactive states — dark glass', () {
    testWidgets('PremiumCard with onTap', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumCard(
          isGlass: true,
          onTap: () {},
          child: const Text('Tappable Card'),
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_card_tappable.png');
    });

    testWidgets('ThemeButton loading', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: true, fullWidth: true),
        brightness: Brightness.dark,
      ));
      // Use pump() instead of pumpAndSettle() — loading spinner is continuous
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'dark_glass_button_loading.png');
    });

    testWidgets('ThemeButton disabled', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Disabled', isDisabled: true, fullWidth: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_button_disabled.png');
    });

    testWidgets('PremiumProgressBar 30%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.30, isGlass: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_progress_30.png');
    });

    testWidgets('PremiumProgressBar 100%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 1.0, isGlass: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_progress_100.png');
    });

    testWidgets('PremiumStatCard large value', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Total Feeds',
          value: '1,247',
          icon: Icons.local_drink,
          iconColor: Colors.blue,
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_stat_large_value.png');
    });

    testWidgets('PremiumEmptyState long text', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.warning_amber_rounded,
          title: 'No health records yet',
          subtitle:
              'Start tracking your baby\'s health to see milestones, growth charts, and vaccination schedules all in one place.',
          actionLabel: 'Add Health Record',
          onAction: () {},
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_empty_long_text.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Interactive state goldens — dark clay
  // ---------------------------------------------------------------------------
  group('Interactive states — dark clay', () {
    testWidgets('PremiumCard with onTap', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumCard(
          isGlass: true,
          onTap: () {},
          child: const Text('Tappable Card'),
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_card_tappable.png');
    });

    testWidgets('ThemeButton loading', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: true, fullWidth: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'dark_clay_button_loading.png');
    });

    testWidgets('ThemeButton disabled', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Disabled', isDisabled: true, fullWidth: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_button_disabled.png');
    });

    testWidgets('PremiumProgressBar 30%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.30, isGlass: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_progress_30.png');
    });

    testWidgets('PremiumProgressBar 100%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 1.0, isGlass: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_progress_100.png');
    });

    testWidgets('PremiumStatCard large value', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Total Feeds',
          value: '1,247',
          icon: Icons.local_drink,
          iconColor: Colors.blue,
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_stat_large_value.png');
    });

    testWidgets('PremiumEmptyState long text', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.warning_amber_rounded,
          title: 'No health records yet',
          subtitle:
              'Start tracking your baby\'s health to see milestones, growth charts, and vaccination schedules all in one place.',
          actionLabel: 'Add Health Record',
          onAction: () {},
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_empty_long_text.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Interactive state goldens — light glass
  // ---------------------------------------------------------------------------
  group('Interactive states — light glass', () {
    testWidgets('PremiumCard with onTap', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumCard(
          isGlass: true,
          onTap: () {},
          child: const Text('Tappable Card'),
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_card_tappable.png');
    });

    testWidgets('ThemeButton loading', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: true, fullWidth: true),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'light_glass_button_loading.png');
    });

    testWidgets('ThemeButton disabled', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Disabled', isDisabled: true, fullWidth: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_button_disabled.png');
    });

    testWidgets('PremiumProgressBar 30%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.30, isGlass: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_progress_30.png');
    });

    testWidgets('PremiumProgressBar 100%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 1.0, isGlass: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_progress_100.png');
    });

    testWidgets('PremiumStatCard large value', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Total Feeds',
          value: '1,247',
          icon: Icons.local_drink,
          iconColor: Colors.blue,
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_stat_large_value.png');
    });

    testWidgets('PremiumEmptyState long text', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.warning_amber_rounded,
          title: 'No health records yet',
          subtitle:
              'Start tracking your baby\'s health to see milestones, growth charts, and vaccination schedules all in one place.',
          actionLabel: 'Add Health Record',
          onAction: () {},
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_empty_long_text.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Interactive state goldens — light clay
  // ---------------------------------------------------------------------------
  group('Interactive states — light clay', () {
    testWidgets('PremiumCard with onTap', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumCard(
          isGlass: true,
          onTap: () {},
          child: const Text('Tappable Card'),
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_card_tappable.png');
    });

    testWidgets('ThemeButton loading', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: true, fullWidth: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'light_clay_button_loading.png');
    });

    testWidgets('ThemeButton disabled', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Disabled', isDisabled: true, fullWidth: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_button_disabled.png');
    });

    testWidgets('PremiumProgressBar 30%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.30, isGlass: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_progress_30.png');
    });

    testWidgets('PremiumProgressBar 100%', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 1.0, isGlass: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_progress_100.png');
    });

    testWidgets('PremiumStatCard large value', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Total Feeds',
          value: '1,247',
          icon: Icons.local_drink,
          iconColor: Colors.blue,
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_stat_large_value.png');
    });

    testWidgets('PremiumEmptyState long text', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.warning_amber_rounded,
          title: 'No health records yet',
          subtitle:
              'Start tracking your baby\'s health to see milestones, growth charts, and vaccination schedules all in one place.',
          actionLabel: 'Add Health Record',
          onAction: () {},
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_empty_long_text.png');
    });
  });
}
