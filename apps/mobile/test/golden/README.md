# Golden Tests

Visual regression tests for BabyMon's premium UI components and screens across all theme combinations.

## Structure

```
test/golden/
├── golden_helpers.dart              # Shared utilities: goldenApp(), matchesGolden(), setupPlatformMocks()
├── golden_auth_stubs.dart           # GoldenLoginForm, GoldenRegisterForm stubs
├── golden_splash_stubs.dart         # GoldenSplashScreen stub
├── golden_onboarding_stubs.dart     # GoldenOnboardingEmpty/Partial/Complete stubs
├── golden_error_stubs.dart          # GoldenErrorBanner, GoldenLoadingOverlay stubs
├── golden_components_test.dart      # 28 tests — base component rendering across 4 themes
├── golden_screens_test.dart         # 80 tests — full screen rendering across 4 themes
├── golden_states_test.dart          # 28 tests — interactive states (loading, disabled, tap)
├── golden_error_states_test.dart    # 24 tests — error banners, empty states, loading spinners
├── golden_semantics_test.dart       # 16 tests — accessibility labels and semantic verification
├── golden_performance_test.dart     # 20 tests — render time benchmarks with 500ms threshold
└── goldens/                         # Generated golden files (auto-committed by CI)
```

## Theme Matrix

Every visual test runs across **4 theme combinations**:

| Theme        | Visual Style | Brightness |
|-------------|-------------|-----------|
| Dark Glass  | `glass`     | `dark`    |
| Dark Clay   | `clay`      | `dark`    |
| Light Glass | `glass`     | `light`   |
| Light Clay  | `clay`      | `light`   |

## Tagging

All golden test files are annotated with `@Tags(['golden'])` so they can be excluded from fast CI runs:

```bash
# Run only golden tests
flutter test test/golden/

# Run everything EXCEPT golden tests
flutter test --exclude-tags golden
```

## Running

```bash
# Run all golden tests
flutter test test/golden/

# Run a specific golden test file
flutter test test/golden/golden_components_test.dart

# Regenerate baselines (after intentional UI changes)
flutter test test/golden/ --update-goldens
```

## Adding a New Golden Test

1. **Choose the right file** based on what you're testing:
   - `golden_components_test.dart` — standalone widgets (cards, buttons, progress bars)
   - `golden_screens_test.dart` — full screen layouts
   - `golden_states_test.dart` — interactive states (hover, loading, disabled)
   - `golden_error_states_test.dart` — error banners, empty states, loading overlays
   - `golden_semantics_test.dart` — accessibility label verification
   - `golden_performance_test.dart` — render time benchmarks

2. **Add a stub** if needed (for screens with complex dependencies):
   - Create `golden_<domain>_stubs.dart` in this directory
   - Follow the pattern of existing stubs (GoldenLoginForm, GoldenSplashScreen, etc.)

3. **Add the test** in all 4 theme groups:
   ```dart
   group('Components — dark glass', () {
     testWidgets('MyWidget', (tester) async {
       await tester.pumpWidget(goldenApp(
         const MyWidget(),
         brightness: Brightness.dark,
       ));
       await tester.pumpAndSettle();
       await matchesGolden(tester, 'dark_glass_my_widget.png');
     });
   });
   ```

4. **Generate baselines**:
   ```bash
   flutter test test/golden/ --update-goldens
   ```

5. **Review the golden files** in `goldens/` to verify they look correct.

## Golden File Naming Convention

```
{brightness}_{visualStyle}_{component}.png

Examples:
  dark_glass_card.png
  dark_clay_button_loading.png
  light_glass_stat_card.png
  light_clay_error_network.png
```

## CI Integration

- **Parallel execution**: CI runs 3 separate golden jobs (`golden-components`, `golden-screens`, `golden-states`) plus a `flutter-test` job that excludes goldens via `--exclude-tags golden`.
- **Baseline updates**: On pushes to `main`, the `update-goldens` job regenerates baselines and auto-commits them.
- **Failure artifacts**: Failed golden tests upload diff images for debugging.

## Stubs vs Real Screens

- **Stubs** (`golden_*_stubs.dart`) are simplified widget shells that avoid platform plugins, complex state, and provider dependencies. They render the same visual layout without the real screen's initialization logic.
- **Real screens** (e.g., `DashboardScreen`, `SettingsScreen`) are used directly when they have no problematic dependencies.

## Performance Benchmarks

Golden performance tests assert that each widget renders within **500ms** in the test environment. CI machines lack GPU acceleration, so this threshold is generous. To tighten it:

1. Run locally with `flutter test test/golden/golden_performance_test.dart`
2. Check the elapsed times in the test output
3. Adjust `_maxRenderMs` in `golden_performance_test.dart` accordingly
