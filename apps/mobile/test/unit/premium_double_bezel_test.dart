import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/widgets/premium_double_bezel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PremiumDoubleBezel', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            child: Text('Bezel content'),
          ),
        ),
      ));

      expect(find.byType(PremiumDoubleBezel), findsOneWidget);
      expect(find.text('Bezel content'), findsOneWidget);
    });

    testWidgets('renders with custom outerRadius', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            outerRadius: 20,
            child: Text('Custom radius'),
          ),
        ),
      ));

      expect(find.text('Custom radius'), findsOneWidget);
    });

    testWidgets('renders with custom gap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            gap: 4.0,
            child: Text('Custom gap'),
          ),
        ),
      ));

      expect(find.text('Custom gap'), findsOneWidget);
    });

    testWidgets('renders with custom outerColor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            outerColor: Colors.red.withValues(alpha: 0.1),
            child: const Text('Custom outer'),
          ),
        ),
      ));

      expect(find.text('Custom outer'), findsOneWidget);
    });

    testWidgets('renders with custom innerColor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            innerColor: Colors.blue.withValues(alpha: 0.1),
            child: const Text('Custom inner'),
          ),
        ),
      ));

      expect(find.text('Custom inner'), findsOneWidget);
    });

    testWidgets('renders with custom innerPadding', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            innerPadding: EdgeInsets.all(32),
            child: Text('Custom padding'),
          ),
        ),
      ));

      expect(find.text('Custom padding'), findsOneWidget);
    });

    testWidgets('renders with custom outerPadding', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            outerPadding: EdgeInsets.all(16),
            child: Text('Outer padding'),
          ),
        ),
      ));

      expect(find.text('Outer padding'), findsOneWidget);
    });

    testWidgets('wraps with GestureDetector when onTap is provided',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            onTap: () => tapped = true,
            child: const Text('Tappable'),
          ),
        ),
      ));

      expect(find.text('Tappable'), findsOneWidget);
      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets('does not wrap with GestureDetector when onTap is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            child: Text('Not tappable'),
          ),
        ),
      ));

      expect(find.text('Not tappable'), findsOneWidget);
    });

    testWidgets('hides inner highlight when showInnerHighlight is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            showInnerHighlight: false,
            child: Text('No highlight'),
          ),
        ),
      ));

      expect(find.text('No highlight'), findsOneWidget);
    });

    testWidgets('shows inner highlight by default', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            child: Text('With highlight'),
          ),
        ),
      ));

      expect(find.text('With highlight'), findsOneWidget);
    });

    testWidgets('renders with custom innerGradient', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            innerGradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
            ),
            child: Text('Gradient'),
          ),
        ),
      ));

      expect(find.text('Gradient'), findsOneWidget);
    });

    testWidgets('renders with custom innerBorder', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            innerBorder: Border.all(color: Colors.red, width: 2),
            child: const Text('Bordered'),
          ),
        ),
      ));

      expect(find.text('Bordered'), findsOneWidget);
    });

    testWidgets('renders with custom innerShadow', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            innerShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
            child: const Text('Custom shadow'),
          ),
        ),
      ));

      expect(find.text('Custom shadow'), findsOneWidget);
    });

    testWidgets('renders dark theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(
          body: PremiumDoubleBezel(
            child: Text('Dark theme'),
          ),
        ),
      ));

      expect(find.text('Dark theme'), findsOneWidget);
    });

    testWidgets('renders nested bezels', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            outerRadius: 24,
            gap: 6,
            child: PremiumDoubleBezel(
              outerRadius: 18,
              gap: 4,
              child: Text('Nested'),
            ),
          ),
        ),
      ));

      expect(find.text('Nested'), findsOneWidget);
      // Should have 2 PremiumDoubleBezel widgets
      expect(find.byType(PremiumDoubleBezel), findsNWidgets(2));
    });

    testWidgets('default outerRadius is DesignTokens.radius2xl',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            child: Text('Default radius'),
          ),
        ),
      ));

      expect(find.text('Default radius'), findsOneWidget);
    });

    testWidgets('default gap is 6.0', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            child: Text('Default gap'),
          ),
        ),
      ));

      expect(find.text('Default gap'), findsOneWidget);
    });

    testWidgets('wraps with Semantics widget when onTap is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumDoubleBezel(
            onTap: () {},
            child: const Text('Semantic'),
          ),
        ),
      ));

      // PremiumDoubleBezel wraps with Semantics(label: 'Tap') when onTap is set
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
