@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart' hide AppThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'golden_helpers.dart';
import 'golden_error_stubs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setupPlatformMocks();

  // ---------------------------------------------------------------------------
  // Error state goldens — dark glass
  // ---------------------------------------------------------------------------
  group('Error states — dark glass', () {
    testWidgets('Network error banner with retry', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenErrorBanner(
          message: 'Unable to connect to server. Please check your internet connection.',
          onRetry: null,
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_error_network.png');
    });

    testWidgets('Empty state — no data', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.inbox_rounded,
          title: 'No items yet',
          subtitle: 'Items you add will appear here.',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_empty_no_data.png');
    });

    testWidgets('Empty state — no results', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results found',
          subtitle: 'Try adjusting your search or filters.',
          actionLabel: 'Clear Filters',
          onAction: () {},
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_empty_no_results.png');
    });

    testWidgets('Empty state — error', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Connection lost',
          subtitle: 'Unable to load data. Pull to refresh or check your connection.',
          actionLabel: 'Retry',
          onAction: () {},
        ),
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_glass_empty_error.png');
    });

    testWidgets('Loading spinner with message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(message: 'Loading milestones...'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'dark_glass_loading_message.png');
    });

    testWidgets('Loading spinner without message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'dark_glass_loading_bare.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Error state goldens — dark clay
  // ---------------------------------------------------------------------------
  group('Error states — dark clay', () {
    testWidgets('Network error banner', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenErrorBanner(
          message: 'Unable to connect to server. Please check your internet connection.',
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_error_network.png');
    });

    testWidgets('Empty state — no data', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.inbox_rounded,
          title: 'No items yet',
          subtitle: 'Items you add will appear here.',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_empty_no_data.png');
    });

    testWidgets('Empty state — no results', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results found',
          subtitle: 'Try adjusting your search or filters.',
          actionLabel: 'Clear Filters',
          onAction: () {},
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_empty_no_results.png');
    });

    testWidgets('Empty state — error', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Connection lost',
          subtitle: 'Unable to load data. Pull to refresh or check your connection.',
          actionLabel: 'Retry',
          onAction: () {},
        ),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'dark_clay_empty_error.png');
    });

    testWidgets('Loading spinner with message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(message: 'Loading milestones...'),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'dark_clay_loading_message.png');
    });

    testWidgets('Loading spinner without message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(),
        brightness: Brightness.dark,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'dark_clay_loading_bare.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Error state goldens — light glass
  // ---------------------------------------------------------------------------
  group('Error states — light glass', () {
    testWidgets('Network error banner', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenErrorBanner(
          message: 'Unable to connect to server. Please check your internet connection.',
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_error_network.png');
    });

    testWidgets('Empty state — no data', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.inbox_rounded,
          title: 'No items yet',
          subtitle: 'Items you add will appear here.',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_empty_no_data.png');
    });

    testWidgets('Empty state — no results', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results found',
          subtitle: 'Try adjusting your search or filters.',
          actionLabel: 'Clear Filters',
          onAction: () {},
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_empty_no_results.png');
    });

    testWidgets('Empty state — error', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Connection lost',
          subtitle: 'Unable to load data. Pull to refresh or check your connection.',
          actionLabel: 'Retry',
          onAction: () {},
        ),
        brightness: Brightness.light,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_glass_empty_error.png');
    });

    testWidgets('Loading spinner with message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(message: 'Loading milestones...'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'light_glass_loading_message.png');
    });

    testWidgets('Loading spinner without message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(),
        brightness: Brightness.light,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'light_glass_loading_bare.png');
    });
  });

  // ---------------------------------------------------------------------------
  // Error state goldens — light clay
  // ---------------------------------------------------------------------------
  group('Error states — light clay', () {
    testWidgets('Network error banner', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenErrorBanner(
          message: 'Unable to connect to server. Please check your internet connection.',
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_error_network.png');
    });

    testWidgets('Empty state — no data', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.inbox_rounded,
          title: 'No items yet',
          subtitle: 'Items you add will appear here.',
          actionLabel: 'Add Item',
          onAction: () {},
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_empty_no_data.png');
    });

    testWidgets('Empty state — no results', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results found',
          subtitle: 'Try adjusting your search or filters.',
          actionLabel: 'Clear Filters',
          onAction: () {},
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_empty_no_results.png');
    });

    testWidgets('Empty state — error', (tester) async {
      await tester.pumpWidget(goldenApp(
        PremiumEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Connection lost',
          subtitle: 'Unable to load data. Pull to refresh or check your connection.',
          actionLabel: 'Retry',
          onAction: () {},
        ),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pumpAndSettle();
      await matchesGolden(tester, 'light_clay_empty_error.png');
    });

    testWidgets('Loading spinner with message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(message: 'Loading milestones...'),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'light_clay_loading_message.png');
    });

    testWidgets('Loading spinner without message', (tester) async {
      await tester.pumpWidget(goldenApp(
        const GoldenLoadingOverlay(),
        brightness: Brightness.light,
        visualStyle: AppVisualStyle.clay,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await matchesGolden(tester, 'light_clay_loading_bare.png');
    });
  });
}
