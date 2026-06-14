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
  // Semantics / accessibility tests — verify semantic labels exist
  // ---------------------------------------------------------------------------
  group('Semantics verification', () {
    testWidgets('PremiumStatCard has semantic label', (tester) async {
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

      expect(
        find.bySemanticsLabel(RegExp(r'Milestones')),
        findsOneWidget,
      );
    });

    testWidgets('PremiumProgressBar exposes value', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      // Verify the widget renders without error
      expect(find.byType(PremiumProgressBar), findsOneWidget);
    });

    testWidgets('PremiumEmptyState has semantic labels', (tester) async {
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

      expect(find.text('No data yet'), findsOneWidget);
      expect(find.text('Start tracking to see your progress.'), findsOneWidget);
    });

    testWidgets('ThemeButton renders as button', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', fullWidth: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      // Verify button renders
      expect(find.byType(ThemeButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('ThemeButton disabled renders correctly', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Disabled', isDisabled: true, fullWidth: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      // Verify disabled button renders
      expect(find.byType(ThemeButton), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('PremiumCard with onTap is tappable', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumCard(
          isGlass: true,
          onTap: () {},
          child: const Text('Tappable'),
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tappable'), findsOneWidget);
    });

    testWidgets('PremiumDoubleBezel has semantic label', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bezel Content'), findsOneWidget);
    });

    testWidgets('ScreenHeader exposes title', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Semantics golden tests — dark glass
  // ---------------------------------------------------------------------------
  group('Semantics golden — dark glass', () {
    testWidgets('StatCard semantic tree', (tester) async {
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
      await matchesGolden(tester, 'dark_glass_semantics_stat.png');
    });

    testWidgets('Button semantic tree', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', fullWidth: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_semantics_button.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Semantics golden tests — dark clay
  // ---------------------------------------------------------------------------
  group('Semantics golden — dark clay', () {
    testWidgets('StatCard semantic tree', (tester) async {
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
      await matchesGolden(tester, 'dark_clay_semantics_stat.png');
    });

    testWidgets('Button semantic tree', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', fullWidth: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_semantics_button.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Semantics golden tests — light glass
  // ---------------------------------------------------------------------------
  group('Semantics golden — light glass', () {
    testWidgets('StatCard semantic tree', (tester) async {
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
      await matchesGolden(tester, 'light_glass_semantics_stat.png');
    });

    testWidgets('Button semantic tree', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', fullWidth: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_semantics_button.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Semantics golden tests — light clay
  // ---------------------------------------------------------------------------
  group('Semantics golden — light clay', () {
    testWidgets('StatCard semantic tree', (tester) async {
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
      await matchesGolden(tester, 'light_clay_semantics_stat.png');
    });

    testWidgets('Button semantic tree', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton(text: 'Submit', fullWidth: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_semantics_button.png');
    });
  });
}
