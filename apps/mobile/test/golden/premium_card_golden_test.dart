@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:baby_mon/core/widgets/premium_card.dart';
import '../golden/golden_helpers.dart';

void main() {
  setUpAll(() => setupPlatformMocks());

  group('PremiumCard golden — light glass', () {
    testWidgets('standard', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Standard card content'),
          ),
        ),
        brightness: Brightness.light,
      ));
      await matchesGolden(tester, 'premium_card_light_glass_standard.png');
    });

    testWidgets('glass', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          isGlass: true,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Glass card content'),
          ),
        ),
        brightness: Brightness.light,
      ));
      await matchesGolden(tester, 'premium_card_light_glass_glass.png');
    });
  });

  group('PremiumCard golden — dark glass', () {
    testWidgets('standard', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Standard card content'),
          ),
        ),
        brightness: Brightness.dark,
      ));
      await matchesGolden(tester, 'premium_card_dark_glass_standard.png');
    });

    testWidgets('glass', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          isGlass: true,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Glass card content'),
          ),
        ),
        brightness: Brightness.dark,
      ));
      await matchesGolden(tester, 'premium_card_dark_glass_glass.png');
    });
  });

  group('PremiumCard golden — light clay', () {
    testWidgets('standard', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Standard card content'),
          ),
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await matchesGolden(tester, 'premium_card_light_clay_standard.png');
    });

    testWidgets('glass', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          isGlass: true,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Glass card content'),
          ),
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await matchesGolden(tester, 'premium_card_light_clay_glass.png');
    });
  });

  group('PremiumCard golden — dark clay', () {
    testWidgets('standard', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Standard card content'),
          ),
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await matchesGolden(tester, 'premium_card_dark_clay_standard.png');
    });

    testWidgets('glass', (WidgetTester tester) async {
      await tester.pumpWidget(goldenApp(
        const PremiumCard(
          isGlass: true,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Glass card content'),
          ),
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await matchesGolden(tester, 'premium_card_dark_clay_glass.png');
    });
  });
}
