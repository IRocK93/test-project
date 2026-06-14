import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:baby_mon/core/constants/api_constants.dart';

/// A Dio [Interceptor] that transparently refreshes expired access tokens.
///
/// When a non-auth endpoint returns 401, the interceptor:
/// 1. Queues the failed request
/// 2. Attempts a single token refresh via the `/auth/refresh` endpoint
/// 3. Retries all queued requests with the new token
/// 4. Properly rejects all requests if refresh fails
///
/// Auth endpoints (login, register, refresh) are excluded from retry
/// to avoid infinite loops and spurious refresh calls.
class RetryInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  /// Called to perform the actual token refresh.
  final Future<bool> Function() refreshToken;

  bool _isRefreshing = false;
  final List<_PendingRetry> _pendingRetries = [];

  RetryInterceptor({
    required FlutterSecureStorage storage,
    required Dio dio,
    required this.refreshToken,
  })  : _storage = storage,
        _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;

      // Don't try to refresh token for auth endpoints
      if (path.contains('/auth/login') ||
          path.contains('/auth/register') ||
          path.contains('/auth/refresh')) {
        return handler.next(err);
      }

      // Queue this request to retry after token refresh
      _pendingRetries.add((success, newToken) async {
        if (success && newToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await _dio.fetch<dynamic>(err.requestOptions);
            handler.resolve(response);
          } catch (e) {
            handler.reject(
              e is DioException
                  ? e
                  : DioException(requestOptions: err.requestOptions, error: e),
            );
          }
        } else {
          // Refresh failed — reject with the original error
          handler.next(err);
        }
      });

      // Only trigger refresh once for concurrent 401s
      if (!_isRefreshing) {
        _isRefreshing = true;
        final success = await refreshToken();
        final newToken = await _storage.read(key: StorageKeys.accessToken);

        // Process all queued retries
        final retries = List<_PendingRetry>.from(_pendingRetries);
        _pendingRetries.clear();
        for (final retry in retries) {
          retry(success, newToken);
        }
        _isRefreshing = false;
      }
      return;
    }
    return handler.next(err);
  }
}

typedef _PendingRetry = Future<void> Function(bool success, String? newToken);
