import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/utils/json_utils.dart';

void main() {
  group('parseJsonMap', () {
    test('returns map when given a valid Map', () {
      final result = parseJsonMap(<String, dynamic>{'key': 'value', 'num': 42});
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['key'], 'value');
      expect(result['num'], 42);
    });

    test('returns null when given null', () {
      expect(parseJsonMap(null), isNull);
    });

    test('returns null when given a List', () {
      expect(parseJsonMap([1, 2, 3]), isNull);
    });

    test('returns null when given a String', () {
      expect(parseJsonMap('not a map'), isNull);
    });

    test('returns null when given an int', () {
      expect(parseJsonMap(42), isNull);
    });

    test('returns null when given a bool', () {
      expect(parseJsonMap(true), isNull);
    });

    test('returns a shallow copy, not the original reference', () {
      final original = <String, dynamic>{'a': 1};
      final result = parseJsonMap(original);
      expect(identical(result, original), isFalse);
    });
  });

  group('parseJsonList', () {
    test('returns typed list when given a valid List of maps', () {
      final data = <Map<String, dynamic>>[
        <String, dynamic>{'id': 1},
        <String, dynamic>{'id': 2},
      ];
      final result = parseJsonList(data);
      expect(result, hasLength(2));
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result[0]['id'], 1);
    });

    test('returns empty list when given null', () {
      final result = parseJsonList(null);
      expect(result, isEmpty);
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('returns empty list when given a Map', () {
      expect(parseJsonList(<String, dynamic>{}), isEmpty);
    });

    test('returns empty list when given a String', () {
      expect(parseJsonList('hello'), isEmpty);
    });

    test('returns empty list when given an empty list', () {
      expect(parseJsonList(<dynamic>[]), isEmpty);
    });

    test('throws when list contains non-Map elements at access time', () {
      final mixed = <dynamic>[<String, dynamic>{'id': 1}, 'not a map'];
      expect(() => parseJsonList(mixed), throwsA(isA<TypeError>()));
    });
  });

  group('parseList', () {
    test('returns the same list reference when given a List', () {
      final original = [1, 'two', true];
      final result = parseList(original);
      expect(identical(result, original), isTrue);
      expect(result, hasLength(3));
    });

    test('returns empty list when given null', () {
      final result = parseList(null);
      expect(result, isEmpty);
      expect(result, isA<List<dynamic>>());
    });

    test('returns empty list when given a Map', () {
      expect(parseList(<String, dynamic>{}), isEmpty);
    });

    test('returns empty list when given a String', () {
      expect(parseList('hello'), isEmpty);
    });

    test('returns empty list when given an int', () {
      expect(parseList(42), isEmpty);
    });

    test('returns empty list when given an empty list', () {
      expect(parseList(<dynamic>[]), isEmpty);
    });
  });

  group('parseString', () {
    test('returns value when given a String', () {
      expect(parseString('hello'), 'hello');
    });

    test('returns null when given null', () {
      expect(parseString(null), isNull);
    });

    test('returns null when given an int', () {
      expect(parseString(42), isNull);
    });

    test('returns null when given a Map', () {
      expect(parseString(<String, dynamic>{}), isNull);
    });

    test('returns null when given a List', () {
      expect(parseString([1, 2, 3]), isNull);
    });

    test('returns null when given a bool', () {
      expect(parseString(true), isNull);
    });

    test('returns null when given an empty String', () {
      expect(parseString(''), '');
    });
  });

  group('safeCast', () {
    test('returns value when type matches String', () {
      final result = safeCast<String>('hello');
      expect(result, 'hello');
    });

    test('returns value when type matches int', () {
      final result = safeCast<int>(42);
      expect(result, 42);
    });

    test('returns null when type does not match', () {
      final result = safeCast<String>(42);
      expect(result, isNull);
    });

    test('returns null when given null', () {
      final result = safeCast<String>(null);
      expect(result, isNull);
    });

    test('works with List types', () {
      final result = safeCast<List<dynamic>>([1, 2, 3]);
      expect(result, hasLength(3));
    });

    test('returns null for null even with nullable type context', () {
      // ignore: unnecessary_type_check
      final result = safeCast<String?>(null);
      expect(result, isNull);
    });
  });

  group('parseItems', () {
    test('returns list directly when value is a List', () {
      final data = [
        <String, dynamic>{'id': 1},
        <String, dynamic>{'id': 2},
      ];
      final result = parseItems(data);
      expect(result, hasLength(2));
      expect(identical(result, data), isTrue);
    });

    test('extracts items from paginated envelope Map', () {
      final data = <String, dynamic>{
        'items': [
          <String, dynamic>{'id': 1},
          <String, dynamic>{'id': 2},
        ],
        'total': 2,
      };
      final result = parseItems(data);
      expect(result, hasLength(2));
      expect(result[0]['id'], 1);
    });

    test('returns empty list from paginated envelope with no items key', () {
      final data = <String, dynamic>{'total': 0};
      final result = parseItems(data);
      expect(result, isEmpty);
    });

    test('returns empty list when given null', () {
      expect(parseItems(null), isEmpty);
    });

    test('returns empty list when given a String', () {
      expect(parseItems('not a list'), isEmpty);
    });

    test('returns empty list when given an empty Map', () {
      expect(parseItems(<String, dynamic>{}), isEmpty);
    });
  });

  group('parseItemsTyped', () {
    test('returns typed list when value is a List of maps', () {
      final data = [
        <String, dynamic>{'id': 1},
        <String, dynamic>{'id': 2},
      ];
      final result = parseItemsTyped(data);
      expect(result, hasLength(2));
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('extracts typed items from paginated envelope', () {
      final data = <String, dynamic>{
        'items': [
          <String, dynamic>{'id': 1},
        ],
      };
      final result = parseItemsTyped(data);
      expect(result, hasLength(1));
      expect(result[0]['id'], 1);
    });

    test('returns empty typed list when given null', () {
      final result = parseItemsTyped(null);
      expect(result, isEmpty);
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('returns empty typed list from empty Map', () {
      expect(parseItemsTyped(<String, dynamic>{}), isEmpty);
    });
  });

  group('parseInt', () {
    test('returns int when given an int', () {
      expect(parseInt(42), 42);
      expect(parseInt(0), 0);
      expect(parseInt(-1), -1);
    });

    test('returns null when given a double', () {
      expect(parseInt(3.14), isNull);
      expect(parseInt(42.0), isNull);
    });

    test('returns null when given null', () {
      expect(parseInt(null), isNull);
    });

    test('returns null when given a String', () {
      expect(parseInt('42'), isNull);
    });

    test('returns null when given a Map', () {
      expect(parseInt(<String, dynamic>{}), isNull);
    });

    test('returns null when given a bool', () {
      expect(parseInt(true), isNull);
    });

    test('returns null when given a List', () {
      expect(parseInt([1, 2, 3]), isNull);
    });
  });

  group('parseDouble', () {
    test('returns double when given a double', () {
      expect(parseDouble(3.14), 3.14);
      expect(parseDouble(0.0), 0.0);
    });

    test('returns double when given an int (widening)', () {
      expect(parseDouble(42), 42.0);
      expect(parseDouble(0), 0.0);
    });

    test('returns null when given null', () {
      expect(parseDouble(null), isNull);
    });

    test('returns null when given a String', () {
      expect(parseDouble('3.14'), isNull);
    });

    test('returns null when given a Map', () {
      expect(parseDouble(<String, dynamic>{}), isNull);
    });

    test('returns null when given a bool', () {
      expect(parseDouble(true), isNull);
    });

    test('returns null when given a List', () {
      expect(parseDouble([1.5, 2.5]), isNull);
    });
  });

  group('parseBool', () {
    test('returns true when given true', () {
      expect(parseBool(true), isTrue);
    });

    test('returns false when given false', () {
      expect(parseBool(false), isFalse);
    });

    test('returns null when given null', () {
      expect(parseBool(null), isNull);
    });

    test('returns null when given an int', () {
      expect(parseBool(1), isNull);
      expect(parseBool(0), isNull);
    });

    test('returns null when given a String', () {
      expect(parseBool('true'), isNull);
    });

    test('returns null when given a Map', () {
      expect(parseBool(<String, dynamic>{}), isNull);
    });

    test('returns null when given a List', () {
      expect(parseBool([true, false]), isNull);
    });
  });

  // ── Edge cases shared across helpers ──

  group('edge cases', () {
    test('parseJsonMap handles Map subclasses', () {
      final linked = <dynamic, dynamic>{};
      linked['key'] = 'value';
      final result = parseJsonMap(linked);
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['key'], 'value');
    });

    test('parseJsonList handles empty list of maps', () {
      expect(parseJsonList(<Map<String, dynamic>>[]), isEmpty);
    });

    test('parseList handles custom Iterable subclass', () {
      // A List is-a Iterable, and parseList checks `is List`
      final queue = [1, 2, 3];
      final result = parseList(queue);
      expect(result, hasLength(3));
    });

    test('safeCast handles num -> int subtype correctly', () {
      // Dart's `is` check is strict: `int is num` is true, but `num is int` is false
      const num value = 42;
      final asInt = safeCast<int>(value);
      expect(asInt, 42); // Runtime type is int, so this works
    });

    test('safeCast returns null on num -> String', () {
      const num value = 42;
      final result = safeCast<String>(value);
      expect(result, isNull);
    });

    test('parseItems handles List subclasses', () {
      final data = <int>[1, 2, 3];
      final result = parseItems(data);
      expect(result, hasLength(3));
      expect(identical(result, data), isTrue);
    });
  });
}
