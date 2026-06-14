import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/widgets/journal_entry_type.dart';

// ═══════════════════════════════════════════════
//  Test helpers — replicate private logic so we
//  can verify the formulas in isolation.
// ═══════════════════════════════════════════════

/// Mirrors `_DashboardScreenState._xpProgress` exactly.
double xpProgress(Map<String, dynamic>? evolution) {
  if (evolution == null) return 0.0;
  final progress = evolution['xpProgress'];
  if (progress != null) return (progress as num).toDouble() / 100.0;
  final xp = (parseDouble(evolution['currentXp']) ?? 0.0);
  final needed = parseDouble(evolution['xpForNextLevel']) ?? 50;
  return needed > 0 ? (xp / needed).clamp(0.0, 1.0) : 0.0;
}

/// Mirrors `_DashboardScreenState._currentLevel` exactly.
int currentLevel(Map<String, dynamic>? evolution) =>
    parseInt(evolution?['currentLevel']) ?? 1;

/// Mirrors `_DashboardScreenState._xpForNextLevel` exactly.
int xpForNextLevel(Map<String, dynamic>? evolution) {
  final numVal = parseDouble(evolution?['xpForNextLevel']);
  if (numVal != null && numVal > 0) return numVal.round();
  return 50;
}

/// Mirrors `DataScreenMixin.loadData` cooldown check exactly.
bool shouldRefresh({
  bool force = false,
  Duration? refreshCooldown,
  DateTime? lastDataRefresh,
  String? babyMonId,
}) {
  if (!force &&
      refreshCooldown != null &&
      lastDataRefresh != null &&
      babyMonId != null) {
    final elapsed = DateTime.now().difference(lastDataRefresh);
    if (elapsed < refreshCooldown) return false;
  }
  return true;
}

/// Mirrors `JournalScreen._groupEntriesByDate` exactly.
List<MapEntry<String, List<Map<String, dynamic>>>> groupEntriesByDate(
  List entries,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final weekStart = today.subtract(Duration(days: now.weekday - 1));

  final groups = <String, List<Map<String, dynamic>>>{
    'TODAY': [],
    'YESTERDAY': [],
    'THIS WEEK': [],
  };
  final monthlyGroups = <String, List<Map<String, dynamic>>>{};

  for (final raw in entries) {
    final entry = parseJsonMap(raw) ?? <String, dynamic>{};
    final dateStr = entry['happenedAt'] ?? entry['createdAt'];
    if (dateStr == null) continue;
    final date = DateTime.tryParse(dateStr.toString())?.toLocal();
    if (date == null) continue;
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) {
      groups['TODAY']!.add(entry);
    } else if (d == yesterday) {
      groups['YESTERDAY']!.add(entry);
    } else if (d.isAfter(weekStart) && d.isBefore(today)) {
      groups['THIS WEEK']!.add(entry);
    } else {
      final key = DateFormat('MMMM yyyy').format(d).toUpperCase();
      monthlyGroups.putIfAbsent(key, () => []).add(entry);
    }
  }

  final ordered = <MapEntry<String, List<Map<String, dynamic>>>>[];
  for (final key in ['TODAY', 'YESTERDAY', 'THIS WEEK']) {
    final items = groups[key]!;
    if (items.isNotEmpty) {
      items.sort(
        (a, b) => _entryDate(b).compareTo(_entryDate(a)),
      );
      ordered.add(MapEntry(key, items));
    }
  }
  final monthKeys = monthlyGroups.keys.toList()
    ..sort((a, b) => b.compareTo(a));
  for (final key in monthKeys) {
    final items = monthlyGroups[key]!;
    items.sort(
      (a, b) => _entryDate(b).compareTo(_entryDate(a)),
    );
    ordered.add(MapEntry(key, items));
  }
  return ordered;
}

DateTime _entryDate(Map<String, dynamic> entry) {
  final dateStr = entry['happenedAt'] ?? entry['createdAt'];
  return (DateTime.tryParse(dateStr?.toString() ?? '') ?? DateTime.now())
      .toLocal();
}

/// Helper: generate an ISO-8601 UTC string for [localDate] at noon,
/// so it round-trips through UTC→local to the same calendar day
/// regardless of timezone.
String _dateToIso(DateTime localDate) =>
    localDate.add(const Duration(hours: 12)).toUtc().toIso8601String();

