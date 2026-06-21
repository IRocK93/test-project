import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/widgets/fade_scale_in.dart';
import 'package:baby_mon/core/widgets/animated_entry.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';

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
  // ─────────────────────────────────────────
  //  FadeScaleIn
  // ─────────────────────────────────────────
  group('FadeScaleIn', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const FadeScaleIn(
          child: Text('Hello'),
        ),
      ));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('opacity reaches 1.0 after animation completes',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const FadeScaleIn(
          duration: Duration(milliseconds: 300),
          child: Text('Animate Me'),
        ),
      ));

      // After settle, opacity should be 1
      await tester.pumpAndSettle();
      final opacityWidget = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(FadeScaleIn),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, equals(1.0));
    });

    testWidgets('scale reaches 1.0 after animation completes', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const FadeScaleIn(
          duration: Duration(milliseconds: 300),
          child: Text('Scale Test'),
        ),
      ));

      // After settle, scale should be 1.0
      await tester.pumpAndSettle();
      final transformWidget = tester.widget<Transform>(
        find.descendant(
          of: find.byType(FadeScaleIn),
          matching: find.byType(Transform),
        ),
      );
      expect(
        transformWidget.transform.getMaxScaleOnAxis(),
        closeTo(1.0, 0.01),
      );
    });

    testWidgets('respects delay parameter', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const FadeScaleIn(
          duration: Duration(milliseconds: 100),
          delay: Duration(milliseconds: 200),
          child: Text('Delayed'),
        ),
      ));

      // Before delay elapses, widget should show SizedBox.shrink()
      expect(find.text('Delayed'), findsNothing);

      // Pump past the delay (200ms) so the Future.delayed resolves
      await tester.pump(const Duration(milliseconds: 250));

      // After delay, the TweenAnimationBuilder should render the child
      expect(find.text('Delayed'), findsOneWidget);

      // Fully settle the animation
      await tester.pumpAndSettle();
      expect(find.text('Delayed'), findsOneWidget);
    });

    testWidgets('uses DesignTokens defaults when not overridden',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const FadeScaleIn(
          child: Text('Defaults'),
        ),
      ));

      // Should render successfully with default duration/curve
      await tester.pumpAndSettle();
      expect(find.text('Defaults'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────
  //  StaggeredFadeSlide
  // ─────────────────────────────────────────
  group('StaggeredFadeSlide', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const StaggeredFadeSlide(
          index: 0,
          child: Text('Staggered'),
        ),
      ));

      expect(find.text('Staggered'), findsOneWidget);
    });

    testWidgets('opacity reaches 1.0 after animation completes',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const StaggeredFadeSlide(
          index: 0,
          duration: Duration(milliseconds: 400),
          child: Text('Index Zero'),
        ),
      ));

      // Advance past the Timer (index 0 = 0ms delay)
      await tester.pump(const Duration(milliseconds: 1));
      // Settle all animations
      await tester.pumpAndSettle();

      // Opacity should be 1
      final opacityWidget = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(StaggeredFadeSlide),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, equals(1.0));
    });

    testWidgets('translation reaches 0 after animation completes',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const StaggeredFadeSlide(
          index: 0,
          duration: Duration(milliseconds: 400),
          child: Text('Translate'),
        ),
      ));

      // Advance past the Timer
      await tester.pump(const Duration(milliseconds: 1));
      // Settle all animations
      await tester.pumpAndSettle();

      // Translation should be 0
      final transformWidget = tester.widget<Transform>(
        find.descendant(
          of: find.byType(StaggeredFadeSlide),
          matching: find.byType(Transform),
        ),
      );
      final translation = transformWidget.transform.getTranslation();
      expect(translation.y, closeTo(0.0, 0.01));
    });

    testWidgets('higher index delays animation completion', (tester) async {
      // Two items: index 0 (0ms delay) and index 5 (400ms delay)
      // Total time for both to complete: 400ms + 400ms = 800ms
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            StaggeredFadeSlide(
              key: Key('first'),
              index: 0,
              duration: Duration(milliseconds: 400),
              child: Text('First'),
            ),
            StaggeredFadeSlide(
              key: Key('fifth'),
              index: 5,
              duration: Duration(milliseconds: 400),
              child: Text('Fifth'),
            ),
          ],
        ),
      ));

      // Pump multiple frames to advance the clock and tick the
      // AnimationController. At ~100ms: index 0's Timer fired at 0ms
      // and animation has been running ~25% through 400ms. Index 5's
      // Timer fires at 400ms, so its animation hasn't started yet.
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      // Find each StaggeredFadeSlide's opacity using keys
      final firstOpacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('first')),
          matching: find.byType(Opacity),
        ),
      );
      final fifthOpacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('fifth')),
          matching: find.byType(Opacity),
        ),
      );

      // First should be animating (> 0)
      expect(firstOpacity.opacity, greaterThan(0.0));
      // Fifth should not have started yet (= 0)
      expect(fifthOpacity.opacity, equals(0.0));

      // Settle all (this will take ~700ms more to complete index 5's animation)
      await tester.pumpAndSettle();
    });

    testWidgets('all items complete animation after sufficient time',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            StaggeredFadeSlide(
              key: Key('first'),
              index: 0,
              duration: Duration(milliseconds: 200),
              child: Text('First'),
            ),
            StaggeredFadeSlide(
              key: Key('fifth'),
              index: 5,
              duration: Duration(milliseconds: 200),
              child: Text('Fifth'),
            ),
          ],
        ),
      ));

      // Settle all animations (pumpAndSettle will run until no more frames)
      // Index 5's Timer fires at 400ms, then animation runs 200ms = 600ms total
      await tester.pumpAndSettle();

      // Both opacities should be 1
      final firstOpacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('first')),
          matching: find.byType(Opacity),
        ),
      );
      final fifthOpacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('fifth')),
          matching: find.byType(Opacity),
        ),
      );

      expect(firstOpacity.opacity, equals(1.0));
      expect(fifthOpacity.opacity, equals(1.0));
    });
  });

  // ─────────────────────────────────────────
  //  ScrollStagger
  // ─────────────────────────────────────────
  group('ScrollStagger', () {
    testWidgets('starts with opacity 0 before Timer fires', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ScrollStagger(
          index: 0,
          child: Text('Scroll Item'),
        ),
      ));

      // Before Timer fires, _hasAnimated is false, so opacity should be 0
      final opacityWidget = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(ScrollStagger),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, equals(0.0));
    });

    testWidgets('opacity reaches 1.0 after animation completes',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ScrollStagger(
          index: 0,
          duration: Duration(milliseconds: 400),
          child: Text('Scroll Animated'),
        ),
      ));

      // Advance past the Timer (index 0 = 0ms delay)
      await tester.pump(const Duration(milliseconds: 1));
      // Settle all animations
      await tester.pumpAndSettle();

      // Opacity should be 1
      final opacityWidget = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(ScrollStagger),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, equals(1.0));
    });

    testWidgets('higher index delays Timer firing', (tester) async {
      // Two items: index 0 (0ms delay) and index 3 (240ms delay)
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            ScrollStagger(
              key: Key('itemA'),
              index: 0,
              duration: Duration(milliseconds: 200),
              child: Text('Item A'),
            ),
            ScrollStagger(
              key: Key('itemB'),
              index: 3,
              duration: Duration(milliseconds: 200),
              child: Text('Item B'),
            ),
          ],
        ),
      ));

      // Pump multiple frames to advance the clock and tick the
      // AnimationController. At ~100ms: index 0's Timer fired at 0ms
      // and animation has been running ~50% through 200ms. Index 3's
      // Timer fires at 240ms, so _hasAnimated is still false.
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      // Find each ScrollStagger's opacity using keys
      final opacityA = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('itemA')),
          matching: find.byType(Opacity),
        ),
      );
      final opacityB = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('itemB')),
          matching: find.byType(Opacity),
        ),
      );

      // A should be animating (> 0)
      expect(opacityA.opacity, greaterThan(0.0));
      // B should still be hidden (= 0)
      expect(opacityB.opacity, equals(0.0));

      // Settle all
      await tester.pumpAndSettle();
    });

    testWidgets('translation reaches 0 after animation completes',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const ScrollStagger(
          index: 0,
          duration: Duration(milliseconds: 400),
          child: Text('Offset Check'),
        ),
      ));

      // Advance past the Timer
      await tester.pump(const Duration(milliseconds: 1));
      // Settle all animations
      await tester.pumpAndSettle();

      // Translation should be 0
      final transformWidget = tester.widget<Transform>(
        find.descendant(
          of: find.byType(ScrollStagger),
          matching: find.byType(Transform),
        ),
      );
      final translation = transformWidget.transform.getTranslation();
      expect(translation.y, closeTo(0.0, 0.01));
    });

    testWidgets('all items complete animation after sufficient time',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Column(
          children: [
            ScrollStagger(
              key: Key('itemA'),
              index: 0,
              duration: Duration(milliseconds: 200),
              child: Text('Item A'),
            ),
            ScrollStagger(
              key: Key('itemB'),
              index: 3,
              duration: Duration(milliseconds: 200),
              child: Text('Item B'),
            ),
          ],
        ),
      ));

      // Settle all animations
      // Index 3's Timer fires at 240ms, then animation runs 200ms = 440ms total
      await tester.pumpAndSettle();

      // Both opacities should be 1
      final opacityA = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('itemA')),
          matching: find.byType(Opacity),
        ),
      );
      final opacityB = tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('itemB')),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacityA.opacity, equals(1.0));
      expect(opacityB.opacity, equals(1.0));
    });
  });

  // ─────────────────────────────────────────
  //  Integration: animation widgets with DesignTokens
  // ─────────────────────────────────────────
  group('DesignTokens integration', () {
    testWidgets('DesignTokens contain expected animation values',
        (tester) async {
      // Verify that the expected constants are defined with reasonable values
      expect(DesignTokens.durationEntrance, const Duration(milliseconds: 400));
      expect(DesignTokens.staggerDelayMs, 80);
      expect(DesignTokens.fadeScaleInBegin, 0.5);
      expect(DesignTokens.slideUpOffset, 20.0);
      expect(DesignTokens.curveEntrance, Curves.easeOutCubic);
      expect(DesignTokens.curveBounce, Curves.easeOutBack);
    });
  });
}
