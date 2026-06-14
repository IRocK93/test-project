@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart' hide AppThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'golden_helpers.dart';

/// Render time threshold for test environments (ms).
/// CI machines lack GPU acceleration, so thresholds are generous.
const int _maxRenderMs = 500;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setupPlatformMocks();

  // ---------------------------------------------------------------------------
  // Performance benchmarks — measure widget build and paint times
  // ---------------------------------------------------------------------------
  group('Render performance — dark glass', () {
    testWidgets('PremiumCard render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_glass_perf_card.png');
    });

    testWidgets('PremiumStatCard render time', (tester) async {
      final sw = Stopwatch()..start();
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
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_glass_perf_stat.png');
    });

    testWidgets('PremiumEmptyState render time', (tester) async {
      final sw = Stopwatch()..start();
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
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_glass_perf_empty.png');
    });

    testWidgets('PremiumProgressBar render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_glass_perf_progress.png');
    });

    testWidgets('ThemeButton render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: false, fullWidth: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_glass_perf_button.png');
    });
  });

  group('Render performance — dark clay', () {
    testWidgets('PremiumCard render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_clay_perf_card.png');
    });

    testWidgets('PremiumStatCard render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Milestones',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_clay_perf_stat.png');
    });

    testWidgets('PremiumEmptyState render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No data yet',
          subtitle: 'Start tracking to see your progress.',
          actionLabel: 'Get Started',
          onAction: () {},
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_clay_perf_empty.png');
    });

    testWidgets('PremiumProgressBar render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_clay_perf_progress.png');
    });

    testWidgets('ThemeButton render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: false, fullWidth: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'dark_clay_perf_button.png');
    });
  });

  group('Render performance — light glass', () {
    testWidgets('PremiumCard render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_glass_perf_card.png');
    });

    testWidgets('PremiumStatCard render time', (tester) async {
      final sw = Stopwatch()..start();
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
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_glass_perf_stat.png');
    });

    testWidgets('PremiumEmptyState render time', (tester) async {
      final sw = Stopwatch()..start();
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
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_glass_perf_empty.png');
    });

    testWidgets('PremiumProgressBar render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_glass_perf_progress.png');
    });

    testWidgets('ThemeButton render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: false, fullWidth: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_glass_perf_button.png');
    });
  });

  group('Render performance — light clay', () {
    testWidgets('PremiumCard render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_clay_perf_card.png');
    });

    testWidgets('PremiumStatCard render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumStatCard(
          label: 'Milestones',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_clay_perf_stat.png');
    });

    testWidgets('PremiumEmptyState render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.child_care,
          title: 'No data yet',
          subtitle: 'Start tracking to see your progress.',
          actionLabel: 'Get Started',
          onAction: () {},
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_clay_perf_empty.png');
    });

    testWidgets('PremiumProgressBar render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_clay_perf_progress.png');
    });

    testWidgets('ThemeButton render time', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', isLoading: false, fullWidth: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(_maxRenderMs));
      await matchesGolden(tester, 'light_clay_perf_button.png');
    });
  });
}