// ═══════════════════════════════════════════════
//  Tests
// ═══════════════════════════════════════════════

void main() {
  // ── extractErrorMessage ──
  group('extractErrorMessage', () {
    test('returns server message from DioException response body', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/test'),
          statusCode: 400,
          data: {'message': 'Email already registered'},
        ),
        type: DioExceptionType.badResponse,
      );
      expect(extractErrorMessage(dioError), 'Email already registered');
    });

    test('returns timeout message for connection timeout', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        extractErrorMessage(dioError),
        'Connection timed out. Please check your internet and try again.',
      );
    });

    test('returns correct message for each HTTP status code', () {
      final cases = {
        400: 'Invalid request. Please check your input.',
        401: 'Session expired. Please log in again.',
        403: "You don't have permission to do that.",
        404: 'Not found. The feature may not be available yet.',
        409: 'This already exists. Please use a different value.',
        429: 'Too many requests. Please wait a moment and try again.',
        500: 'Server error. Please try again later.',
        502: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
      };
      for (final entry in cases.entries) {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: entry.key,
          ),
          type: DioExceptionType.badResponse,
        );
        expect(
          extractErrorMessage(dioError),
          entry.value,
          reason: 'Status ${entry.key}',
        );
      }
    });

    test('returns fallback for non-DioException errors', () {
      expect(extractErrorMessage(Exception('something broke')),
          'Something went wrong. Please try again.');
      expect(extractErrorMessage('raw string error'),
          'Something went wrong. Please try again.');
      expect(extractErrorMessage(42), 'Something went wrong. Please try again.');
    });
  });

  // ── XP calculation ──
  group('XP calculation', () {
    test('returns 0.0 for null evolution', () {
      expect(xpProgress(null), 0.0);
    });

    test('uses backend xpProgress when available', () {
      expect(xpProgress({'xpProgress': 75}), 0.75);
      expect(xpProgress({'xpProgress': 0}), 0.0);
      expect(xpProgress({'xpProgress': 100}), 1.0);
    });

    test('computes locally when xpProgress is absent', () {
      expect(xpProgress({'currentXp': 0, 'xpForNextLevel': 50}), 0.0);
      expect(xpProgress({'currentXp': 25, 'xpForNextLevel': 50}), 0.5);
      expect(xpProgress({'currentXp': 50, 'xpForNextLevel': 50}), 1.0);
      // Over-max is clamped to 1.0
      expect(xpProgress({'currentXp': 100, 'xpForNextLevel': 50}), 1.0);
    });

    test('falls back to 50 XP needed when xpForNextLevel is missing', () {
      expect(xpProgress({'currentXp': 25}), 0.5);
    });

    test('currentLevel defaults to 1 when absent', () {
      expect(currentLevel(null), 1);
      expect(currentLevel({}), 1);
      expect(currentLevel({'currentLevel': 5}), 5);
    });

    test('xpForNextLevel falls back to 50 for legacy/missing data', () {
      expect(xpForNextLevel(null), 50);
      expect(xpForNextLevel({}), 50);
      expect(xpForNextLevel({'xpForNextLevel': 100}), 100);
      expect(xpForNextLevel({'xpForNextLevel': -10}), 50);
      expect(xpForNextLevel({'xpForNextLevel': 0}), 50);
    });
  });

  // ── DataScreenMixin cooldown ──
  group('DataScreenMixin cooldown', () {
    test('force=true always refreshes regardless of cooldown', () {
      expect(
        shouldRefresh(
          force: true,
          refreshCooldown: const Duration(seconds: 10),
          lastDataRefresh: DateTime.now(),
          babyMonId: 'test-id',
        ),
        true,
      );
    });

    test('skips refresh when within cooldown window', () {
      expect(
        shouldRefresh(
          refreshCooldown: const Duration(seconds: 10),
          lastDataRefresh: DateTime.now().subtract(const Duration(seconds: 3)),
          babyMonId: 'test-id',
        ),
        false,
      );
    });

    test('allows refresh when cooldown has elapsed', () {
      expect(
        shouldRefresh(
          refreshCooldown: const Duration(seconds: 10),
          lastDataRefresh: DateTime.now().subtract(const Duration(seconds: 15)),
          babyMonId: 'test-id',
        ),
        true,
      );
    });

    test('allows refresh when no cooldown is configured', () {
      expect(
        shouldRefresh(
          refreshCooldown: null,
          lastDataRefresh: DateTime.now(),
          babyMonId: 'test-id',
        ),
        true,
      );
    });

    test('allows refresh when babyMonId is null (first load)', () {
      expect(
        shouldRefresh(
          refreshCooldown: const Duration(seconds: 10),
          lastDataRefresh: DateTime.now(),
          babyMonId: null,
        ),
        true,
      );
    });
  });

  // ── Journal date grouping ──
  // Uses relative DateTime.now() so tests are timezone-independent.
  group('Journal date grouping', () {
    late DateTime now;
    late DateTime today;

    setUp(() {
      now = DateTime.now();
      today = DateTime(now.year, now.month, now.day);
    });

    test('today entries land in TODAY group', () {
      final entries = [
        {'id': 'a', 'happenedAt': _dateToIso(today)},
        {'id': 'b', 'happenedAt': _dateToIso(today)},
      ];
      final groups = groupEntriesByDate(entries, now);

      expect(groups.length, 1);
      expect(groups[0].key, 'TODAY');
      expect(groups[0].value.length, 2);
    });

    test('yesterday entries land in YESTERDAY group', () {
      final yesterday = today.subtract(const Duration(days: 1));
      final entries = [
        {'id': 'a', 'happenedAt': _dateToIso(yesterday)},
      ];
      final groups = groupEntriesByDate(entries, now);

      expect(groups.length, 1);
      expect(groups[0].key, 'YESTERDAY');
      expect(groups[0].value[0]['id'], 'a');
    });

    test('entries 30+ days ago land in a monthly group', () {
      final oldDate = today.subtract(const Duration(days: 30));
      final entries = [
        {'id': 'a', 'happenedAt': _dateToIso(oldDate)},
      ];
      final groups = groupEntriesByDate(entries, now);

      expect(groups.length, 1);
      expect(groups[0].key, isNot('TODAY'));
      expect(groups[0].key, isNot('YESTERDAY'));
      expect(groups[0].key, isNot('THIS WEEK'));
      // Should be a monthly label like "MAY 2026"
      expect(groups[0].key, matches(RegExp(r'^[A-Z]+ \d{4}$')));
    });

    test('entries without happenedAt/createdAt are skipped', () {
      final entries = [
        {'id': 'no-date', 'entryType': 'MILESTONE'},
        {'id': 'has-date', 'happenedAt': _dateToIso(today)},
      ];
      final groups = groupEntriesByDate(entries, now);

      expect(groups.length, 1);
      expect(groups[0].value.length, 1);
      expect(groups[0].value[0]['id'], 'has-date');
    });

    test('multiple entries in same group are sorted newest-first', () {
      final entries = [
        {'id': 'old', 'happenedAt': _dateToIso(today.subtract(const Duration(hours: 4)))},
        {'id': 'new', 'happenedAt': _dateToIso(today)},
      ];
      final groups = groupEntriesByDate(entries, now);

      expect(groups.length, 1);
      expect(groups[0].value[0]['id'], 'new');
      expect(groups[0].value[1]['id'], 'old');
    });
  });

  // ── JournalEntryType parsing ──
  group('JournalEntryType', () {
    test('fromString parses all known types', () {
      expect(
          JournalEntryType.fromString('MILESTONE'), JournalEntryType.milestone);
      expect(
          JournalEntryType.fromString('FEED_LOG'), JournalEntryType.feedLog);
      expect(JournalEntryType.fromString('HEALTH_RECORD'),
          JournalEntryType.healthRecord);
      expect(JournalEntryType.fromString('SYSTEM'), JournalEntryType.system);
    });

    test('fromString falls back to system for unknown strings', () {
      expect(JournalEntryType.fromString('UNKNOWN'), JournalEntryType.system);
      expect(JournalEntryType.fromString(''), JournalEntryType.system);
      expect(JournalEntryType.fromString(null), JournalEntryType.system);
    });

    test('apiKey round-trips correctly for all types', () {
      for (final type in JournalEntryType.values) {
        final parsed = JournalEntryType.fromString(type.apiKey);
        expect(parsed, type, reason: 'Round-trip failed for ${type.name}');
      }
    });
  });
}
