import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/mixins/data_screen_mixin.dart';
import 'package:baby_mon/core/widgets/premium_empty_state.dart';

/// Tracks how many times onEmptyAction was called.
int _emptyActionCount = 0;

/// Minimal concrete widget that uses DataScreenMixin for testing.
class _TestScreen extends ConsumerStatefulWidget {
  const _TestScreen();

  @override
  ConsumerState<_TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<_TestScreen>
    with DataScreenMixin<_TestScreen> {
  @override
  String get emptyTitle => 'No items yet';

  @override
  String get emptySubtitle => 'Add your first item to get started.';

  @override
  String get emptyActionLabel => 'Add Item';

  @override
  IconData get emptyIcon => Icons.inbox_rounded;

  @override
  Duration get refreshCooldown => const Duration(seconds: 10);

  @override
  int get listenToTabRefresh => 0;

  @override
  Future<void> fetchData() async {}

  @override
  void onEmptyAction() {
    _emptyActionCount++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildEmptyState(),
    );
  }
}

/// Helper to create a testable widget wrapped in ProviderScope.
Widget _buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  setUp(() {
    _emptyActionCount = 0;
  });

  group('DataScreenMixin', () {
    testWidgets('shows empty state when items list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const _TestScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Add your first item to get started.'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });

    testWidgets('empty action button triggers onEmptyAction callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const _TestScreen()));
      await tester.pumpAndSettle();

      final addButton = find.text('Add Item');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(_emptyActionCount, 1);
    });

    testWidgets('empty state uses correct visual design',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const _TestScreen()));
      await tester.pumpAndSettle();

      // Verify PremiumEmptyState is rendered with correct content
      expect(find.byType(PremiumEmptyState), findsOneWidget);
    });
  });
}
