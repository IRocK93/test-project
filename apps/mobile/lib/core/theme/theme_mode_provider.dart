import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available visual styles.
enum AppVisualStyle {
  /// Dark glassmorphism (default)
  glass,

  /// Lighter claymorphism with warm earthy tones
  clay;
}

/// Available theme mode (light/dark/system).
enum AppThemeMode {
  /// Follow OS setting
  system,

  /// Force light mode
  light,

  /// Force dark mode
  dark;
}

// ── Preference keys ──

const _stylePrefKey = 'app_visual_style';
const _oldStylePrefKey = 'app_visual_theme'; // V1 key — migration target
const _modePrefKey = 'app_theme_mode';

// ── Persistence helpers ──

Future<AppVisualStyle> _loadStylePref() async {
  final prefs = await SharedPreferences.getInstance();

  // Migration: if old key exists, move to new key and delete old
  final oldValue = prefs.getString(_oldStylePrefKey);
  if (oldValue != null) {
    final style = oldValue == 'clay' ? AppVisualStyle.clay : AppVisualStyle.glass;
    await prefs.setString(_stylePrefKey, oldValue == 'clay' ? 'clay' : 'glass');
    await prefs.remove(_oldStylePrefKey);
    return style;
  }

  // Normal read from new key
  final stored = prefs.getString(_stylePrefKey);
  if (stored == 'clay') return AppVisualStyle.clay;
  return AppVisualStyle.glass;
}

Future<void> _saveStylePref(AppVisualStyle style) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_stylePrefKey, style == AppVisualStyle.clay ? 'clay' : 'glass');
}

Future<AppThemeMode> _loadModePref() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_modePrefKey);
  if (stored == 'light') return AppThemeMode.light;
  if (stored == 'dark') return AppThemeMode.dark;
  return AppThemeMode.system;
}

Future<void> _saveModePref(AppThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_modePrefKey, mode.name);
}

// ── Providers ──

/// Manages the persisted visual style preference (glass or clay).
class AppVisualStyleNotifier extends StateNotifier<AppVisualStyle> {
  AppVisualStyleNotifier() : super(AppVisualStyle.glass) {
    _init();
  }

  Future<void> _init() async {
    state = await _loadStylePref();
  }

  Future<void> setStyle(AppVisualStyle style) async {
    if (state == style) return;
    state = style;
    await _saveStylePref(style);
  }
}

final appVisualStyleProvider =
    StateNotifierProvider<AppVisualStyleNotifier, AppVisualStyle>(
  (ref) => AppVisualStyleNotifier(),
);

/// Manages the persisted theme mode preference (system, light, dark).
class AppThemeModeNotifier extends StateNotifier<AppThemeMode> {
  AppThemeModeNotifier() : super(AppThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    state = await _loadModePref();
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await _saveModePref(mode);
  }
}

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeNotifier, AppThemeMode>(
  (ref) => AppThemeModeNotifier(),
);

// ── Init-flash prevention ──
// Both notifiers start with defaults and async-load saved prefs.
// The splash screen delays auth check by 3 seconds (see splash_screen.dart),
// which gives both providers ample time to load. By the time any screen
// renders, the correct style and mode are already resolved. No flash.

/// Indicates whether both theme preferences have been loaded from storage.
/// Screens should defer rendering until this is true to avoid flash.
final themePreferencesReadyProvider = Provider<bool>((ref) {
  // Watch both providers so we rebuild when preferences load from storage.
  ref.watch(appVisualStyleProvider);
  ref.watch(appThemeModeProvider);
  return true;
});

/// Convenience labels for the theme mode toggle.
final appThemeModeLabelProvider = Provider<String>((ref) {
  switch (ref.watch(appThemeModeProvider)) {
    case AppThemeMode.light:
      return 'Light';
    case AppThemeMode.dark:
      return 'Dark';
    case AppThemeMode.system:
      return 'System';
  }
});

/// Resolves [AppThemeMode] to Flutter's [ThemeMode].
final themeModeResolverProvider = Provider<ThemeMode>((ref) {
  switch (ref.watch(appThemeModeProvider)) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});