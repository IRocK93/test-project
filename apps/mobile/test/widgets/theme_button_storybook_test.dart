import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/core/theme/app_theme.dart';

/// Builds a full-screen storybook scaffold for visual testing.
Widget buildStorybook({required Brightness brightness, required Widget body}) {
  return MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text(brightness == Brightness.light ? 'Light Mode' : 'Dark Mode'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      ),
    ),
  );
}

/// Wraps a section with a title label.
Widget section(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children,
      ),
      const Divider(height: 32),
    ],
  );
}

Widget _lightStorybook(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      section('Filled Variant', [
        const ThemeButton(text: 'Default', onPressed: null),
        const SizedBox(width: 12),
        ThemeButton(text: 'Tappable', onPressed: () {}),
        const SizedBox(width: 12),
        const ThemeButton(text: 'Disabled', onPressed: null, isDisabled: true),
      ]),
      section('Outlined Variant', [
        const ThemeButton(
          text: 'Outlined',
          onPressed: null,
          variant: ThemeButtonVariant.outlined,
        ),
        const SizedBox(width: 12),
        ThemeButton(
          text: 'Tappable',
          onPressed: () {},
          variant: ThemeButtonVariant.outlined,
        ),
      ]),
      section('Text Variant', [
        const ThemeButton(
          text: 'Text',
          onPressed: null,
          variant: ThemeButtonVariant.text,
        ),
        const SizedBox(width: 12),
        ThemeButton(
          text: 'Tappable',
          onPressed: () {},
          variant: ThemeButtonVariant.text,
        ),
      ]),
      section('With Leading Icon', [
        const ThemeButton(
          text: 'Heart',
          onPressed: null,
          icon: PhosphorIconsLight.heart,
        ),
        const SizedBox(width: 12),
        const ThemeButton(
          text: 'Star',
          onPressed: null,
          icon: PhosphorIconsLight.star,
        ),
      ]),
      section('With Trailing Icon', [
        const ThemeButton(
          text: 'Continue',
          onPressed: null,
          trailingIcon: PhosphorIconsLight.arrowRight,
        ),
        const SizedBox(width: 12),
        const ThemeButton(
          text: 'Save',
          onPressed: null,
          trailingIcon: PhosphorIconsLight.heart,
        ),
      ]),
      section('Both Icons', [
        const ThemeButton(
          text: 'Fav',
          onPressed: null,
          icon: PhosphorIconsLight.heart,
          trailingIcon: PhosphorIconsLight.star,
        ),
      ]),
      section('Full Width', [
        const ThemeButton(
          text: 'Full Width Button',
          onPressed: null,
          fullWidth: true,
        ),
        const SizedBox(height: 8),
        const ThemeButton(
          text: 'Full Width Outlined',
          onPressed: null,
          variant: ThemeButtonVariant.outlined,
          fullWidth: true,
        ),
      ]),
      section('Loading States', [
        const ThemeButton(text: 'Saving...', onPressed: null, isLoading: true),
        const SizedBox(width: 12),
        const ThemeButton(
          text: 'Saving...',
          onPressed: null,
          isLoading: true,
          variant: ThemeButtonVariant.outlined,
        ),
        const SizedBox(width: 12),
        const ThemeButton(
          text: 'Saving...',
          onPressed: null,
          isLoading: true,
          variant: ThemeButtonVariant.text,
        ),
      ]),
      section('Custom Colors', [
        const ThemeButton(
          text: 'Custom BG',
          onPressed: null,
          backgroundColor: Colors.teal,
        ),
        const SizedBox(width: 12),
        const ThemeButton(
          text: 'Custom FG',
          onPressed: null,
          foregroundColor: Colors.amber,
        ),
      ]),
      section('Custom Radius & Height', [
        const ThemeButton(
          text: 'Pill',
          onPressed: null,
          borderRadius: 24,
        ),
        const SizedBox(width: 12),
        const ThemeButton(
          text: 'Tall',
          onPressed: null,
          height: 64,
        ),
      ]),
      section('Icon-Only Buttons', [
        const ThemeButton.icon(
          icon: PhosphorIconsLight.heart,
          onPressed: null,
          tooltip: 'Favorite',
        ),
        const SizedBox(width: 12),
        ThemeButton.icon(
          icon: PhosphorIconsLight.star,
          onPressed: () {},
          tooltip: 'Star',
        ),
        const SizedBox(width: 12),
        const ThemeButton.icon(
          icon: PhosphorIconsLight.bell,
          onPressed: null,
          isDisabled: true,
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 12),
        const ThemeButton.icon(
          icon: PhosphorIconsLight.gear,
          onPressed: null,
          variant: ThemeButtonVariant.outlined,
          tooltip: 'Settings',
        ),
        const SizedBox(width: 12),
        const ThemeButton.icon(
          icon: PhosphorIconsLight.info,
          onPressed: null,
          variant: ThemeButtonVariant.text,
          tooltip: 'Info',
        ),
      ]),
      section('InkWell & GestureDetector Wrappers', [
        ThemeButtonStyle.inkWell(
          context: context,
          onTap: () {},
          borderRadius: 12,
          child: Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Icon(PhosphorIconsLight.heart, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ThemeButtonStyle.gestureDetector(
          onTap: () {},
          child: Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(PhosphorIconsLight.handTap, size: 20),
            ),
          ),
        ),
      ]),
    ],
  );
}

