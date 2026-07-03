@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'golden_helpers.dart';
import 'golden_splash_stubs.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setupPlatformMocks();

  // ---------------------------------------------------------------------------
  // RTL Screen goldens — dark glass
  // ---------------------------------------------------------------------------
  group('RTL Screen goldens — dark glass', () {
    testWidgets('GoldenSplashScreen', (tester) async {
      await tester.pumpWidget(goldenRtlApp(
        const GoldenSplashScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'rtl_dark_glass_splash.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(goldenRtlApp(
        const DashboardScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'rtl_dark_glass_dashboard.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(goldenRtlApp(
        const SettingsScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'rtl_dark_glass_settings.png');
    });
  });

  // ---------------------------------------------------------------------------
  // RTL Screen goldens — light glass
  // ---------------------------------------------------------------------------
  group('RTL Screen goldens — light glass', () {
    testWidgets('GoldenSplashScreen', (tester) async {
      await tester.pumpWidget(goldenRtlApp(
        const GoldenSplashScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'rtl_light_glass_splash.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(goldenRtlApp(
        const DashboardScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'rtl_light_glass_dashboard.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(goldenRtlApp(
        const SettingsScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'rtl_light_glass_settings.png');
    });
  });
}
