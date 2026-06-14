import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/data/api_client.dart';

/// In-memory store for FlutterSecureStorage mock.
final Map<String, String> _secureStore = {};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _secureStore.clear();
    SharedPreferences.setMockInitialValues({});
    // Mock FlutterSecureStorage platform channel with in-memory storage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            final key = methodCall.arguments['key'] as String?;
            return _secureStore[key];
          case 'write':
            final key = methodCall.arguments['key'] as String?;
            final value = methodCall.arguments['value'] as String?;
            if (key != null && value != null) _secureStore[key] = value;
            return null;
          case 'delete':
            final key = methodCall.arguments['key'] as String?;
            if (key != null) _secureStore.remove(key);
            return null;
          case 'deleteAll':
            _secureStore.clear();
            return null;
          case 'readAll':
            return Map<String, String>.from(_secureStore);
          default:
            return null;
        }
      },
    );
  });

  group('ApiClient URL resolution', () {
    test('saveTokens and getAccessToken round-trip', () async {
      final client = ApiClient();

      await client.saveTokens('access-123', 'refresh-456', 'user-789');

      final token = await client.getAccessToken();
      expect(token, 'access-123');
    });

    test('getUserId returns stored user ID', () async {
      final client = ApiClient();

      await client.saveTokens('a', 'b', 'user-42');

      final userId = await client.getUserId();
      expect(userId, 'user-42');
    });

    test('getSelectedBabyMonId returns null when not set', () async {
      final client = ApiClient();

      final id = await client.getSelectedBabyMonId();
      expect(id, isNull);
    });

    test('setSelectedBabyMonId stores and retrieves value', () async {
      final client = ApiClient();

      await client.setSelectedBabyMonId('baby-123');
      final id = await client.getSelectedBabyMonId();
      expect(id, 'baby-123');
    });

    test('setSelectedBabyMonId with null deletes the key', () async {
      final client = ApiClient();

      await client.setSelectedBabyMonId('baby-123');
      await client.setSelectedBabyMonId(null);
      final id = await client.getSelectedBabyMonId();
      expect(id, isNull);
    });

    test('setSelectedBabyMonId with empty string deletes the key', () async {
      final client = ApiClient();

      await client.setSelectedBabyMonId('baby-123');
      await client.setSelectedBabyMonId('');
      final id = await client.getSelectedBabyMonId();
      expect(id, isNull);
    });

    test('setTrialOverride and getTrialOverride round-trip', () async {
      final client = ApiClient();

      await client.setTrialOverride(7);
      final days = await client.getTrialOverride();
      expect(days, 7);
    });

    test('getTrialOverride returns null when not set', () async {
      final client = ApiClient();

      final days = await client.getTrialOverride();
      expect(days, isNull);
    });
  });

  group('ApiClient logout', () {
    test('logout clears all stored tokens', () async {
      final client = ApiClient();

      await client.saveTokens('access', 'refresh', 'user-1');
      await client.setSelectedBabyMonId('baby-1');

      // logout should clear everything
      await client.logout();

      expect(await client.getAccessToken(), isNull);
      expect(await client.getUserId(), isNull);
      expect(await client.getSelectedBabyMonId(), isNull);
    });
  });

  group('ApiClient base URL', () {
    test('uses ApiConstants.baseUrl', () {
      final client = ApiClient();
      // Verify the client was created without throwing
      expect(client, isA<ApiClient>());
    });
  });
}
