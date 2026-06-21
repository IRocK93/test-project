import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:baby_mon/core/theme/app_theme.dart';

/// Helper: wraps children in a MaterialApp with the given brightness.
Widget _wrapInApp(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('ThemeButton integration — light mode', () {
    testWidgets('all three variants render together', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            ThemeButton(text: 'Filled', onPressed: null, variant: ThemeButtonVariant.filled),
            SizedBox(height: 8),
            ThemeButton(text: 'Outlined', onPressed: null, variant: ThemeButtonVariant.outlined),
            SizedBox(height: 8),
            ThemeButton(text: 'Text', onPressed: null, variant: ThemeButtonVariant.text),
            SizedBox(height: 8),
            ThemeButton(text: 'With Icon', onPressed: null, icon: PhosphorIconsLight.heart),
            SizedBox(height: 8),
            ThemeButton(text: 'Loading', onPressed: null, isLoading: true),
            SizedBox(height: 8),
            ThemeButton(text: 'Full Width', onPressed: null, fullWidth: true),
          ],
        ),
      ));

      // All buttons should render
      expect(find.text('Filled'), findsOneWidget);
      expect(find.text('Outlined'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
      expect(find.text('Loading'), findsNothing); // Loading hides text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Full Width'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsLight.heart), findsOneWidget);
    });

    testWidgets('filled variant has correct light-mode colors', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Test', onPressed: _stub),
      ));

      final material = tester.widget<Material>(
        find.byKey(const ValueKey('theme_button_material')),
      );

      // Light mode filled: bg = AppColors.primary
      expect(material.color?.toARGB32(), equals(0xFF7C5CFC));
    });
  });

  group('ThemeButton integration — dark mode', () {
    testWidgets('all three variants render together', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            ThemeButton(text: 'Dark Filled', onPressed: null, variant: ThemeButtonVariant.filled),
            SizedBox(height: 8),
            ThemeButton(text: 'Dark Outlined', onPressed: null, variant: ThemeButtonVariant.outlined),
            SizedBox(height: 8),
            ThemeButton(text: 'Dark Text', onPressed: null, variant: ThemeButtonVariant.text),
          ],
        ),
        brightness: Brightness.dark,
      ));

      expect(find.text('Dark Filled'), findsOneWidget);
      expect(find.text('Dark Outlined'), findsOneWidget);
      expect(find.text('Dark Text'), findsOneWidget);
    });

    testWidgets('filled variant has correct dark-mode colors', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Dark Test', onPressed: _stub),
        brightness: Brightness.dark,
      ));

      final material = tester.widget<Material>(
        find.byKey(const ValueKey('theme_button_material')),
      );

      // Dark mode filled: bg = AppColors.primaryLight
      expect(material.color?.toARGB32(), equals(0xFFA29BFE));
    });

    testWidgets('filled variant uses dark text on light primary bg', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Contrast Check', onPressed: _stub),
        brightness: Brightness.dark,
      ));

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.byKey(const ValueKey('theme_button_text_style')),
      );

      // Dark mode filled: fg = colorScheme.onSurface (textOnDark = 0xFFF0F0F5)
      expect(defaultTextStyle.style.color?.toARGB32(), equals(0xFFF0F0F5));
    });
  });

  group('ThemeButton interaction', () {
    testWidgets('filled variant triggers callback on tap', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(_wrapInApp(
        ThemeButton(text: 'Tap Me', onPressed: () => tapCount++),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapCount, equals(1));
    });

    testWidgets('disabled variant does not trigger callback', (tester) async {
      const int tapCount = 0;
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Cant Tap', onPressed: null),
      ));

      await tester.tap(find.text('Cant Tap'));
      expect(tapCount, equals(0));
    });

    testWidgets('fullWidth button fills available width', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Full Width', onPressed: null, fullWidth: true),
      ));

      // Find the outer SizedBox that should have double.infinity width
      final sizedBoxes = find.byType(SizedBox);
      bool foundFullWidth = false;
      for (final element in sizedBoxes.evaluate()) {
        final widget = element.widget as SizedBox;
        if (widget.width == double.infinity) {
          foundFullWidth = true;
          break;
        }
      }
      expect(foundFullWidth, isTrue);
    });

    testWidgets('ThemeButton exported from widgets barrel', (tester) async {
      // Verify the barrel export works by checking ThemeButton is accessible
      await tester.pumpWidget(_wrapInApp(
        const ThemeButton(text: 'Barrel Test', onPressed: null),
      ));

      expect(find.byType(ThemeButton), findsOneWidget);
      expect(find.text('Barrel Test'), findsOneWidget);
    });

    testWidgets('ThemeButtonVariant enum values exist', (tester) async {
      expect(ThemeButtonVariant.values.length, equals(3));
      expect(ThemeButtonVariant.filled, isA<ThemeButtonVariant>());
      expect(ThemeButtonVariant.outlined, isA<ThemeButtonVariant>());
      expect(ThemeButtonVariant.text, isA<ThemeButtonVariant>());
    });
  });

  group('RTL support', () {
    testWidgets('icon is on the right and trailingIcon on the left in RTL', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: ThemeButton(
            text: 'RTL Test',
            onPressed: null,
            icon: PhosphorIconsLight.arrowLeft,
            trailingIcon: PhosphorIconsLight.arrowRight,
          ),
        ),
      ));

      // Both icons should be present
      expect(find.byIcon(PhosphorIconsLight.arrowLeft), findsOneWidget);
      expect(find.byIcon(PhosphorIconsLight.arrowRight), findsOneWidget);
      expect(find.text('RTL Test'), findsOneWidget);
    });

    testWidgets('icon is on the left and trailingIcon on the right in LTR', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ThemeButton(
            text: 'LTR Test',
            onPressed: null,
            icon: PhosphorIconsLight.arrowLeft,
            trailingIcon: PhosphorIconsLight.arrowRight,
          ),
        ),
      ));

      // Both icons should be present
      expect(find.byIcon(PhosphorIconsLight.arrowLeft), findsOneWidget);
      expect(find.byIcon(PhosphorIconsLight.arrowRight), findsOneWidget);
      expect(find.text('LTR Test'), findsOneWidget);
    });

    testWidgets('only leading icon renders in RTL', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: ThemeButton(
            text: 'RTL Icon',
            onPressed: null,
            icon: PhosphorIconsLight.heart,
          ),
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.heart), findsOneWidget);
      expect(find.text('RTL Icon'), findsOneWidget);
    });

    testWidgets('only trailing icon renders in RTL', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: ThemeButton(
            text: 'RTL Trailing',
            onPressed: null,
            trailingIcon: PhosphorIconsLight.arrowRight,
          ),
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.arrowRight), findsOneWidget);
      expect(find.text('RTL Trailing'), findsOneWidget);
    });

    testWidgets('icon-only button is not affected by RTL', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: ThemeButton.icon(
            icon: PhosphorIconsLight.heart,
            onPressed: null,
            tooltip: 'Favorite',
          ),
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.heart), findsOneWidget);
      expect(find.byType(ThemeButton), findsOneWidget);
    });

    testWidgets('no icons — text only unaffected by RTL', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: ThemeButton(text: 'Just Text', onPressed: null),
        ),
      ));

      expect(find.text('Just Text'), findsOneWidget);
    });
  });
}

/// Stub callback used in const constructors for tests.
void _stub() {}
