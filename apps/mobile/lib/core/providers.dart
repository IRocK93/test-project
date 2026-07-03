import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/api_client.dart';
/// Cross-tab action signals sent from the main FAB to individual tab screens.
enum AddAction { feeding, milestone, healthMeasurement, healthEvent, healthMedicalTeam }
/// Global API Client provider — the SINGLE source of truth for ApiClient across the app.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
/// Refresh counter — bump this to force all tab screens to reload their data.
/// Incremented after BabyMon creation, deletion, or any state-changing operation.
final appRefreshProvider = StateProvider<int>((ref) => 0);
/// Per-tab refresh signal. Each tab index gets its own counter so navigating
/// back to a tab triggers a reload without refreshing unrelated tabs.
final tabRefreshProvider = StateProvider.family<int, int>((ref, index) => 0);
/// One-shot action signal from the dashboard FAB. The target tab screen reads
/// and immediately clears it to open the appropriate dialog.
final pendingAddActionProvider = StateProvider<AddAction?>((ref) => null);
/// Shared preferences instance — initialized once per app session.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});
/// Currently selected BabyMon ID — updated when the user switches profiles.
final selectedBabyMonIdProvider = StateProvider<String?>((ref) => null);

// ── Locale / RTL support ──

const _localePrefKey = 'user_locale';
const _supportedLocales = {'en', 'es', 'fr', 'pt', 'de', 'ar', 'he', 'zh', 'it'};

/// Loads the persisted locale code from SharedPreferences.
Future<String> _loadLocalePref() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_localePrefKey);
  if (stored != null && _supportedLocales.contains(stored)) return stored;
  return 'en';
}

/// Saves the locale code to SharedPreferences.
Future<void> _saveLocalePref(String locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_localePrefKey, locale);
}

/// Manages the app's active locale. Persists to SharedPreferences and
/// triggers app-wide rebuilds so Flutter applies the correct text direction
/// (LTR or RTL) automatically.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _init();
  }

  Future<void> _init() async {
    final code = await _loadLocalePref();
    state = Locale(code);
  }

  /// Updates the locale and persists it locally.
  /// Callers should also sync to the backend separately if authenticated.
  Future<void> setLocale(String localeCode) async {
    if (!_supportedLocales.contains(localeCode)) return;
    if (state.languageCode == localeCode) return;
    state = Locale(localeCode);
    await _saveLocalePref(localeCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
