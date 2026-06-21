import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/theme/app_theme.dart';

/// Creates a [ProviderScope] wrapping [child] with overridden providers
/// for testing. Uses the production glass-light theme so that
/// [GlassTokens] and other theme extensions are registered — widgets
/// that depend on `context.glass` will work correctly.
Widget createTestProviderScope({
  List<Override> overrides = const [],
  Brightness brightness = Brightness.light,
  required Widget child,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.resolve(
        visualStyle: 'glass',
        brightness: brightness,
      ),
      home: child,
    ),
  );
}

/// Helper to create a test [MaterialApp] without ProviderScope,
/// using the production glass theme so theme extensions are present.
Widget createTestMaterialApp({
  Brightness brightness = Brightness.light,
  required Widget home,
}) {
  return MaterialApp(
    theme: AppTheme.resolve(
      visualStyle: 'glass',
      brightness: brightness,
    ),
    home: home,
  );
}
