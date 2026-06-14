import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/widgets/premium_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PremiumCard', () {
    testWidgets('renders child in standard mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            child: Text('Card content'),
          ),
        ),
      ));

      expect(find.byType(PremiumCard), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders with glass effect', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            isGlass: true,
            child: Text('Glass card'),
          ),
        ),
      ));

      expect(find.byType(PremiumCard), findsOneWidget);
      expect(find.text('Glass card'), findsOneWidget);
      // Glass cards use ClipRRect + BackdropFilter
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('renders with custom padding', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            padding: EdgeInsets.all(32),
            child: Text('Padded'),
          ),
        ),
      ));

      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('renders with custom margin', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            margin: EdgeInsets.all(16),
            child: Text('Margined'),
          ),
        ),
      ));

      expect(find.text('Margined'), findsOneWidget);
    });

    testWidgets('renders with fixed height and width',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            height: 100,
            width: 200,
            child: Text('Sized'),
          ),
        ),
      ));

      expect(find.text('Sized'), findsOneWidget);
    });

    testWidgets('wraps with ScalePress when onTap is provided',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            onTap: () => tapped = true,
            child: const Text('Tappable'),
          ),
        ),
      ));

      expect(find.text('Tappable'), findsOneWidget);
      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets('does not wrap with ScalePress when onTap is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            child: Text('Not tappable'),
          ),
        ),
      ));

      expect(find.text('Not tappable'), findsOneWidget);
    });

    testWidgets('renders hero bento variant', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            bentoVariant: BentoVariant.hero,
            child: Text('Hero card'),
          ),
        ),
      ));

      expect(find.text('Hero card'), findsOneWidget);
    });

    testWidgets('renders compact bento variant', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            bentoVariant: BentoVariant.compact,
            child: Text('Compact card'),
          ),
        ),
      ));

      expect(find.text('Compact card'), findsOneWidget);
    });

    testWidgets('renders with gradient', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
            ),
            child: Text('Gradient card'),
          ),
        ),
      ));

      expect(find.text('Gradient card'), findsOneWidget);
    });

    testWidgets('renders with custom border', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            border: Border.all(color: Colors.red, width: 2),
            child: const Text('Bordered card'),
          ),
        ),
      ));

      expect(find.text('Bordered card'), findsOneWidget);
    });

    testWidgets('renders dark theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(
          body: PremiumCard(
            isGlass: true,
            child: Text('Dark glass'),
          ),
        ),
      ));

      expect(find.text('Dark glass'), findsOneWidget);
    });
  });

  group('PremiumCard.glassGroup', () {
    testWidgets('renders vertical glass group', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard.glassGroup(
            children: [
              const Text('Item 1'),
              const Text('Item 2'),
            ],
          ),
        ),
      ));

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('renders horizontal glass group', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard.glassGroup(
            direction: Axis.horizontal,
            children: [
              const Text('Left'),
              const Text('Right'),
            ],
          ),
        ),
      ));

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('renders with gap between items',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard.glassGroup(
            gap: 16,
            children: [
              const Text('A'),
              const Text('B'),
              const Text('C'),
            ],
          ),
        ),
      ));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders with custom padding', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard.glassGroup(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('Padded group'),
            ],
          ),
        ),
      ));

      expect(find.text('Padded group'), findsOneWidget);
    });

    testWidgets('renders empty group gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard.glassGroup(
            children: [],
          ),
        ),
      ));

      expect(find.byType(PremiumCard), findsNothing);
      // The ClipRRect wrapping should still exist
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('renders with margin', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PremiumCard.glassGroup(
            margin: const EdgeInsets.all(16),
            children: [
              const Text('Margined group'),
            ],
          ),
        ),
      ));

      expect(find.text('Margined group'), findsOneWidget);
    });
  });
}
