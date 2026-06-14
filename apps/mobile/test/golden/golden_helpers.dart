import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart' hide AppThemeMode;
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set up mock platform channels needed by screens that use platform plugins.
void setupPlatformMocks() {
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

  // share_plus — used by DashboardScreen and SettingsScreen
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/share_plus'),
    (MethodCall methodCall) async => null,
  );

  // image_picker — used by AlbumScreen
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/image_picker'),
    (MethodCall methodCall) async => null,
  );
}

/// Wrap a widget with all required providers for golden tests.
Widget goldenApp(
  Widget child, {
  required Brightness brightness,
  AppVisualStyle visualStyle = AppVisualStyle.glass,
  List<Override>? extraOverrides,
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
      sharedPreferencesProvider.overrideWith(
          (ref) async => SharedPreferences.getInstance()),
      ...?extraOverrides,
    ],
    child: MaterialApp(
      theme: visualStyle == AppVisualStyle.clay
          ? (isDark ? AppTheme.clayDarkTheme : AppTheme.clayLightTheme)
          : (isDark ? AppTheme.glassDarkTheme : AppTheme.glassLightTheme),
      home: Scaffold(body: child),
    ),
  );
}

/// Pump and compare against a golden file.
Future<void> matchesGolden(
  WidgetTester tester,
  String goldenFile,
) async {
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('goldens/$goldenFile'),
  );
}
