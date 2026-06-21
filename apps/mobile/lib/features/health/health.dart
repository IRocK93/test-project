/// Health Feature Barrel
///
/// Import all health-related symbols from a single location:
/// ```dart
/// import 'package:baby_mon/features/health/health.dart';
/// ```
///
/// Instead of importing individual files.
library;

// ── Domain ──
export 'domain/entities/health_record.dart' show HealthRecord;
export 'domain/entities/sleep_log.dart' show SleepLog;
export 'domain/entities/growth_record.dart' show GrowthRecord;
export 'domain/entities/allergy.dart' show Allergy, AllergyEvent;

// ── Presentation: Screens ──
export 'presentation/screens/health_screen.dart' show HealthScreen;
export 'presentation/screens/growth_chart_screen.dart' show GrowthChartScreen;
export 'presentation/screens/sleep_screen.dart' show SleepScreen;
