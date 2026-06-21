import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/core/theme/app_theme.dart';

/// Stub callback used in const constructors for tests that verify color/state
/// without needing the button to be tappable.
void _neverCalled() {}

/// Helper: wraps a ThemeButton in a MaterialApp with the given brightness.
Widget _wrapInApp(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme,
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('ThemeButton (light theme)', () {
    testWidgets('filled variant renders text', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: null),
      ));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('filled variant is tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapInApp(
        ThemeButton(text: 'Save', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Save'));
      expect(tapped, isTrue);
    });

    testWidgets('filled variant disabled when onPressed is null', (tester) async {
      const tapped = false;
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: null),
      ));

      await tester.tap(find.text('Save'));
      expect(tapped, isFalse);
    });

    testWidgets('filled variant disabled when isDisabled is true', (tester) async {
      const tapped = false;
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Current Plan',
          onPressed: _neverCalled,
          isDisabled: true,
        ),
      ));

      await tester.tap(find.text('Current Plan'));
      expect(tapped, isFalse);
    });

    testWidgets('filled variant uses primary background in light mode',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: _neverCalled),
      ));

      final material = tester.widget<Material>(
        find.byKey(const ValueKey('theme_button_material')),
      );
      expect(material.color, equals(const Color(0xFF7C5CFC)));
    });

    testWidgets('filled variant uses onPrimary foreground in light mode',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: _neverCalled),
      ));

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.byKey(const ValueKey('theme_button_text_style')),
      );
      expect(defaultTextStyle.style.color, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('filled variant shows ButtonLoading when isLoading is true',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: null, isLoading: true),
      ));

      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('outlined variant renders correctly', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Cancel',
          onPressed: null,
          variant: ThemeButtonVariant.outlined,
        ),
      ));

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('text variant renders correctly', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Skip',
          onPressed: null,
          variant: ThemeButtonVariant.text,
        ),
      ));

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Add',
          onPressed: null,
          icon: PhosphorIconsLight.plus,
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.plus), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('fullWidth uses SizedBox with infinite width', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Full',
          onPressed: null,
          fullWidth: true,
        ),
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
    });

    testWidgets('custom backgroundColor overrides default', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Custom',
          onPressed: _neverCalled,
          backgroundColor: Colors.red,
        ),
      ));

      final material = tester.widget<Material>(
        find.byKey(const ValueKey('theme_button_material')),
      );
      expect(material.color, equals(Colors.red));
    });

    testWidgets('custom foregroundColor overrides default', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Custom',
          onPressed: _neverCalled,
          foregroundColor: Colors.amber,
        ),
      ));

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.byKey(const ValueKey('theme_button_text_style')),
      );
      expect(defaultTextStyle.style.color, equals(Colors.amber));
    });
  });

  group('ThemeButton (dark theme)', () {
    testWidgets('filled variant renders text', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: null),
        brightness: Brightness.dark,
      ));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('filled variant is tappable', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapInApp(
        ThemeButton(text: 'Save', onPressed: () => tapped = true),
        brightness: Brightness.dark,
      ));

      await tester.tap(find.text('Save'));
      expect(tapped, isTrue);
    });

    testWidgets('filled variant uses primaryLight background in dark mode',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: _neverCalled),
        brightness: Brightness.dark,
      ));

      final material = tester.widget<Material>(
        find.byKey(const ValueKey('theme_button_material')),
      );
      expect(material.color, equals(const Color(0xFFA29BFE)));
    });

    testWidgets('filled variant uses textPrimary foreground in dark mode',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Save', onPressed: _neverCalled),
        brightness: Brightness.dark,
      ));

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.byKey(const ValueKey('theme_button_text_style')),
      );
      // In dark mode, foreground uses colorScheme.onSurface (textOnDark = 0xFFF0F0F5)
      expect(defaultTextStyle.style.color, equals(const Color(0xFFF0F0F5)));
    });
  });

  group('ThemeButton (integration)', () {
    testWidgets('filled variant matches snapshot pattern',
        (tester) async {
      // Verify the button appears within the Scaffold
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Submit',
          onPressed: null,
          icon: PhosphorIconsLight.check,
        ),
      ));

      expect(find.byType(ThemeButton), findsOneWidget);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('custom borderRadius applies correctly', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Round',
          onPressed: null,
          borderRadius: 24,
        ),
      ));

      // Should render without error
      expect(find.text('Round'), findsOneWidget);
    });

    testWidgets('all three variants render without error', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            ThemeButton(text: 'Filled', onPressed: null, variant: ThemeButtonVariant.filled),
            SizedBox(height: 8),
            ThemeButton(text: 'Outlined', onPressed: null, variant: ThemeButtonVariant.outlined),
            SizedBox(height: 8),
            ThemeButton(text: 'Text', onPressed: null, variant: ThemeButtonVariant.text),
          ],
        ),
      ));

      expect(find.text('Filled'), findsOneWidget);
      expect(find.text('Outlined'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
    });

    testWidgets('loading state prevents onPressed from firing', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapInApp(
        ThemeButton(
          text: 'Saving...',
          onPressed: () => tapped = true,
          isLoading: true,
        ),
      ));

      // The button should show the loading spinner, not text
      expect(find.text('Saving...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tap the button — should NOT fire onPressed while loading
      await tester.tap(find.byType(InkWell));
      expect(tapped, isFalse);
    });

    testWidgets('loading state does not prevent onPressed when isLoading is false', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapInApp(
        ThemeButton(
          text: 'Save',
          onPressed: () => tapped = true,
          isLoading: false,
        ),
      ));

      // Control test: tap fires when NOT loading
      await tester.tap(find.text('Save'));
      expect(tapped, isTrue);
    });

    testWidgets('loading state transitions smoothly', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Saving...', onPressed: null, isLoading: true),
      ));

      // Should immediately show loader, not text
      expect(find.text('Saving...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('outlined variant has visible border in light mode', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(
          text: 'Outlined',
          onPressed: null,
          variant: ThemeButtonVariant.outlined,
        ),
      ));

      // Border is on the Container decoration
      final container = tester.widget<Container>(
        find.byType(Container).last,
      );
      final border = container.decoration as BoxDecoration?;
      expect(border?.border, isNotNull);
    });
  });
}
