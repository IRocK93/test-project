import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Extension to access localized strings cleanly via `context.l10n.emailLabel`.
///
/// Usage:
/// ```dart
/// import 'package:baby_mon/l10n/l10n_ext.dart';
/// Text(context.l10n.welcomeBack)
/// ```
extension AppLocalizationsExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