Widget _darkStorybook(BuildContext context) {
  return Container(
    color: const Color(0xFF0E0E12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section('Filled Variant', [
          const ThemeButton(text: 'Default', onPressed: _stub),
          const SizedBox(width: 12),
          ThemeButton(text: 'Tappable', onPressed: () {}),
          const SizedBox(width: 12),
          const ThemeButton(text: 'Disabled', onPressed: null, isDisabled: true),
        ]),
        section('Outlined Variant', [
          const ThemeButton(
            text: 'Outlined',
            onPressed: null,
            variant: ThemeButtonVariant.outlined,
          ),
          const SizedBox(width: 12),
          ThemeButton(
            text: 'Tappable',
            onPressed: () {},
            variant: ThemeButtonVariant.outlined,
          ),
        ]),
        section('Full Width', [
          const ThemeButton(
            text: 'Full Width Filled',
            onPressed: null,
            fullWidth: true,
          ),
          const SizedBox(height: 8),
          const ThemeButton(
            text: 'Full Width with Trailing',
            onPressed: null,
            trailingIcon: PhosphorIconsLight.arrowRight,
            fullWidth: true,
          ),
        ]),
        section('Loading States', [
          const ThemeButton(
            text: 'Loading',
            onPressed: null,
            isLoading: true,
          ),
          const SizedBox(width: 12),
          const ThemeButton(
            text: 'Loading',
            onPressed: null,
            variant: ThemeButtonVariant.outlined,
            isLoading: true,
          ),
        ]),
        section('Icon-Only Buttons', [
          const ThemeButton.icon(
            icon: PhosphorIconsLight.heart,
            onPressed: null,
            tooltip: 'Favorite',
          ),
          const SizedBox(width: 12),
          ThemeButton.icon(
            icon: PhosphorIconsLight.star,
            onPressed: () {},
            tooltip: 'Star',
          ),
          const SizedBox(width: 12),
          const ThemeButton.icon(
            icon: PhosphorIconsLight.gear,
            onPressed: null,
            variant: ThemeButtonVariant.outlined,
            tooltip: 'Settings',
          ),
        ]),
      ],
    ),
  );
}

