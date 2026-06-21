import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/utils/theme_text_utils.dart';
import 'package:baby_mon/core/widgets/theme_text.dart';

void main() {
  group('ThemeTextColor extension', () {
    testWidgets('textPrimary returns onSurface in light mode',
        (tester) async {
      Color? captured;
      final theme = ThemeData(brightness: Brightness.light);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context.textPrimary;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, equals(theme.colorScheme.onSurface));
    });

    testWidgets('textPrimary returns onPrimary in dark mode',
        (tester) async {
      Color? captured;
      final theme = AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context.textPrimary;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, equals(theme.colorScheme.onSurface));
    });

    testWidgets('textSecondary returns onSurfaceVariant in light mode',
        (tester) async {
      Color? captured;
      final theme = ThemeData(brightness: Brightness.light);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context.textSecondary;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, equals(theme.colorScheme.onSurfaceVariant));
    });

    testWidgets('textSecondary returns onSurfaceVariant in dark mode',
        (tester) async {
      Color? captured;
      final theme = AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context.textSecondary;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, equals(theme.colorScheme.onSurfaceVariant));
    });

    testWidgets('textCaption returns muted onSurfaceVariant in light mode',
        (tester) async {
      Color? captured;
      final theme = ThemeData(brightness: Brightness.light);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context.textCaption;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, equals(theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)));
    });

    testWidgets('textCaption returns muted onSurfaceVariant in dark mode',
        (tester) async {
      Color? captured;
      final theme = AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context.textCaption;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, equals(theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)));
    });
  });

  group('ThemeText widget', () {
    testWidgets('renders text with correct color in light mode',
        (tester) async {
      final theme = ThemeData(brightness: Brightness.light);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Material(
            child: Center(
              child: ThemeText('Hello', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Hello'));
      // ThemeText applies textPrimary color when no explicit color is set
      // and brightness is light → colorScheme.onSurface
      expect(textWidget.style?.color, equals(theme.colorScheme.onSurface));
    });

    testWidgets('renders text with correct color in dark mode',
        (tester) async {
      final theme = AppTheme.resolve(visualStyle: 'glass', brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Material(
            child: Center(
              child: ThemeText('Hello Dark', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );

      expect(find.text('Hello Dark'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Hello Dark'));
      // ThemeText applies textPrimary color → onSurface in dark mode
      expect(textWidget.style?.color, equals(theme.colorScheme.onSurface));
    });
  });
}
