import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/widgets/animated_entry.dart';

/// Helper: wraps a widget in a MaterialApp for test pump context
Widget _wrapInApp(Widget child) {
  return MaterialApp(
      theme: AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.light),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('ScalePress', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ScalePress(
          child: Text('Press Me'),
        ),
      ));

      expect(find.text('Press Me'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapInApp(
        ScalePress(
          child: const Text('Tap Test'),
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap Test'));
      expect(tapped, isTrue);
    });

    testWidgets('does nothing when no onTap provided', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ScalePress(
          child: Text('No Op'),
        ),
      ));

      // Should not throw when tapped without onTap
      await tester.tap(find.text('No Op'));
    });

    testWidgets('scale animates on press and returns on release',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        ScalePress(
          scaleAmount: 0.8,
          onTap: () {},
          child: const Text('Animate'),
        ),
      ));

      // Find the Transform widget
      final transformFinder = find.descendant(
        of: find.byType(ScalePress),
        matching: find.byType(Transform),
      );

      // Initially scale should be 1.0
      Transform transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Animate')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Scale should be animating toward 0.8
      transform = tester.widget<Transform>(transformFinder);
      final scaleDuringPress = transform.transform.getMaxScaleOnAxis();
      expect(scaleDuringPress, lessThan(1.0));

      // Release
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // Scale should return to 1.0
      transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
    });

    testWidgets('custom pressDuration affects animation speed',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        ScalePress(
          scaleAmount: 0.9,
          pressDuration: const Duration(milliseconds: 500),
          releaseDuration: const Duration(milliseconds: 100),
          onTap: () {},
          child: const Text('Custom Durations'),
        ),
      ));

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Custom Durations')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // After only 50ms of a 500ms animation, scale should be slightly less than 1.0
      final transformFinder = find.descendant(
        of: find.byType(ScalePress),
        matching: find.byType(Transform),
      );
      final transform = tester.widget<Transform>(transformFinder);
      final scale = transform.transform.getMaxScaleOnAxis();
      expect(scale, lessThan(1.0));
      expect(scale, greaterThan(0.9));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('releaseDuration controls reverse animation speed',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        ScalePress(
          scaleAmount: 0.9,
          pressDuration: const Duration(milliseconds: 500),
          releaseDuration: const Duration(milliseconds: 50),
          onTap: () {},
          child: const Text('Release Speed'),
        ),
      ));

      final transformFinder = find.descendant(
        of: find.byType(ScalePress),
        matching: find.byType(Transform),
      );

      // Press and hold to animate to pressed state
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Release Speed')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should be at pressed scale
      Transform transform = tester.widget<Transform>(transformFinder);
      expect(
        transform.transform.getMaxScaleOnAxis(),
        closeTo(0.9, 0.02),
      );

      // Release — reverse should complete quickly with 50ms releaseDuration
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 100ms is more than the 50ms releaseDuration but less than the
      // 500ms pressDuration — the reverse should already be complete.
      transform = tester.widget<Transform>(transformFinder);
      expect(
        transform.transform.getMaxScaleOnAxis(),
        closeTo(1.0, 0.01),
      );
    });

    testWidgets('magneticOffset affects translation on press',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        ScalePress(
          scaleAmount: 0.95,
          magneticOffset: 5.0,
          magneticAngle: 0.0, // purely horizontal
          onTap: () {},
          child: const Text('Magnetic'),
        ),
      ));

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Magnetic')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // After full animation, translation should be (5.0, 0.0)
      final transformFinder = find.descendant(
        of: find.byType(ScalePress),
        matching: find.byType(Transform),
      );
      final transform = tester.widget<Transform>(transformFinder);
      final translation = transform.transform.getTranslation();
      expect(translation.x, closeTo(5.0, 0.5));

      await gesture.up();
      await tester.pumpAndSettle();

      // After release, translation returns to (0, 0)
      final transformAfter = tester.widget<Transform>(transformFinder);
      final translationAfter = transformAfter.transform.getTranslation();
      expect(translationAfter.x, closeTo(0.0, 0.5));
    });
  });
}
