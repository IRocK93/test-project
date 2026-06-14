import 'dart:io';

/// Golden Test Coverage Report Generator
///
/// Scans the project for all screens and widgets, cross-references them
/// against golden test files, and produces a formatted coverage report.
///
/// Usage:
///   dart run tool/golden_coverage_report.dart
///   dart run tool/golden_coverage_report.dart --json
///   dart run tool/golden_coverage_report.dart --markdown
void main(List<String> args) {
  final jsonOutput = args.contains('--json');
  final markdownOutput = args.contains('--markdown');

  final projectRoot = _findProjectRoot();
  final libDir = Directory('$projectRoot/lib');
  final goldenDir = Directory('$projectRoot/test/golden');

  if (!libDir.existsSync()) {
    stderr.writeln('Error: lib/ directory not found at ${libDir.path}');
    exit(1);
  }
  if (!goldenDir.existsSync()) {
    stderr.writeln('Error: test/golden/ directory not found at ${goldenDir.path}');
    exit(1);
  }

  // Gather all golden test names
  final goldenTests = _extractGoldenTestNames(goldenDir);

  // Build stub mappings dynamically from golden_*_stubs.dart files
  final stubMappings = _buildStubMappings(goldenDir, goldenTests);

  // Discover screens
  final screens = _discoverScreens(libDir);

  // Discover core widgets
  final coreWidgets = _discoverCoreWidgets(libDir);

  // Discover feature widgets
  final featureWidgets = _discoverFeatureWidgets(libDir);

  // Build report
  final screenResults = screens.map((s) {
    final covered = _isCoveredByGolden(s.className, goldenTests, stubMappings);
    final goldenFile = covered ? _findGoldenFile(s.className, goldenDir) : null;
    return CoverageItem(
      name: s.className,
      filePath: s.relativePath,
      category: 'Screen',
      feature: s.feature,
      covered: covered,
      goldenFile: goldenFile,
    );
  }).toList();

  final coreWidgetResults = coreWidgets.map((w) {
    final covered = _isCoveredByGolden(w.className, goldenTests, stubMappings);
    final goldenFile = covered ? _findGoldenFile(w.className, goldenDir) : null;
    return CoverageItem(
      name: w.className,
      filePath: w.relativePath,
      category: 'Core Widget',
      feature: 'core',
      covered: covered,
      goldenFile: goldenFile,
    );
  }).toList();

  final featureWidgetResults = featureWidgets.map((w) {
    final covered = _isCoveredByGolden(w.className, goldenTests, stubMappings);
    final goldenFile = covered ? _findGoldenFile(w.className, goldenDir) : null;
    return CoverageItem(
      name: w.className,
      filePath: w.relativePath,
      category: 'Feature Widget',
      feature: w.feature,
      covered: covered,
      goldenFile: goldenFile,
    );
  }).toList();

  final allItems = [...screenResults, ...coreWidgetResults, ...featureWidgetResults];
  final totalCovered = allItems.where((i) => i.covered).length;
  final total = allItems.length;
  final uncovered = allItems.where((i) => !i.covered).toList();

  if (jsonOutput) {
    _printJson(allItems, totalCovered, total);
  } else if (markdownOutput) {
    _printMarkdown(screenResults, coreWidgetResults, featureWidgetResults, totalCovered, total);
  } else {
    _printTerminal(screenResults, coreWidgetResults, featureWidgetResults, totalCovered, total, uncovered);
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class CoverageItem {
  final String name;
  final String filePath;
  final String category;
  final String feature;
  final bool covered;
  final String? goldenFile;

  CoverageItem({
    required this.name,
    required this.filePath,
    required this.category,
    required this.feature,
    required this.covered,
    this.goldenFile,
  });
}

class DiscoveredWidget {
  final String className;
  final String relativePath;
  final String feature;

  DiscoveredWidget({
    required this.className,
    required this.relativePath,
    required this.feature,
  });
}

// ─── Discovery ───────────────────────────────────────────────────────────────

List<DiscoveredWidget> _discoverScreens(Directory libDir) {
  final screens = <DiscoveredWidget>[];
  final screensDir = Directory('${libDir.path}/features');
  if (!screensDir.existsSync()) return screens;

  for (final featureDir in screensDir.listSync().whereType<Directory>()) {
    final featureName = featureDir.path.split(Platform.pathSeparator).last;
    final screensPath = '${featureDir.path}${Platform.pathSeparator}presentation${Platform.pathSeparator}screens';
    final dir = Directory(screensPath);
    if (!dir.existsSync()) continue;

    for (final file in dir.listSync().whereType<File>()) {
      if (!file.path.endsWith('_screen.dart')) continue;
      final className = _extractFirstClassName(file);
      if (className == null) continue;
      screens.add(DiscoveredWidget(
        className: className,
        relativePath: _relativePath(file.path, libDir.parent.path),
        feature: featureName,
      ));
    }
  }
  return screens;
}

List<DiscoveredWidget> _discoverCoreWidgets(Directory libDir) {
  final widgets = <DiscoveredWidget>[];
  final widgetsDir = Directory('${libDir.path}/core/widgets');
  if (!widgetsDir.existsSync()) return widgets;

  for (final file in widgetsDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    // Skip barrel files and files with no class
    final basename = file.path.split(Platform.pathSeparator).last;
    if (basename == 'widgets.dart') continue;

    final className = _extractFirstClassName(file);
    if (className == null) continue;
    widgets.add(DiscoveredWidget(
      className: className,
      relativePath: _relativePath(file.path, libDir.parent.path),
      feature: 'core',
    ));
  }
  return widgets;
}

List<DiscoveredWidget> _discoverFeatureWidgets(Directory libDir) {
  final widgets = <DiscoveredWidget>[];
  final featuresDir = Directory('${libDir.path}/features');
  if (!featuresDir.existsSync()) return widgets;

  for (final featureDir in featuresDir.listSync().whereType<Directory>()) {
    final featureName = featureDir.path.split(Platform.pathSeparator).last;
    // Try multiple possible widget paths (cross-platform compatibility)
    final seenClassNames = <String>{};
    for (final widgetsPath in [
      '${featureDir.path}${Platform.pathSeparator}presentation${Platform.pathSeparator}widgets',
      '${featureDir.path}/presentation/widgets',
      '${featureDir.path}${Platform.pathSeparator}widgets',
      '${featureDir.path}/widgets',
    ]) {
      final dir = Directory(widgetsPath);
      if (!dir.existsSync()) continue;

      for (final file in dir.listSync().whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final className = _extractFirstClassName(file);
        if (className == null || seenClassNames.contains(className)) continue;
        seenClassNames.add(className);
        widgets.add(DiscoveredWidget(
          className: className,
          relativePath: _relativePath(file.path, libDir.parent.path),
          feature: featureName,
        ));
      }
    }
  }
  return widgets;
}

// ─── Golden Test Analysis ────────────────────────────────────────────────────

/// Extracts all class names and test name tokens from golden test files.
Set<String> _extractGoldenTestNames(Directory goldenDir) {
  final names = <String>{};
  for (final file in goldenDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('_test.dart')) continue;
    final content = file.readAsStringSync();

    // Extract class names from widget constructors (e.g., const PremiumCard(...))
    final constructorPattern = RegExp(r'const\s+(\w+)\(');
    for (final match in constructorPattern.allMatches(content)) {
      names.add(match.group(1)!);
    }

    // Extract test names (e.g., testWidgets('PremiumCard render time', ...))
    final testPattern = RegExp(r"testWidgets\('([^']+)'");
    for (final match in testPattern.allMatches(content)) {
      // Extract meaningful tokens from test names
      final testLabel = match.group(1)!;
      for (final word in testLabel.split(RegExp(r'[\s–—\-]+'))) {
        if (word.length > 3) {
          names.add(word);
        }
      }
    }

    // Extract golden file names (e.g., matchesGoldenFile('goldens/dark_glass_card.png'))
    final goldenPattern = RegExp(r"matchesGoldenFile\('goldens/([^']+)'");
    for (final match in goldenPattern.allMatches(content)) {
      names.add(match.group(1)!);
    }
  }
  return names;
}

/// Build stub mappings dynamically by scanning golden_*_stubs.dart files.
Map<String, String> _buildStubMappings(Directory goldenDir, Set<String> goldenTests) {
  final mappings = <String, String>{};
  for (final file in goldenDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('_stubs.dart')) continue;
    final content = file.readAsStringSync();
    // Extract class names from stubs (e.g., class GoldenLoginForm extends ...)
    final classPattern = RegExp(r'^\s*class\s+(\w+)', multiLine: true);
    final stubClasses = classPattern.allMatches(content).map((m) => m.group(1)!).toList();

    // Map real screen/widget names to their stub names based on naming conventions
    // e.g., GoldenLoginForm -> LoginScreen, GoldenSplashScreen -> SplashScreen
    for (final stubClass in stubClasses) {
      if (!goldenTests.contains(stubClass)) continue;
      // Remove 'Golden' prefix and try common suffixes
      final base = stubClass.replaceFirst('Golden', '');
      for (final suffix in ['Screen', 'Widget', '']) {
        final realName = '$base$suffix';
        mappings[realName] = stubClass;
      }
    }
  }
  return mappings;
}

