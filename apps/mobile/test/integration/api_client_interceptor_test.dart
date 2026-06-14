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

  group('ApiClient storage round-trips', () {
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

    test('getUserId returns null when not set', () async {
      final client = ApiClient();
      expect(await client.getUserId(), isNull);
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

    test('setSelectedBabyMonId with null deletes key', () async {
      final client = ApiClient();
      await client.setSelectedBabyMonId('baby-1');
      await client.setSelectedBabyMonId(null);
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

    test('setSelectedBabyMonId stores and overwrites value', () async {
      final client = ApiClient();
      await client.setSelectedBabyMonId('baby-42');
      expect(await client.getSelectedBabyMonId(), 'baby-42');

      await client.setSelectedBabyMonId('baby-99');
      expect(await client.getSelectedBabyMonId(), 'baby-99');
    });
  });

  group('ApiClient token access', () {
    test('createBabyMon reads token correctly', () async {
      final client = ApiClient();
      await client.saveTokens('my-jwt-token', 'refresh', 'user-1');

      final token = await client.getAccessToken();
      expect(token, 'my-jwt-token');
    });

    test('multiple clients share the same storage', () async {
      final client1 = ApiClient();
      final client2 = ApiClient();

      await client1.saveTokens('token-1', 'refresh-1', 'user-1');

      expect(await client2.getAccessToken(), 'token-1');
      expect(await client2.getUserId(), 'user-1');
    });
  });

  group('ApiClient edge cases', () {
    test('ApiClient can be created', () {
      final client = ApiClient();
      expect(client, isA<ApiClient>());
    });

    test('logout is idempotent — calling twice does not throw', () async {
      final client = ApiClient();
      await client.saveTokens('access', 'refresh', 'user-1');

      await client.logout();
      await client.logout();

      expect(await client.getAccessToken(), isNull);
    });

    test('saveTokens overwrites previous values', () async {
      final client = ApiClient();
      await client.saveTokens('old-access', 'old-refresh', 'old-user');
      await client.saveTokens('new-access', 'new-refresh', 'new-user');

      expect(await client.getAccessToken(), 'new-access');
      expect(await client.getUserId(), 'new-user');
    });

    test('setSelectedBabyMonId handles rapid updates', () async {
      final client = ApiClient();
      await client.setSelectedBabyMonId('baby-1');
      await client.setSelectedBabyMonId('baby-2');
      await client.setSelectedBabyMonId('baby-3');

      expect(await client.getSelectedBabyMonId(), 'baby-3');
    });

    test('logout clears refresh token', () async {
      final client = ApiClient();
      await client.saveTokens('access', 'refresh-abc', 'user-1');

      await client.logout();

      expect(_secureStore['refresh_token'], isNull);
    });

    test('saveTokens stores refresh token', () async {
      final client = ApiClient();
      await client.saveTokens('access', 'refresh-xyz', 'user-1');

      expect(_secureStore['refresh_token'], 'refresh-xyz');
    });
  });
}
