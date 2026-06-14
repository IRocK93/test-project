import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';

void main() {
  group('AppVisualStyleNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to glass visual style', () async {
      final notifier = AppVisualStyleNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, AppVisualStyle.glass);
      notifier.dispose();
    });

    test('setStyle changes visual style', () async {
      final notifier = AppVisualStyleNotifier();
      await Future<void>.delayed(Duration.zero);

      notifier.setStyle(AppVisualStyle.clay);
      expect(notifier.state, AppVisualStyle.clay);

      notifier.setStyle(AppVisualStyle.glass);
      expect(notifier.state, AppVisualStyle.glass);

      notifier.dispose();
    });

    test('setStyle persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = AppVisualStyleNotifier();
      await Future<void>.delayed(Duration.zero);

      await notifier.setStyle(AppVisualStyle.clay);
      final stored = prefs.getString('app_visual_style');
      expect(stored, 'clay');

      notifier.dispose();
    });

    test('loads persisted visual style on construction', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_visual_style', 'clay');

      final notifier = AppVisualStyleNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, AppVisualStyle.clay);
      notifier.dispose();
    });
  });

  group('AppThemeModeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to system theme mode', () async {
      final notifier = AppThemeModeNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, AppThemeMode.system);
      notifier.dispose();
    });

    test('setMode changes theme mode', () async {
      final notifier = AppThemeModeNotifier();
      await Future<void>.delayed(Duration.zero);

      await notifier.setMode(AppThemeMode.dark);
      expect(notifier.state, AppThemeMode.dark);

      await notifier.setMode(AppThemeMode.light);
      expect(notifier.state, AppThemeMode.light);

      notifier.dispose();
    });

    test('setMode persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = AppThemeModeNotifier();
      await Future<void>.delayed(Duration.zero);

      await notifier.setMode(AppThemeMode.dark);
      final stored = prefs.getString('app_theme_mode');
      expect(stored, 'dark');

      notifier.dispose();
    });

    test('loads persisted theme mode on construction', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme_mode', 'dark');

      final notifier = AppThemeModeNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, AppThemeMode.dark);
      notifier.dispose();
    });
  });
}