bool _isCoveredByGolden(String className, Set<String> goldenTests, Map<String, String> stubMappings) {
  // Direct class name match
  if (goldenTests.contains(className)) return true;

  // Check for stub mappings (dynamically built from stubs files)
  if (stubMappings.containsKey(className)) {
    final stub = stubMappings[className]!;
    if (goldenTests.contains(stub)) return true;
    return goldenTests.any((t) => t.startsWith(stub));
  }

  // Fuzzy match: check if class name appears in any golden test name
  // Only match names with 5+ chars to avoid false positives on short names like 'Card'
  if (className.length < 5) return false;
  return goldenTests.any((t) => t.contains(className));
}

String? _findGoldenFile(String className, Directory goldenDir) {
  // Check for direct golden files referencing this class
  final goldensSubDir = Directory('${goldenDir.path}/goldens');
  if (!goldensSubDir.existsSync()) return null;

  final lower = className.toLowerCase();
  for (final file in goldensSubDir.listSync().whereType<File>()) {
    if (file.path.toLowerCase().contains(lower)) {
      return file.path.split(Platform.pathSeparator).last;
    }
  }
  return null;
}

// ─── Output Formatters ───────────────────────────────────────────────────────

void _printTerminal(
  List<CoverageItem> screens,
  List<CoverageItem> coreWidgets,
  List<CoverageItem> featureWidgets,
  int totalCovered,
  int total,
  List<CoverageItem> uncovered,
) {
  final pct = total > 0 ? (totalCovered / total * 100).round() : 0;
  final bar = _progressBar(totalCovered, total, 30);

  stdout.writeln('');
  stdout.writeln('╔══════════════════════════════════════════════════════════════╗');
  stdout.writeln('║              GOLDEN TEST COVERAGE REPORT                    ║');
  stdout.writeln('╚══════════════════════════════════════════════════════════════╝');
  stdout.writeln('');

  // Screens
  _printSection('📱 Screens', screens);
  stdout.writeln('');

  // Core Widgets
  _printSection('🧩 Core Widgets', coreWidgets);
  stdout.writeln('');

  // Feature Widgets
  _printSection('📦 Feature Widgets', featureWidgets);
  stdout.writeln('');

  // Summary
  stdout.writeln('┌──────────────────────────────────────────────────────────────┐');
  stdout.writeln('│  SUMMARY                                                   │');
  stdout.writeln('├──────────────────────────────────────────────────────────────┤');
  stdout.writeln('│  Coverage: $totalCovered / $total ($pct%)');
  stdout.writeln('│  $bar');
  stdout.writeln('│');
  stdout.writeln('│  Screens:        ${screens.where((i) => i.covered).length}/${screens.length}');
  stdout.writeln('│  Core Widgets:   ${coreWidgets.where((i) => i.covered).length}/${coreWidgets.length}');
  stdout.writeln('│  Feature Widgets: ${featureWidgets.where((i) => i.covered).length}/${featureWidgets.length}');
  stdout.writeln('└──────────────────────────────────────────────────────────────┘');
  stdout.writeln('');

  if (uncovered.isNotEmpty) {
    stdout.writeln('⚠️  UNCOVERED (${uncovered.length}):');
    for (final item in uncovered) {
      stdout.writeln('   ✗ ${item.name.padRight(30)} ${item.filePath}');
    }
    stdout.writeln('');
  }
}

