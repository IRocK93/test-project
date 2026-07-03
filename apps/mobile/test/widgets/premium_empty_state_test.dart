import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/widgets/premium_empty_state.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';

/// Helper: wraps a widget in a MaterialApp for test pump context
Widget _wrapInApp(Widget child) {
  return MaterialApp(
      theme: AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.light),
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('PremiumEmptyState', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'Welcome!',
          subtitle: 'This is a subtitle.',
        ),
      ));

      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('This is a subtitle.'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'Hello',
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.baby), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel is provided',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'Empty',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
      ));

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ThemeButton), findsOneWidget);
    });

    testWidgets('action button triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapInApp(
        PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'Empty',
          actionLabel: 'Tap Me',
          onAction: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('noData preset renders correct text', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        Builder(
          builder: (context) => PremiumEmptyState.noData(
            context: context,
            itemName: 'milestone',
          ),
        ),
      ));

      expect(find.text('No milestone yet'), findsOneWidget);
      expect(find.text('Tap + to add your first milestone'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsLight.mailbox), findsOneWidget);
    });

    testWidgets('noData preset renders action button when onAdd provided',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        Builder(
          builder: (context) => PremiumEmptyState.noData(
            context: context,
            itemName: 'feeding',
            onAdd: () {},
          ),
        ),
      ));

      expect(find.text('Add feeding'), findsOneWidget);
      expect(find.byType(ThemeButton), findsOneWidget);
    });

    testWidgets('comingSoon preset renders correct text', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        Builder(
          builder: (context) => PremiumEmptyState.comingSoon(
            context: context,
            featureName: 'Chat',
          ),
        ),
      ));

      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Chat is under development.'), findsOneWidget);
    });

    testWidgets('comingSoon preset defaults to wrench icon', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        Builder(
          builder: (context) => PremiumEmptyState.comingSoon(context: context),
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.wrench), findsOneWidget);
    });

    testWidgets('customIcon overrides default icon', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'Custom',
          customIcon: Icon(PhosphorIconsLight.heart, size: 36),
        ),
      ));

      expect(find.byIcon(PhosphorIconsLight.heart), findsOneWidget);
      expect(find.byIcon(PhosphorIconsLight.baby), findsNothing);
    });

    testWidgets('no subtitle renders without error', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'No Subtitle',
        ),
      ));

      expect(find.text('No Subtitle'), findsOneWidget);
    });
  });
}
