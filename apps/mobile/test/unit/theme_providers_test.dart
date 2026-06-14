import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppVisualStyleNotifier / appVisualStyleProvider', () {
    test('defaults to glass style', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appVisualStyleProvider), AppVisualStyle.glass);
    });

    test('can switch to clay style', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appVisualStyleProvider.notifier)
          .setStyle(AppVisualStyle.clay);
      expect(container.read(appVisualStyleProvider), AppVisualStyle.clay);
    });

    test('can switch back to glass style', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appVisualStyleProvider.notifier)
          .setStyle(AppVisualStyle.clay);
      await container
          .read(appVisualStyleProvider.notifier)
          .setStyle(AppVisualStyle.glass);
      expect(container.read(appVisualStyleProvider), AppVisualStyle.glass);
    });

    test('setStyle is a no-op when style is same as current', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Default is glass — setting glass again should be a no-op
      final notifier = container.read(appVisualStyleProvider.notifier);
      await notifier.setStyle(AppVisualStyle.glass);
      expect(container.read(appVisualStyleProvider), AppVisualStyle.glass);
    });

    test('persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appVisualStyleProvider.notifier)
          .setStyle(AppVisualStyle.clay);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_visual_style'), 'clay');
    });

    test('loads persisted clay style on init', () async {
      SharedPreferences.setMockInitialValues({'app_visual_style': 'clay'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Poll until async _init() completes SharedPreferences read
      await _waitForState(container, appVisualStyleProvider, AppVisualStyle.clay);
      expect(container.read(appVisualStyleProvider), AppVisualStyle.clay);
    });

    test('migrates from old preference key', () async {
      SharedPreferences.setMockInitialValues({'app_visual_theme': 'clay'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Poll until async _init() completes SharedPreferences read + migration
      await _waitForState(container, appVisualStyleProvider, AppVisualStyle.clay);
      expect(container.read(appVisualStyleProvider), AppVisualStyle.clay);

      // Old key should be removed
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_visual_theme'), isNull);
      // New key should be set
      expect(prefs.getString('app_visual_style'), 'clay');
    });
  });

  group('AppThemeModeNotifier / appThemeModeProvider', () {
    test('defaults to system mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appThemeModeProvider), AppThemeMode.system);
    });

    test('can switch to light mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appThemeModeProvider.notifier)
          .setMode(AppThemeMode.light);
      expect(container.read(appThemeModeProvider), AppThemeMode.light);
    });

    test('can switch to dark mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appThemeModeProvider.notifier)
          .setMode(AppThemeMode.dark);
      expect(container.read(appThemeModeProvider), AppThemeMode.dark);
    });

    test('setMode is a no-op when mode is same as current', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appThemeModeProvider.notifier);
      await notifier.setMode(AppThemeMode.system);
      expect(container.read(appThemeModeProvider), AppThemeMode.system);
    });

    test('persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appThemeModeProvider.notifier)
          .setMode(AppThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    test('loads persisted dark mode on init', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Poll until async _init() completes SharedPreferences read
      await _waitForState(container, appThemeModeProvider, AppThemeMode.dark);
      expect(container.read(appThemeModeProvider), AppThemeMode.dark);
    });

    test('loads persisted light mode on init', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Poll until async _init() completes SharedPreferences read
      await _waitForState(container, appThemeModeProvider, AppThemeMode.light);
      expect(container.read(appThemeModeProvider), AppThemeMode.light);
    });
  });

  group('themePreferencesReadyProvider', () {
    test('returns true after both providers load', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // themePreferencesReadyProvider watches both notifiers and returns true.
      // It evaluates as soon as the notifiers are created (they start with defaults).
      // No async wait needed — the provider itself is synchronous.
      expect(container.read(themePreferencesReadyProvider), true);
    });
  });

  group('appThemeModeLabelProvider', () {
    test('returns "System" for system mode', () {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith((ref) {
            return _FakeThemeModeNotifier(AppThemeMode.system);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appThemeModeLabelProvider), 'System');
    });

    test('returns "Light" for light mode', () {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith((ref) {
            return _FakeThemeModeNotifier(AppThemeMode.light);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appThemeModeLabelProvider), 'Light');
    });

    test('returns "Dark" for dark mode', () {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith((ref) {
            return _FakeThemeModeNotifier(AppThemeMode.dark);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appThemeModeLabelProvider), 'Dark');
    });
  });

  group('themeModeResolverProvider', () {
    test('resolves system to ThemeMode.system', () {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith((ref) {
            return _FakeThemeModeNotifier(AppThemeMode.system);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeResolverProvider), ThemeMode.system);
    });

    test('resolves light to ThemeMode.light', () {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith((ref) {
            return _FakeThemeModeNotifier(AppThemeMode.light);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeResolverProvider), ThemeMode.light);
    });

    test('resolves dark to ThemeMode.dark', () {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith((ref) {
            return _FakeThemeModeNotifier(AppThemeMode.dark);
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeResolverProvider), ThemeMode.dark);
    });
  });

  group('AppVisualStyle enum', () {
    test('has exactly 2 values', () {
      expect(AppVisualStyle.values.length, 2);
      expect(AppVisualStyle.values, contains(AppVisualStyle.glass));
      expect(AppVisualStyle.values, contains(AppVisualStyle.clay));
    });
  });

  group('AppThemeMode enum', () {
    test('has exactly 3 values', () {
      expect(AppThemeMode.values.length, 3);
      expect(AppThemeMode.values, contains(AppThemeMode.system));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
    });
  });
}

/// Minimal fake AppThemeModeNotifier for provider overrides in tests.
/// Sets state immediately in constructor body, bypassing async _init().
/// The parent's _init() fires async but is harmless — the derived-provider
/// tests read synchronously before it completes.
class _FakeThemeModeNotifier extends AppThemeModeNotifier {
  _FakeThemeModeNotifier(AppThemeMode initial) : super() {
    state = initial;
  }
}

/// Polls a provider until it reaches the expected value or times out.
Future<void> _waitForState<T>(
  ProviderContainer container,
  ProviderBase<T> provider,
  T expected, {
  int maxRetries = 100,
  Duration interval = const Duration(milliseconds: 10),
}) async {
  for (var i = 0; i < maxRetries; i++) {
    if (container.read(provider) == expected) return;
    await Future<void>.delayed(interval);
  }
  throw TimeoutException(
    'Provider did not reach expected state ($expected) within ${maxRetries * interval.inMilliseconds}ms',
  );
}
