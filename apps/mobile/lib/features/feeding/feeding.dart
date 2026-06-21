/// Feeding Feature Barrel
///
/// Import all feeding-related symbols from a single location:
/// ```dart
/// import 'package:baby_mon/features/feeding/feeding.dart';
/// ```
///
/// Instead of importing individual files.
library;

// ── Domain ──
export 'domain/entities/feed_log.dart' show FeedLog;

// ── Presentation: Screens ──
export 'presentation/screens/feeding_screen.dart' show FeedingScreen;
