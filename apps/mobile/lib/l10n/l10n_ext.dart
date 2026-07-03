import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_en.dart';

/// Extension to access localized strings cleanly via `context.l10n.emailLabel`.
///
/// Usage:
/// ```dart
/// import 'package:baby_mon/l10n/l10n_ext.dart';
/// Text(context.l10n.welcomeBack)
/// ```
///
/// Gracefully falls back to English when [AppLocalizations] is not available
/// in the widget tree (e.g. before [MaterialApp.router] has been built, during
/// route resolution, or in error recovery paths). This eliminates the null-check
/// crash that would otherwise occur with the `!` operator.
extension AppLocalizationsExt on BuildContext {
  /// Returns the localized strings for the current context.
  ///
  /// Falls back to English if the [AppLocalizations] delegate has not been
  /// loaded yet (returns `AppLocalizationsEn` as a safe default).
  AppLocalizations get l10n => AppLocalizations.of(this) ?? _fallback;
}

/// English fallback used when [AppLocalizations.of] returns null.
/// Cannot be const because AppLocalizationsEn does not have a const constructor.
// ignore: prefer_const_constructors
final _fallback = AppLocalizationsEn();
