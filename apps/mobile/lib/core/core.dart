/// Core Barrel
///
/// Import all core modules from a single location:
/// ```dart
/// import 'package:baby_mon/core/core.dart';
/// ```
///
/// Instead of importing individual barrels:
/// ```dart
/// import 'package:baby_mon/core/constants/constants.dart';
/// import 'package:baby_mon/core/utils/utils.dart';
/// import 'package:baby_mon/core/widgets/widgets.dart';
/// ```
library;

export 'constants/constants.dart';
export 'theme/app_theme.dart' show AppTheme;
export 'theme/design_tokens.dart' show DesignTokens;
export 'utils/navigation_utils.dart' show popOrGoHome;
export 'utils/utils.dart';
export 'widgets/widgets.dart';
