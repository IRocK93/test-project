import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/features/auth/domain/entities/user.dart';

void main() {
  group('User', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'user-123',
          'email': 'test@example.com',
          'name': 'Test User',
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.id, 'user-123');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.createdAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
      });

      test('handles missing name gracefully', () {
        final json = {
          'id': 'u1',
          'email': 'a@b.com',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.name, isNull);
      });

      test('handles missing id by defaulting to empty string', () {
        final json = {
          'email': 'a@b.com',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.id, '');
      });

      test('handles missing email by defaulting to empty string', () {
        final json = {
          'id': 'u1',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.email, '');
      });

      test('handles missing createdAt by defaulting to now', () {
        final before = DateTime.now();
        final json = {
          'id': 'u1',
          'email': 'a@b.com',
        };

        final user = User.fromJson(json);
        final after = DateTime.now();

        expect(user.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(user.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('handles empty map', () {
        final user = User.fromJson({});

        expect(user.id, '');
        expect(user.email, '');
        expect(user.name, isNull);
        expect(user.createdAt, isNotNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final user = User(
          id: 'u1',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime(2024, 6, 15, 10, 30),
        );

        final json = user.toJson();

        expect(json['id'], 'u1');
        expect(json['email'], 'test@example.com');
        expect(json['name'], 'Test User');
        expect(json['createdAt'], '2024-06-15T10:30:00.000');
      });

      test('serializes null name as null in JSON', () {
        final user = User(
          id: 'u1',
          email: 'a@b.com',
          createdAt: DateTime(2024),
        );

        final json = user.toJson();

        expect(json['name'], isNull);
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = User(
          id: 'round-trip',
          email: 'round@trip.com',
          name: 'Round Trip',
          createdAt: DateTime(2024, 3, 15, 8, 0),
        );

        final restored = User.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.email, original.email);
        expect(restored.name, original.name);
        // DateTime serialization may lose microseconds
        expect(restored.createdAt, original.createdAt);
      });
    });
  });
}
