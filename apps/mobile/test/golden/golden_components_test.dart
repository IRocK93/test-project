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
  // Component goldens — dark glass
  // ---------------------------------------------------------------------------
  group('Component goldens — dark glass', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await matchesGolden(tester, 'dark_glass_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Milestones',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No data yet',
          subtitle: 'Start tracking to see your progress.',
          actionLabel: 'Get Started',
          onAction: () {},
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Component goldens — dark clay
  // ---------------------------------------------------------------------------
  group('Component goldens — dark clay', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await matchesGolden(tester, 'dark_clay_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Feedings',
          value: '128',
          icon: Icons.star,
          iconColor: Colors.orange,
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No records',
          subtitle: 'Add your first entry.',
          actionLabel: 'Add',
          onAction: () {},
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.45, isGlass: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Component goldens — light glass
  // ---------------------------------------------------------------------------
  group('Component goldens — light glass', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await matchesGolden(tester, 'light_glass_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Milestones',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No data yet',
          subtitle: 'Start tracking to see your progress.',
          actionLabel: 'Get Started',
          onAction: () {},
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Component goldens — light clay
  // ---------------------------------------------------------------------------
  group('Component goldens — light clay', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await matchesGolden(tester, 'light_clay_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Feedings',
          value: '128',
          icon: Icons.star,
          iconColor: Colors.orange,
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No records',
          subtitle: 'Add your first entry.',
          actionLabel: 'Add',
          onAction: () {},
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.45, isGlass: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_progress_bar.png');
    });
  });
}
