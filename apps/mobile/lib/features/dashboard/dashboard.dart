/// Dashboard Feature Barrel
///
/// Import all dashboard-related symbols from a single location:
/// ```dart
/// import 'package:baby_mon/features/dashboard/dashboard.dart';
/// ```
///
/// Instead of importing individual files.
library;

// ── Domain ──
export 'domain/entities/baby_mon.dart' show BabyMon;

// ── Presentation: Screens ──
export 'presentation/screens/dashboard_screen.dart' show DashboardScreen;