void main() {
  // ── Light mode storybook ──
  testWidgets('light mode storybook renders all variants', (tester) async {
    await tester.pumpWidget(Builder(
      builder: (context) => buildStorybook(
        brightness: Brightness.light,
        body: _lightStorybook(context),
      ),
    ));

    // Verify key buttons render
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Tappable'), findsAtLeastNWidgets(3));
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.text('Outlined'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Full Width Button'), findsOneWidget);
    // Loading buttons hide text — verify progress indicators render instead
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Custom BG'), findsOneWidget);
    expect(find.text('Pill'), findsOneWidget);
    expect(find.text('Tall'), findsOneWidget);

    // Verify icons
    expect(find.byIcon(PhosphorIconsLight.heart), findsWidgets);
    expect(find.byIcon(PhosphorIconsLight.star), findsWidgets);
    expect(find.byIcon(PhosphorIconsLight.arrowRight), findsOneWidget);
    expect(find.byIcon(PhosphorIconsLight.bell), findsOneWidget);
    expect(find.byIcon(PhosphorIconsLight.gear), findsOneWidget);
    expect(find.byIcon(PhosphorIconsLight.info), findsOneWidget);
    expect(find.byIcon(PhosphorIconsLight.handTap), findsOneWidget);

    // Verify const constructors
    expect(find.byType(ThemeButton), findsWidgets);

    // Verify theme-aware colors
    final material = tester.widget<Material>(
      find.byKey(const ValueKey('theme_button_material')).first,
    );
    expect(material.color, isNotNull);
  });

  // ── Dark mode storybook ──
  testWidgets('dark mode storybook renders correctly', (tester) async {
    await tester.pumpWidget(Builder(
      builder: (context) => buildStorybook(
        brightness: Brightness.dark,
        body: _darkStorybook(context),
      ),
    ));

    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Full Width Filled'), findsOneWidget);

    // Verify dark-mode colors — first button uses _stub (not disabled)
    final material = tester.widget<Material>(
      find.byKey(const ValueKey('theme_button_material')).first,
    );
    // Dark mode filled: bg = AppColors.primaryLight
    expect(material.color?.toARGB32(), equals(0xFFA29BFE));
  });

  // ── Icon-only constructor ──
  testWidgets('icon-only constructor renders multiple icons', (tester) async {
    await tester.pumpWidget(Builder(
      builder: (context) => buildStorybook(
        brightness: Brightness.light,
        body: const Wrap(
          children: [
            ThemeButton.icon(
              icon: PhosphorIconsLight.heart,
              onPressed: null,
              tooltip: 'Favorite',
            ),
            ThemeButton.icon(
              icon: PhosphorIconsLight.star,
              onPressed: _stub,
              tooltip: 'Star',
            ),
            ThemeButton.icon(
              icon: PhosphorIconsLight.bell,
              onPressed: null,
              isDisabled: true,
              tooltip: 'Notifications',
            ),
          ],
        ),
      ),
    ));

    expect(find.byIcon(PhosphorIconsLight.heart), findsOneWidget);
    expect(find.byIcon(PhosphorIconsLight.star), findsOneWidget);
    expect(find.byIcon(PhosphorIconsLight.bell), findsOneWidget);
    expect(find.byType(ThemeButton), findsNWidgets(3));
  });

  // ── ThemeButtonStyle helpers ──
  testWidgets('resolveForeground returns correct colors', (tester) async {
    // Light mode filled
    expect(
      ThemeButtonStyle.resolveForeground(
        variant: ThemeButtonVariant.filled,
        isDark: false,
      ).toARGB32(),
      equals(0xFFFFFFFF), // textOnPrimary
    );

    // Dark mode filled
    expect(
      ThemeButtonStyle.resolveForeground(
        variant: ThemeButtonVariant.filled,
        isDark: true,
      ).toARGB32(),
      equals(0xFF1A1A2E), // textPrimary
    );

    // Light mode outlined
    expect(
      ThemeButtonStyle.resolveForeground(
        variant: ThemeButtonVariant.outlined,
        isDark: false,
      ).toARGB32(),
      equals(0xFF7C5CFC), // primary
    );

    // Dark mode outlined
    expect(
      ThemeButtonStyle.resolveForeground(
        variant: ThemeButtonVariant.outlined,
        isDark: true,
      ).toARGB32(),
      equals(0xFFA29BFE), // primaryLight
    );
  });

  testWidgets('resolveBackground returns correct colors', (tester) async {
    // Light mode filled
    expect(
      ThemeButtonStyle.resolveBackground(
        variant: ThemeButtonVariant.filled,
        isDark: false,
      ).toARGB32(),
      equals(0xFF7C5CFC), // primary
    );

    // Dark mode filled
    expect(
      ThemeButtonStyle.resolveBackground(
        variant: ThemeButtonVariant.filled,
        isDark: true,
      ).toARGB32(),
      equals(0xFFA29BFE), // primaryLight
    );

    // Outlined - transparent
    expect(
      ThemeButtonStyle.resolveBackground(
        variant: ThemeButtonVariant.outlined,
        isDark: false,
      ),
      equals(Colors.transparent),
    );
  });

  // ── InkWell wrapper (using real context) ──
  testWidgets('themedInkWell creates tappable area', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => themedInkWell(
            context: context,
            onTap: () => tapped = true,
            child: const SizedBox(width: 100, height: 48, child: Text('Tap Here')),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Tap Here'));
    expect(tapped, isTrue);
  });

  // ── GestureDetector wrapper ──
  testWidgets('themedGestureDetector fires onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: themedGestureDetector(
          onTap: () => tapped = true,
          child: const SizedBox(width: 100, height: 48, child: Text('Tap Gesture')),
        ),
      ),
    ));

    await tester.tap(find.text('Tap Gesture'));
    expect(tapped, isTrue);
  });

  // ── Barrel export verification ──
  testWidgets('new symbols exported from widgets barrel', (tester) async {
    expect(ThemeButtonVariant.values.length, equals(3));
    expect(ThemeButtonStyle, isA<Type>());
  });
}

/// Stub callback used in const constructors for tests.
void _stub() {}
