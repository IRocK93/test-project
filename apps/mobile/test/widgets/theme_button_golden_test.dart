import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/core/theme/app_theme.dart';

/// Golden (screenshot) tests for ThemeButton.
///
/// These tests render ThemeButton widgets and compare them pixel-by-pixel
/// against stored golden image files. If the rendered output differs from
/// the golden, the test fails — catching visual regressions.
///
/// To update golden files after intentional visual changes:
/// ```sh
/// flutter test --update-goldens test/widgets/theme_button_golden_test.dart
/// ```
///
/// Golden files are stored alongside this test in the `goldens/` directory.
///
/// Note: Google Fonts network requests are disabled in tests (`allowRuntimeFetch = false`),
/// so rendered buttons will use the system fallback font rather than Google Fonts.
/// This is acceptable for catching structural and layout regressions.

/// Helper: wraps a ThemeButton in a MaterialApp for golden rendering.
Widget _wrapInApp(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  // Google Fonts fonts (Syne, PlusJakartaSans) are bundled as test assets,
  // so disable runtime fetching to prevent network requests during tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  // ── Light mode golden tests ──

  testWidgets('golden - filled variant light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(text: 'Save', onPressed: null),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_filled_light.png'),
    );
  });

  testWidgets('golden - outlined variant light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Cancel',
        onPressed: null,
        variant: ThemeButtonVariant.outlined,
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_outlined_light.png'),
    );
  });

  testWidgets('golden - text variant light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Skip',
        onPressed: null,
        variant: ThemeButtonVariant.text,
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_text_light.png'),
    );
  });

  testWidgets('golden - with icon light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Add',
        onPressed: null,
        icon: PhosphorIconsLight.plus,
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_icon_light.png'),
    );
  });

  testWidgets('golden - with trailing icon light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Continue',
        onPressed: null,
        trailingIcon: PhosphorIconsLight.arrowRight,
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_trailing_light.png'),
    );
  });

  // ── Dark mode golden tests ──

  testWidgets('golden - filled variant dark', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(text: 'Save', onPressed: null),
      brightness: Brightness.dark,
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_filled_dark.png'),
    );
  });

  testWidgets('golden - outlined variant dark', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Cancel',
        onPressed: null,
        variant: ThemeButtonVariant.outlined,
      ),
      brightness: Brightness.dark,
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_outlined_dark.png'),
    );
  });

  testWidgets('golden - text variant dark', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Skip',
        onPressed: null,
        variant: ThemeButtonVariant.text,
      ),
      brightness: Brightness.dark,
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_text_dark.png'),
    );
  });

  // ── Disabled state golden tests ──

  testWidgets('golden - disabled filled light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Disabled',
        onPressed: null,
        isDisabled: true,
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_disabled_light.png'),
    );
  });

  testWidgets('golden - full width light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton(
        text: 'Full Width Button',
        onPressed: null,
        fullWidth: true,
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_fullwidth_light.png'),
    );
  });

  // ── Icon-only golden tests ──

  testWidgets('golden - icon-only filled light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton.icon(
        icon: PhosphorIconsLight.heart,
        onPressed: null,
        tooltip: 'Favorite',
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_icon_only_light.png'),
    );
  });

  testWidgets('golden - icon-only outlined light', (tester) async {
    await tester.pumpWidget(_wrapInApp(
      const ThemeButton.icon(
        icon: PhosphorIconsLight.gear,
        onPressed: null,
        variant: ThemeButtonVariant.outlined,
        tooltip: 'Settings',
      ),
    ));
    await expectLater(
      find.byType(ThemeButton),
      matchesGoldenFile('goldens/theme_button_icon_outlined_light.png'),
    );
  });
}
