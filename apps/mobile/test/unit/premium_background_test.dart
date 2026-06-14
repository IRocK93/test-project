import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/widgets/premium_background.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildBackground({
    Brightness brightness = Brightness.light,
    AppVisualStyle visualStyle = AppVisualStyle.glass,
    bool showOrnaments = true,
    Widget? child,
  }) {
    return ProviderScope(
      overrides: [
        appVisualStyleProvider.overrideWith((ref) {
          final notifier = AppVisualStyleNotifier();
          if (visualStyle == AppVisualStyle.clay) {
            notifier.setStyle(AppVisualStyle.clay);
          }
          return notifier;
        }),
      ],
      child: MaterialApp(
        theme: visualStyle == AppVisualStyle.clay
            ? (brightness == Brightness.dark
                ? ThemeData(brightness: Brightness.dark)
                : ThemeData(brightness: Brightness.light))
            : (brightness == Brightness.dark
                ? ThemeData(brightness: Brightness.dark)
                : ThemeData(brightness: Brightness.light)),
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Scaffold(
            body: PremiumBackground(
              showOrnaments: showOrnaments,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  group('PremiumBackground', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        child: const Text('Hello'),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(PremiumBackground), findsOneWidget);
    });

    testWidgets('renders with glass style light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.glass,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PremiumBackground), findsOneWidget);
      // Should have a Stack with gradient and radial orbs
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('renders with glass style dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.glass,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PremiumBackground), findsOneWidget);
    });

    testWidgets('renders with clay style light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PremiumBackground), findsOneWidget);
    });

    testWidgets('renders with clay style dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PremiumBackground), findsOneWidget);
    });

    testWidgets('hides ornaments when showOrnaments is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        showOrnaments: false,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PremiumBackground), findsOneWidget);
      // With ornaments hidden, fewer Positioned widgets (only child in Stack)
      final stack = tester.widget<Stack>(find.byType(Stack).first);
      // Should have 2 children: gradient Container + child (no radial orbs)
      expect(stack.children.length, 2);
    });

    testWidgets('shows ornaments by default', (WidgetTester tester) async {
      await tester.pumpWidget(buildBackground(
        showOrnaments: true,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PremiumBackground), findsOneWidget);
      final stack = tester.widget<Stack>(find.byType(Stack).first);
      // Should have more than 2 children: gradient + radial orbs + child
      expect(stack.children.length, greaterThan(2));
    });
  });
}