void _printSection(String title, List<CoverageItem> items) {
  stdout.writeln('┌─ $title ──────────────────────────────────────────────────┐');
  for (final item in items) {
    final icon = item.covered ? '✓' : '✗';
    final coverage = item.covered
        ? (item.goldenFile != null ? '(${item.goldenFile})' : '(covered)')
        : '— MISSING';
    stdout.writeln('│  $icon ${item.name.padRight(30)} $coverage');
  }
  stdout.writeln('└${'─' * 60}┘');
}

void _printJson(
  List<CoverageItem> allItems,
  int totalCovered,
  int total,
) {
  final uncovered = allItems.where((i) => !i.covered).toList();
  final pct = total > 0 ? (totalCovered / total * 100).round() : 0;

  stdout.writeln('{');
  stdout.writeln('  "summary": {');
  stdout.writeln('    "total": $total,');
  stdout.writeln('    "covered": $totalCovered,');
  stdout.writeln('    "uncovered": ${uncovered.length},');
  stdout.writeln('    "percentage": $pct');
  stdout.writeln('  },');
  stdout.writeln('  "items": [');

  for (var i = 0; i < allItems.length; i++) {
    final item = allItems[i];
    final comma = i < allItems.length - 1 ? ',' : '';
    stdout.writeln('    {"name": "${item.name}", "category": "${item.category}", "feature": "${item.feature}", "covered": ${item.covered}, "filePath": "${item.filePath}"}$comma');
  }

  stdout.writeln('  ],');
  stdout.writeln('  "uncovered": [');

  for (var i = 0; i < uncovered.length; i++) {
    final item = uncovered[i];
    final comma = i < uncovered.length - 1 ? ',' : '';
    stdout.writeln('    {"name": "${item.name}", "category": "${item.category}", "feature": "${item.feature}", "filePath": "${item.filePath}"}$comma');
  }

  stdout.writeln('  ]');
  stdout.writeln('}');
}

