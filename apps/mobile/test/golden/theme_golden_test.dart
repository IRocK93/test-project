import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'auth_form_goldens.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baby_mon/features/journal/presentation/screens/journal_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/health_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/sleep_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/growth_chart_screen.dart';
import 'package:baby_mon/features/feeding/presentation/screens/feeding_screen.dart';
import 'package:baby_mon/features/milestones/presentation/screens/milestones_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/subscription_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set up mock platform channels needed by screens that use platform plugins.
void _setupPlatformMocks() {
  // local_auth — used by LoginScreen in initState (_checkBiometrics)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/local_auth'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'canCheckBiometrics':
          return false;
        case 'isDeviceSupported':
          return false;
        case 'authenticate':
          return false;
        case 'getAvailableBiometrics':
          return <dynamic>[];
        default:
          return null;
      }
    },
  );

  // share_plus — imported by DashboardScreen (only used in callbacks, but mock
  // to prevent MissingPluginException if any path touches it during build).
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/share_plus'),
    (MethodCall methodCall) async => null,
  );
}

/// Helper to wrap a widget with all required providers for golden tests.
Widget _goldenApp(Widget child, {
  required Brightness brightness,
  AppVisualStyle visualStyle = AppVisualStyle.glass,
}) {
  final isDark = brightness == Brightness.dark;
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
          ? (isDark ? AppTheme.clayDarkTheme : AppTheme.clayLightTheme)
          : (isDark ? AppTheme.glassDarkTheme : AppTheme.glassLightTheme),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  _setupPlatformMocks();

  // ---------------------------------------------------------------------------
  // Component goldens — dark glass
  // ---------------------------------------------------------------------------
  group('Component goldens — dark glass', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await _testerMatchesGoldenFile(tester, 'dark_glass_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_glass_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_glass_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumStatCard(
          label: 'Milestones',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_glass_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(_goldenApp(
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
      await _testerMatchesGoldenFile(tester, 'dark_glass_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_glass_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_glass_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Component goldens — dark clay
  // ---------------------------------------------------------------------------
  group('Component goldens — dark clay', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await _testerMatchesGoldenFile(tester, 'dark_clay_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_clay_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_clay_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
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
      await _testerMatchesGoldenFile(tester, 'dark_clay_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(_goldenApp(
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
      await _testerMatchesGoldenFile(tester, 'dark_clay_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_clay_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumProgressBar(value: 0.45, isGlass: true),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'dark_clay_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Component goldens — light glass
  // ---------------------------------------------------------------------------
  group('Component goldens — light glass', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await _testerMatchesGoldenFile(tester, 'light_glass_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_glass_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_glass_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumStatCard(
          label: 'Milestones',
          value: '42',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_glass_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(_goldenApp(
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
      await _testerMatchesGoldenFile(tester, 'light_glass_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_glass_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumProgressBar(value: 0.65, isGlass: true),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_glass_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Component goldens — light clay
  // ---------------------------------------------------------------------------
  group('Component goldens — light clay', () {
    testWidgets('PremiumBackground', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumBackground(child: Center(child: Text('Content'))),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await _testerMatchesGoldenFile(tester, 'light_clay_background.png');
    });

    testWidgets('ScreenHeader', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const ScreenHeader(title: 'Dashboard'),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_clay_header.png');
    });

    testWidgets('PremiumCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumCard(isGlass: true, child: Text('Card Content')),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_clay_card.png');
    });

    testWidgets('PremiumStatCard', (tester) async {
      await tester.pumpWidget(_goldenApp(
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
      await _testerMatchesGoldenFile(tester, 'light_clay_stat_card.png');
    });

    testWidgets('PremiumEmptyState', (tester) async {
      await tester.pumpWidget(_goldenApp(
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
      await _testerMatchesGoldenFile(tester, 'light_clay_empty_state.png');
    });

    testWidgets('PremiumDoubleBezel', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumDoubleBezel(child: Text('Bezel Content')),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_clay_double_bezel.png');
    });

    testWidgets('PremiumProgressBar', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const PremiumProgressBar(value: 0.45, isGlass: true),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await _testerMatchesGoldenFile(tester, 'light_clay_progress_bar.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — dark glass
  // ---------------------------------------------------------------------------
  group('Screen goldens — dark glass', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const DashboardScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const JournalScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const HealthScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const FeedingScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SleepScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SettingsScreen(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_glass_settings.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — dark clay
  // ---------------------------------------------------------------------------
  group('Screen goldens — dark clay', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const DashboardScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const JournalScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const HealthScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const FeedingScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SleepScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SettingsScreen(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'dark_clay_settings.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — light glass
  // ---------------------------------------------------------------------------
  group('Screen goldens — light glass', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const DashboardScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const JournalScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const HealthScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const FeedingScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SleepScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SettingsScreen(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_glass_settings.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Screen goldens — light clay
  // ---------------------------------------------------------------------------
  group('Screen goldens — light clay', () {
    testWidgets('LoginForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenLoginForm(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_login.png');
    });

    testWidgets('RegisterForm', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GoldenRegisterForm(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_register.png');
    });

    testWidgets('DashboardScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const DashboardScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_dashboard.png');
    });

    testWidgets('JournalScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const JournalScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_journal.png');
    });

    testWidgets('HealthScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const HealthScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_health.png');
    });

    testWidgets('FeedingScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const FeedingScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_feeding.png');
    });

    testWidgets('SleepScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SleepScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_sleep.png');
    });

    testWidgets('GrowthChartScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const GrowthChartScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_growth.png');
    });

    testWidgets('MilestonesScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const MilestonesScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_milestones.png');
    });

    testWidgets('SubscriptionScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SubscriptionScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_subscription.png');
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(_goldenApp(
        const SettingsScreen(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await _testerMatchesGoldenFile(tester, 'light_clay_settings.png');
    });
  });
}

/// Utility: pump and compare against a golden file.
/// When `--update-goldens` is passed, creates/updates the reference images.
Future<void> _testerMatchesGoldenFile(
  WidgetTester tester,
  String goldenFile,
) async {
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('goldens/$goldenFile'),
  );
}
