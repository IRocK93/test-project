import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:baby_mon/core/data/retry_interceptor.dart';

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
  late Dio dio;
  late int refreshCount;
  late bool refreshResult;
  late RetryInterceptor interceptor;

  setUp(() {
    _secureStore.clear();
    mockAdapter = _MockHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
    dio.httpClientAdapter = mockAdapter;
    refreshCount = 0;
    refreshResult = false;

    interceptor = RetryInterceptor(
      storage: const FlutterSecureStorage(),
      dio: dio,
      refreshToken: () async {
        refreshCount++;
        if (refreshResult) {
          // Simulate successful refresh by storing new tokens
          _secureStore['access_token'] = 'new-access-token';
          _secureStore['refresh_token'] = 'new-refresh-token';
        }
        return refreshResult;
      },
    );

    // Add a simple onRequest interceptor to create async gaps
    // (mimics ApiClient's token injection interceptor)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _secureStore['access_token'];
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
    dio.interceptors.add(interceptor);

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
    dio.interceptors.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  // ── Auth endpoint exclusion ──

  group('auth endpoint exclusion', () {
    test('login 401 does NOT trigger refresh', () async {
      mockAdapter.statusCodeFor = (o) =>
          o.path.contains('/auth/login') ? 401 : 200;
      mockAdapter.bodyFor = (_) => '{"message": "Invalid credentials"}';

      try {
        await dio.post<dynamic>('/api/auth/login',
            data: {'email': 'a', 'password': 'b'});
      } catch (_) {}

      expect(refreshCount, 0);
      expect(
        mockAdapter.capturedRequests
            .any((r) => r.path.contains('/auth/refresh')),
        isFalse,
      );
    });

    test('register 401 does NOT trigger refresh', () async {
      mockAdapter.statusCodeFor = (o) =>
          o.path.contains('/auth/register') ? 401 : 200;
      mockAdapter.bodyFor = (_) => '{"message": "Email already exists"}';

      try {
        await dio.post<dynamic>('/api/auth/register',
            data: {'email': 'a'});
      } catch (_) {}

      expect(refreshCount, 0);
    });

    test('refresh 401 does NOT trigger another refresh', () async {
      mockAdapter.statusCodeFor = (_) => 401;
      mockAdapter.bodyFor = (_) => '{"message": "Unauthorized"}';

      try {
        await dio.post<dynamic>('/api/auth/refresh',
            data: {'refreshToken': 'x'});
      } catch (_) {}

      expect(refreshCount, 0);
    });
  });

  // ── Refresh triggers ──

  group('refresh triggers', () {
    test('non-auth 401 triggers refresh attempt', () async {
      refreshResult = true;
      _secureStore['access_token'] = 'old-token';
      _secureStore['refresh_token'] = 'my-refresh-token';

      mockAdapter.statusCodeFor = (o) {
        if (o.path.contains('/auth/')) return 200;
        final count = mockAdapter.capturedRequests
            .where((r) => r.path == o.path).length;
        return count <= 1 ? 401 : 200;
      };
      mockAdapter.bodyFor = (_) => '{"data": "ok"}';

      await dio.get<dynamic>('/api/milestones');

      expect(refreshCount, 1);
      expect(
        mockAdapter.capturedRequests
            .where((r) => r.path.contains('/milestones')).length,
        2, // original + retry
      );
    });

    test('refresh failure rejects the request', () async {
      refreshResult = false;
      _secureStore['access_token'] = 'old-token';
      _secureStore['refresh_token'] = 'my-refresh-token';

      mockAdapter.statusCodeFor = (_) => 401;
      mockAdapter.bodyFor = (_) => '{"message": "Unauthorized"}';

      try {
        await dio.get<dynamic>('/api/milestones');
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<DioException>());
      }

      expect(refreshCount, 1);
    });

    test('refresh success stores new tokens', () async {
      refreshResult = true;
      _secureStore['access_token'] = 'old-token';
      _secureStore['refresh_token'] = 'my-refresh-token';

      mockAdapter.statusCodeFor = (o) {
        if (o.path.contains('/auth/')) return 200;
        final count = mockAdapter.capturedRequests
            .where((r) => r.path == o.path).length;
        return count <= 1 ? 401 : 200;
      };
      mockAdapter.bodyFor = (_) => '{"data": "ok"}';

      await dio.get<dynamic>('/api/milestones');

      // New tokens were stored by the refreshToken callback
      expect(_secureStore['access_token'], 'new-access-token');
      expect(_secureStore['refresh_token'], 'new-refresh-token');
    });
  });


}
