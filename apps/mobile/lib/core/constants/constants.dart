/// Core Constants Barrel
///
/// Import all core constants from a single location:
/// ```dart
/// import 'package:baby_mon/core/constants/constants.dart';
/// ```
///
/// Instead of importing individual files:
/// ```dart
/// import 'package:baby_mon/core/constants/app_colors.dart';
/// import 'package:baby_mon/core/theme/design_tokens.dart';
/// ```
library;

// ── Colors ──
export 'app_colors.dart' show AppColors;

// ── API & Storage ──
export 'api_constants.dart' show ApiConstants, StorageKeys, AppConstants;

// ── Strings ──
export 'app_strings.dart' show AppStrings;

// ── Design System ──
export '../theme/design_tokens.dart' show DesignTokens, QuickThemeAccess;
export '../theme/app_theme.dart' show AppTheme;
