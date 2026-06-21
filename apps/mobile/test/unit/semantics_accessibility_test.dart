import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import '../golden/golden_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupPlatformMocks();

  group('ThemeButton.icon Semantics', () {
    testWidgets('exposes semanticLabel when provided', (tester) async {
      await tester.pumpWidget(goldenApp(
        ThemeButton.icon(
          icon: Icons.add,
          onPressed: () {},
          semanticLabel: 'Add record',
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Add record'), findsOneWidget);
    });

    testWidgets('exposes tooltip as fallback when no semanticLabel', (tester) async {
      await tester.pumpWidget(goldenApp(
        ThemeButton.icon(
          icon: Icons.close,
          onPressed: () {},
          tooltip: 'Close menu',
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Close menu'), findsOneWidget);
    });

    testWidgets('disabled icon button still exposes semantic label', (tester) async {
      await tester.pumpWidget(goldenApp(
        const ThemeButton.icon(
          icon: Icons.lock,
          onPressed: null,
          semanticLabel: 'Locked',
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Locked'), findsOneWidget);
    });
  });

  group('Social circle Semantics pattern', () {
    testWidgets('Google social circle has semantic label', (tester) async {
      await tester.pumpWidget(goldenApp(
        Semantics(
          label: 'Sign in with Google',
          button: true,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.g_mobiledata, size: 22),
            ),
          ),
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Sign in with Google'), findsOneWidget);
    });

    testWidgets('Apple social circle has semantic label', (tester) async {
      await tester.pumpWidget(goldenApp(
        Semantics(
          label: 'Sign in with Apple',
          button: true,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.apple, size: 22),
            ),
          ),
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Sign in with Apple'), findsOneWidget);
    });
  });

  group('FAB Semantics pattern', () {
    testWidgets('FAB with Semantics exposes label', (tester) async {
      await tester.pumpWidget(goldenApp(
        Semantics(
          label: 'Add milestone',
          button: true,
          child: FloatingActionButton(
            heroTag: 'test_fab',
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Add milestone'), findsOneWidget);
    });
  });

  group('No double-announcement pattern', () {
    testWidgets('Semantics without Tooltip avoids double announcement', (tester) async {
      await tester.pumpWidget(goldenApp(
        Semantics(
          label: 'Add growth record',
          button: true,
          child: const FloatingActionButton(
            heroTag: 'test_growth_fab',
            onPressed: null,
            child: Icon(Icons.add_chart),
          ),
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();

      // Should find exactly one semantic node with this label (no duplicate from Tooltip)
      expect(find.bySemanticsLabel('Add growth record'), findsOneWidget);
    });
  });
}
