@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:baby_mon/core/widgets/premium_empty_state.dart';
import 'golden_helpers.dart';

void main() {
  setUpAll(() => setupPlatformMocks());

  group('PremiumEmptyState golden — light glass', () {
    testWidgets('with action', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.mailbox,
          title: 'No data yet',
          subtitle: 'Tap + to add your first entry',
          actionLabel: 'Add entry',
          onAction: noop,
        ),
        brightness: Brightness.light,
      ));
      await matchesGolden(tester, 'premium_empty_state_light_glass_action.png');
    });

    testWidgets('without action', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.compass,
          title: 'Coming Soon',
          subtitle: 'This feature is under development.',
        ),
        brightness: Brightness.light,
      ));
      await matchesGolden(tester, 'premium_empty_state_light_glass_no_action.png');
    });
  });

  group('PremiumEmptyState golden — dark glass', () {
    testWidgets('with action', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.mailbox,
          title: 'No data yet',
          subtitle: 'Tap + to add your first entry',
          actionLabel: 'Add entry',
          onAction: noop,
        ),
        brightness: Brightness.dark,
      ));
      await matchesGolden(tester, 'premium_empty_state_dark_glass_action.png');
    });

    testWidgets('without action', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.compass,
          title: 'Coming Soon',
          subtitle: 'This feature is under development.',
        ),
        brightness: Brightness.dark,
      ));
      await matchesGolden(tester, 'premium_empty_state_dark_glass_no_action.png');
    });
  });

  group('PremiumEmptyState golden — light clay', () {
    testWidgets('with action', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.mailbox,
          title: 'No data yet',
          subtitle: 'Tap + to add your first entry',
          actionLabel: 'Add entry',
          onAction: noop,
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await matchesGolden(tester, 'premium_empty_state_light_clay_action.png');
    });
  });

  group('PremiumEmptyState golden — dark clay', () {
    testWidgets('with action', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.mailbox,
          title: 'No data yet',
          subtitle: 'Tap + to add your first entry',
          actionLabel: 'Add entry',
          onAction: noop,
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await matchesGolden(tester, 'premium_empty_state_dark_clay_action.png');
    });
  });
}

void noop() {}
