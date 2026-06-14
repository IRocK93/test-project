@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart' hide AppThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'golden_auth_stubs.dart';
import 'golden_splash_stubs.dart';
import 'golden_onboarding_stubs.dart';
import 'golden_helpers.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baby_mon/features/journal/presentation/screens/journal_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/health_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/sleep_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/growth_chart_screen.dart';
import 'package:baby_mon/features/feeding/presentation/screens/feeding_screen.dart';
import 'package:baby_mon/features/milestones/presentation/screens/milestones_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/subscription_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/settings_screen.dart';
import 'package:baby_mon/features/discover/presentation/screens/discover_screen.dart';
import 'package:baby_mon/features/album/presentation/screens/album_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/partners_screen.dart';
import 'package:baby_mon/features/auth/presentation/screens/reset_password_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setupPlatformMocks();

  // ---------------------------------------------------------------------------
  // Screen goldens — dark glass
  // ---------------------------------------------------------------------------
  group('Screen goldens — dark glass', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DashboardScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const JournalScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const HealthScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const FeedingScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SleepScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SettingsScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_settings.png');
    });

    testWidgets('DiscoverScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DiscoverScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_discover.png');
    });

    testWidgets('AlbumScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const AlbumScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_album.png');
    });

    testWidgets('Onboarding Empty', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingEmpty(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_onboarding_empty.png');
    });

    testWidgets('Onboarding Partial', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingPartial(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_onboarding_partial.png');
    });

    testWidgets('Onboarding Complete', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingComplete(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_onboarding_complete.png');
    });

    testWidgets('SplashScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenSplashScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_splash.png');
    });

    testWidgets('PartnersScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PartnersScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_partners.png');
    });

    testWidgets('ResetPasswordScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ResetPasswordScreen(token: 'test-token'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_glass_reset_password.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — dark clay
  // ---------------------------------------------------------------------------
  group('Screen goldens — dark clay', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DashboardScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const JournalScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const HealthScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const FeedingScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SleepScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SettingsScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_settings.png');
    });

    testWidgets('DiscoverScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DiscoverScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_discover.png');
    });

    testWidgets('AlbumScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const AlbumScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_album.png');
    });

    testWidgets('Onboarding Empty', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingEmpty(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_onboarding_empty.png');
    });

    testWidgets('Onboarding Partial', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingPartial(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_onboarding_partial.png');
    });

    testWidgets('Onboarding Complete', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingComplete(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_onboarding_complete.png');
    });

    testWidgets('SplashScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenSplashScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_splash.png');
    });

    testWidgets('PartnersScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PartnersScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_partners.png');
    });

    testWidgets('ResetPasswordScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ResetPasswordScreen(token: 'test-token'),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'dark_clay_reset_password.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — light glass
  // ---------------------------------------------------------------------------
  group('Screen goldens — light glass', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DashboardScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const JournalScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const HealthScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const FeedingScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SleepScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SettingsScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_settings.png');
    });

    testWidgets('DiscoverScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DiscoverScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_discover.png');
    });

    testWidgets('AlbumScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const AlbumScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_album.png');
    });

    testWidgets('Onboarding Empty', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingEmpty(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_onboarding_empty.png');
    });

    testWidgets('Onboarding Partial', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingPartial(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_onboarding_partial.png');
    });

    testWidgets('Onboarding Complete', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingComplete(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_onboarding_complete.png');
    });

    testWidgets('SplashScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenSplashScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_splash.png');
    });

    testWidgets('PartnersScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PartnersScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_partners.png');
    });

    testWidgets('ResetPasswordScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ResetPasswordScreen(token: 'test-token'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_glass_reset_password.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — light clay
  // ---------------------------------------------------------------------------
  group('Screen goldens — light clay', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DashboardScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const JournalScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const HealthScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const FeedingScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SleepScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const SettingsScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_settings.png');
    });

    testWidgets('DiscoverScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const DiscoverScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_discover.png');
    });

    testWidgets('AlbumScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const AlbumScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_album.png');
    });

    testWidgets('Onboarding Empty', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingEmpty(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_onboarding_empty.png');
    });

    testWidgets('Onboarding Partial', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingPartial(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_onboarding_partial.png');
    });

    testWidgets('Onboarding Complete', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenOnboardingComplete(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_onboarding_complete.png');
    });

    testWidgets('SplashScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenSplashScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_splash.png');
    });

    testWidgets('PartnersScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const PartnersScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_partners.png');
    });

    testWidgets('ResetPasswordScreen', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ResetPasswordScreen(token: 'test-token'),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await matchesGolden(tester, 'light_clay_reset_password.png');
    });
  });
}
