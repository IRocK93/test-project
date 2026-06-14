import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/data/api_client.dart';

/// In-memory store for FlutterSecureStorage mock.
final Map<String, String> _secureStore = {};

/// A mock [HttpClientAdapter] that returns configurable responses.
class _MockHttpClientAdapter implements HttpClientAdapter {
  int Function(RequestOptions)? statusCodeFor;
  String Function(RequestOptions)? bodyFor;
  final List<RequestOptions> capturedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add(options);
    final statusCode = statusCodeFor?.call(options) ?? 200;
    final body = bodyFor?.call(options) ?? '{"message": "ok"}';
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {'content-type': ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockHttpClientAdapter mockAdapter;
  late ApiClient client;

  setUp(() {
    _secureStore.clear();
    mockAdapter = _MockHttpClientAdapter();
    client = ApiClient(adapter: mockAdapter);
    mockAdapter.statusCodeFor = (_) => 200;
    mockAdapter.bodyFor = (_) => '{"message": "ok"}';

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

  tearDown(() {
    mockAdapter.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  // ── Constructor ──

  group('ApiClient constructor', () {
    test('creates with default adapter when none provided', () {
      expect(ApiClient(), isA<ApiClient>());
    });

    test('creates with injected adapter', () {
      expect(client, isA<ApiClient>());
    });
  });

  // ── 401 interceptor — auth endpoint exclusion ──

  group('401 interceptor — auth endpoint exclusion', () {
    test('login 401 does NOT trigger refresh', () async {
      mockAdapter.statusCodeFor = (o) =>
          o.path.contains('/auth/login') ? 401 : 200;
      mockAdapter.bodyFor = (o) =>
          o.path.contains('/auth/login')
              ? '{"message": "Invalid credentials"}'
              : '{"message": "ok"}';

      try {
        await client.login('test@test.com', 'wrong');
      } catch (_) {}

      expect(
        mockAdapter.capturedRequests.any((r) => r.path.contains('/auth/login')),
        isTrue,
      );
      expect(
        mockAdapter.capturedRequests
            .any((r) => r.path.contains('/auth/refresh')),
        isFalse,
      );
    });

    test('register 401 does NOT trigger refresh', () async {
      mockAdapter.statusCodeFor = (o) =>
          o.path.contains('/auth/register') ? 401 : 200;
      mockAdapter.bodyFor = (o) =>
          o.path.contains('/auth/register')
              ? '{"message": "Email already exists"}'
              : '{"message": "ok"}';

      try {
        await client.register('test@test.com', 'password', 'Test');
      } catch (_) {}

      expect(
        mockAdapter.capturedRequests
            .any((r) => r.path.contains('/auth/register')),
        isTrue,
      );
      expect(
        mockAdapter.capturedRequests
            .any((r) => r.path.contains('/auth/refresh')),
        isFalse,
      );
    });
  });

  // ── 401 interceptor — non-auth triggers refresh ──

  group('401 interceptor — non-auth 401 triggers refresh', () {
    test('non-auth 401 queues request and attempts refresh', () async {
      // Store tokens so _refreshToken() has a refresh token to use
      await client.saveTokens('old-token', 'my-refresh-token', 'user-1');

      mockAdapter.statusCodeFor = (o) {
        if (o.path.contains('/auth/')) return 200;
        // capturedRequests.add() runs before statusCodeFor,
        // so count==1 means this is the first request (401),
        // count>1 means it's a retry (200).
        final count = mockAdapter.capturedRequests
            .where((r) => r.path == o.path).length;
        return count <= 1 ? 401 : 200;
      };
      mockAdapter.bodyFor = (o) {
        if (o.path.contains('/auth/refresh')) {
          return '{"accessToken": "new-token", "refreshToken": "new-refresh"}';
        }
        return '{"message": "ok"}';
      };

      await client.getMilestones('baby-1');

      expect(
        mockAdapter.capturedRequests
            .any((r) => r.path.contains('/milestones')),
        isTrue,
      );
      expect(
        mockAdapter.capturedRequests
            .any((r) => r.path.contains('/auth/refresh')),
        isTrue,
      );
    });

    test('refresh endpoint 401 does not recurse', () async {
      int refreshCount = 0;
      // Store tokens so _refreshToken() has a refresh token to use
      await client.saveTokens('old-token', 'my-refresh-token', 'user-1');

      mockAdapter.statusCodeFor = (o) {
        // Refresh always fails with 401
        if (o.path.contains('/auth/refresh')) {
          refreshCount++;
          return 401;
        }
        // Non-auth requests always 401
        return 401;
      };
      mockAdapter.bodyFor = (_) => '{"message": "Unauthorized"}';

      // Refresh fails, so handler rejects with original 401 error
      try {
        await client.getMilestones('baby-1');
      } catch (_) {}

      // Refresh was called exactly once — no recursive refresh
      expect(refreshCount, 1);
    });
  });

  // ── Request methods ──

  group('ApiClient request methods', () {
    test('get sends GET', () async {
      await client.get('/test');
      expect(mockAdapter.capturedRequests.last.method, 'GET');
    });

    test('post sends POST', () async {
      await client.post('/test', data: {'k': 'v'});
      expect(mockAdapter.capturedRequests.last.method, 'POST');
    });

    test('patch sends PATCH', () async {
      await client.patch('/test', data: {'k': 'v'});
      expect(mockAdapter.capturedRequests.last.method, 'PATCH');
    });

    test('put sends PUT', () async {
      await client.put('/test', data: {'k': 'v'});
      expect(mockAdapter.capturedRequests.last.method, 'PUT');
    });

    test('delete sends DELETE', () async {
      await client.delete('/test');
      expect(mockAdapter.capturedRequests.last.method, 'DELETE');
    });

    test('resolvePath prefixes /api/ for relative paths', () async {
      await client.get('baby-mons');
      expect(mockAdapter.capturedRequests.last.path, '/api/baby-mons');
    });

    test('resolvePath keeps /api/ if present', () async {
      await client.get('/api/baby-mons');
      expect(mockAdapter.capturedRequests.last.path, '/api/baby-mons');
    });

    test('resolvePath handles leading /', () async {
      await client.get('/custom');
      expect(mockAdapter.capturedRequests.last.path, '/api/custom');
    });
  });

  // ── Bearer token injection ──

  group('ApiClient token injection via interceptor', () {
    test('onRequest attaches Bearer token from storage', () async {
      await client.saveTokens('my-token', 'refresh', 'user-1');
      await client.get('/test');

      expect(
        mockAdapter.capturedRequests.last.headers['Authorization'],
        'Bearer my-token',
      );
    });

    test('onRequest skips header when no token stored', () async {
      await client.get('/test');
      expect(
        mockAdapter.capturedRequests.last.headers['Authorization'],
        isNull,
      );
    });
  });

  // ── Storage round-trips ──

  group('ApiClient storage', () {
    test('saveTokens stores all values', () async {
      await client.saveTokens('access', 'refresh', 'user-1');
      expect(await client.getAccessToken(), 'access');
      expect(await client.getUserId(), 'user-1');
    });

    test('getAccessToken returns null when not set', () async {
      expect(await client.getAccessToken(), isNull);
    });

    test('logout clears all tokens', () async {
      await client.saveTokens('a', 'r', 'u');
      await client.logout();
      expect(await client.getAccessToken(), isNull);
      expect(await client.getUserId(), isNull);
    });

    test('setSelectedBabyMonId stores and overwrites', () async {
      await client.setSelectedBabyMonId('b1');
      expect(await client.getSelectedBabyMonId(), 'b1');
      await client.setSelectedBabyMonId('b2');
      expect(await client.getSelectedBabyMonId(), 'b2');
    });

    test('setSelectedBabyMonId with null deletes key', () async {
      await client.setSelectedBabyMonId('b1');
      await client.setSelectedBabyMonId(null);
      expect(await client.getSelectedBabyMonId(), isNull);
    });

    test('setSelectedBabyMonId with empty deletes key', () async {
      await client.setSelectedBabyMonId('b1');
      await client.setSelectedBabyMonId('');
      expect(await client.getSelectedBabyMonId(), isNull);
    });

    test('setTrialOverride round-trips', () async {
      await client.setTrialOverride(14);
      expect(await client.getTrialOverride(), 14);
    });

    test('getTrialOverride returns null when not set', () async {
      expect(await client.getTrialOverride(), isNull);
    });

    test('logout is idempotent', () async {
      await client.saveTokens('a', 'r', 'u');
      await client.logout();
      await client.logout();
      expect(await client.getAccessToken(), isNull);
    });

    test('saveTokens overwrites previous values', () async {
      await client.saveTokens('old', 'old', 'old');
      await client.saveTokens('new', 'new', 'new');
      expect(await client.getAccessToken(), 'new');
      expect(await client.getUserId(), 'new');
    });

    test('multiple clients share storage', () async {
      final c1 = ApiClient(adapter: mockAdapter);
      final c2 = ApiClient(adapter: mockAdapter);
      await c1.saveTokens('t', 'r', 'u');
      expect(await c2.getAccessToken(), 't');
    });
  });
}
