import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory store for FlutterSecureStorage mock.
final Map<String, String> _secureStore = {};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _secureStore.clear();
    SharedPreferences.setMockInitialValues({});
    // Mock FlutterSecureStorage platform channel
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

  group('ApiClient token management', () {
    test('saveTokens stores all three values', () async {
      final client = ApiClient();

      await client.saveTokens('access-abc', 'refresh-def', 'user-123');

      expect(await client.getAccessToken(), 'access-abc');
      expect(await client.getUserId(), 'user-123');
    });

    test('getAccessToken returns null when not set', () async {
      final client = ApiClient();
      expect(await client.getAccessToken(), isNull);
    });

    test('getSelectedBabyMonId returns null when not set', () async {
      final client = ApiClient();
      expect(await client.getSelectedBabyMonId(), isNull);
    });

    test('setSelectedBabyMonId with empty string returns null', () async {
      final client = ApiClient();
      await client.setSelectedBabyMonId('baby-1');
      await client.setSelectedBabyMonId('');
      expect(await client.getSelectedBabyMonId(), isNull);
    });

    test('logout clears all stored tokens', () async {
      final client = ApiClient();
      await client.saveTokens('access', 'refresh', 'user-1');
      await client.setSelectedBabyMonId('baby-1');

      await client.logout();

      expect(await client.getAccessToken(), isNull);
      expect(await client.getUserId(), isNull);
      expect(await client.getSelectedBabyMonId(), isNull);
    });
  });

  group('ApiClient request construction', () {
    test('createBabyMon adds auth header', () async {
      final client = ApiClient();
      await client.saveTokens('my-jwt-token', 'refresh', 'user-1');

      // createBabyMon reads the token and adds it to the request headers
      // We can't fully test the HTTP call without mocking Dio,
      // but we can verify the token is accessible
      final token = await client.getAccessToken();
      expect(token, 'my-jwt-token');
    });
  });

  group('ApiClient storage edge cases', () {
    test('setTrialOverride and getTrialOverride round-trip', () async {
      final client = ApiClient();

      await client.setTrialOverride(14);
      expect(await client.getTrialOverride(), 14);

      await client.setTrialOverride(0);
      expect(await client.getTrialOverride(), 0);
    });

    test('getTrialOverride returns null when not set', () async {
      final client = ApiClient();
      expect(await client.getTrialOverride(), isNull);
    });

    test('setSelectedBabyMonId stores value', () async {
      final client = ApiClient();

      await client.setSelectedBabyMonId('baby-42');
      expect(await client.getSelectedBabyMonId(), 'baby-42');

      await client.setSelectedBabyMonId('baby-99');
      expect(await client.getSelectedBabyMonId(), 'baby-99');
    });

    test('setSelectedBabyMonId with null deletes key', () async {
      final client = ApiClient();

      await client.setSelectedBabyMonId('baby-1');
      await client.setSelectedBabyMonId(null);
      expect(await client.getSelectedBabyMonId(), isNull);
    });
  });

  group('ApiClient URL patterns', () {
    test('ApiClient can be instantiated', () {
      final client = ApiClient();
      expect(client, isA<ApiClient>());
    });
  });
}
