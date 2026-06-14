import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/utils/json_utils.dart';

void main() {
  group('parseJsonMap', () {
    test('returns Map<String, dynamic> from a Map', () {
      final result = parseJsonMap({'key': 'value', 'num': 42});
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['key'], 'value');
      expect(result['num'], 42);
    });

    test('converts nested Map types', () {
      final result = parseJsonMap(<String, dynamic>{'nested': <String, dynamic>{'a': 1}});
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['nested'], isA<Map<String, dynamic>>());
    });

    test('returns null for non-Map values', () {
      expect(parseJsonMap(null), isNull);
      expect(parseJsonMap('string'), isNull);
      expect(parseJsonMap(42), isNull);
      expect(parseJsonMap([1, 2, 3]), isNull);
      expect(parseJsonMap(true), isNull);
    });

    test('returns empty map for empty Map', () {
      final result = parseJsonMap({});
      expect(result, isA<Map<String, dynamic>>());
      expect(result, isEmpty);
    });
  });

  group('parseJsonList', () {
    test('returns typed list from a List', () {
      final result = parseJsonList([
        {'id': 1},
        {'id': 2},
      ]);
      expect(result, hasLength(2));
      expect(result[0]['id'], 1);
    });

    test('returns empty list for non-List values', () {
      expect(parseJsonList(null), isEmpty);
      expect(parseJsonList('string'), isEmpty);
      expect(parseJsonList(42), isEmpty);
    });

    test('returns empty list for empty List', () {
      expect(parseJsonList(<dynamic>[]), isEmpty);
    });

    test('non-Map elements throw at creation', () {
      expect(
        () => parseJsonList(<dynamic>[1, 2, 3]),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('parseList', () {
    test('returns the list when input is a List', () {
      final result = parseList([1, 'two', 3.0]);
      expect(result, hasLength(3));
      expect(result[0], 1);
      expect(result[1], 'two');
    });

    test('returns empty list for non-List values', () {
      expect(parseList(null), isEmpty);
      expect(parseList('string'), isEmpty);
      expect(parseList(42), isEmpty);
    });
  });

  group('safeCast', () {
    test('returns value when cast succeeds', () {
      expect(safeCast<String>('hello'), 'hello');
      expect(safeCast<int>(42), 42);
      expect(safeCast<double>(3.14), 3.14);
      expect(safeCast<bool>(true), true);
    });

    test('returns null when cast fails', () {
      expect(safeCast<int>('hello'), isNull);
      expect(safeCast<String>(42), isNull);
      expect(safeCast<double>(true), isNull);
    });

    test('returns null for null input', () {
      expect(safeCast<String>(null), isNull);
    });
  });

  group('parseItems', () {
    test('returns list directly when input is a List', () {
      final result = parseItems([{'id': 1}, {'id': 2}]);
      expect(result, hasLength(2));
    });

    test('extracts items from envelope object', () {
      final result = parseItems({
        'items': [{'id': 1}],
        'total': 1,
      });
      expect(result, hasLength(1));
      expect(result[0]['id'], 1);
    });

    test('returns empty list for non-List non-Map values', () {
      expect(parseItems(null), isEmpty);
      expect(parseItems('string'), isEmpty);
      expect(parseItems(42), isEmpty);
    });

    test('returns empty list when envelope has no items key', () {
      expect(parseItems({'data': 'something'}), isEmpty);
    });

    test('returns empty list when items is null in envelope', () {
      expect(parseItems({'items': null}), isEmpty);
    });
  });

  group('parseString', () {
    test('returns string value', () {
      expect(parseString('hello'), 'hello');
    });

    test('returns empty string', () {
      expect(parseString(''), '');
    });

    test('returns null for non-string values', () {
      expect(parseString(null), isNull);
      expect(parseString(42), isNull);
      expect(parseString(true), isNull);
    });
  });

  group('parseInt', () {
    test('returns int value', () {
      expect(parseInt(42), 42);
      expect(parseInt(0), 0);
      expect(parseInt(-1), -1);
    });

    test('returns null for non-int values', () {
      expect(parseInt(null), isNull);
      expect(parseInt('42'), isNull);
      expect(parseInt(3.14), isNull);
      expect(parseInt(true), isNull);
    });
  });

  group('parseDouble', () {
    test('returns double from double', () {
      expect(parseDouble(3.14), 3.14);
      expect(parseDouble(0.0), 0.0);
    });

    test('widens int to double', () {
      expect(parseDouble(42), 42.0);
      expect(parseDouble(0), 0.0);
    });

    test('returns null for non-numeric values', () {
      expect(parseDouble(null), isNull);
      expect(parseDouble('3.14'), isNull);
      expect(parseDouble(true), isNull);
    });
  });

  group('parseBool', () {
    test('returns bool value', () {
      expect(parseBool(true), isTrue);
      expect(parseBool(false), isFalse);
    });

    test('returns null for non-bool values', () {
      expect(parseBool(null), isNull);
      expect(parseBool(1), isNull);
      expect(parseBool('true'), isNull);
    });
  });

  group('parseItemsTyped', () {
    test('returns typed list from a List', () {
      final result = parseItemsTyped([
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ]);
      expect(result, hasLength(2));
      expect(result[0]['name'], 'Alice');
    });

    test('extracts items from envelope object', () {
      final result = parseItemsTyped({
        'items': [
          {'id': 1},
        ],
      });
      expect(result, hasLength(1));
    });

    test('returns empty list for non-List non-Map values', () {
      expect(parseItemsTyped(null), isEmpty);
      expect(parseItemsTyped('string'), isEmpty);
    });
  });
}