void _printMarkdown(
  List<CoverageItem> screens,
  List<CoverageItem> coreWidgets,
  List<CoverageItem> featureWidgets,
  int totalCovered,
  int total,
) {
  final pct = total > 0 ? (totalCovered / total * 100).round() : 0;
  final uncovered = [...screens, ...coreWidgets, ...featureWidgets]
      .where((i) => !i.covered)
      .toList();

  stdout.writeln('# Golden Test Coverage Report');
  stdout.writeln('');
  stdout.writeln('**Coverage: $totalCovered / $total ($pct%)**');
  stdout.writeln('');

  // Summary table
  stdout.writeln('| Category | Covered | Total | Percentage |');
  stdout.writeln('|----------|---------|-------|------------|');
  stdout.writeln('| Screens | ${screens.where((i) => i.covered).length} | ${screens.length} | ${screens.isNotEmpty ? (screens.where((i) => i.covered).length / screens.length * 100).round() : 0}% |');
  stdout.writeln('| Core Widgets | ${coreWidgets.where((i) => i.covered).length} | ${coreWidgets.length} | ${coreWidgets.isNotEmpty ? (coreWidgets.where((i) => i.covered).length / coreWidgets.length * 100).round() : 0}% |');
  stdout.writeln('| Feature Widgets | ${featureWidgets.where((i) => i.covered).length} | ${featureWidgets.length} | ${featureWidgets.isNotEmpty ? (featureWidgets.where((i) => i.covered).length / featureWidgets.length * 100).round() : 0}% |');
  stdout.writeln('');

  // Detailed tables
  _printMarkdownSection('Screens', screens);
  _printMarkdownSection('Core Widgets', coreWidgets);
  _printMarkdownSection('Feature Widgets', featureWidgets);

  if (uncovered.isNotEmpty) {
    stdout.writeln('## ⚠️ Uncovered Items');
    stdout.writeln('');
    stdout.writeln('| Name | Category | Feature | File |');
    stdout.writeln('|------|----------|---------|------|');
    for (final item in uncovered) {
      stdout.writeln('| ${item.name} | ${item.category} | ${item.feature} | `${item.filePath}` |');
    }
    stdout.writeln('');
  }
}

void _printMarkdownSection(String title, List<CoverageItem> items) {
  stdout.writeln('## $title');
  stdout.writeln('');
  stdout.writeln('| Widget | Feature | Covered | Golden File |');
  stdout.writeln('|--------|---------|---------|-------------|');
  for (final item in items) {
    final covered = item.covered ? '✅' : '❌';
    final golden = item.goldenFile ?? '—';
    stdout.writeln('| ${item.name} | ${item.feature} | $covered | $golden |');
  }
  stdout.writeln('');
}

// ─── Utilities ───────────────────────────────────────────────────────────────

String _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      stderr.writeln('Error: Could not find project root (no pubspec.yaml found)');
      exit(1);
    }
    dir = parent;
  }
}

String? _extractFirstClassName(File file) {
  final content = file.readAsStringSync();
  // Match: class ClassName extends/with/implements ...
  final pattern = RegExp(r'^\s*class\s+(\w+)', multiLine: true);
  final match = pattern.firstMatch(content);
  return match?.group(1);
}

String _relativePath(String absolutePath, String projectRoot) {
  if (absolutePath.startsWith(projectRoot)) {
    return absolutePath.substring(projectRoot.length + 1).replaceAll('\\', '/');
  }
  return absolutePath.replaceAll('\\', '/');
}

String _progressBar(int current, int total, int width) {
  final filled = total > 0 ? (current / total * width).round() : 0;
  final empty = width - filled;
  return '[${'█' * filled}${'░' * empty}]';
}
