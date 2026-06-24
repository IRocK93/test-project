import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';

/// Exponential backoff retry interceptor for transient failures.
///
/// Retries requests that fail with server errors (5xx) or network errors,
/// using exponential backoff with jitter. Auth errors (401) and client
/// errors (400-499, excluding 429) are not retried — those are handled
/// by the separate [RetryInterceptor].
class BackoffInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;
  final double multiplier;

  BackoffInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.multiplier = 2.0,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final retryCount = err.requestOptions.extra['_backoffRetryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff with jitter
    final delayMs = initialDelay.inMilliseconds *
        pow(multiplier, retryCount) *
        (1.0 + Random().nextDouble() * 0.3); // ±15% jitter
    await Future.delayed(Duration(milliseconds: delayMs.round()));

    try {
      final options = err.requestOptions;
      options.extra['_backoffRetryCount'] = retryCount + 1;
      final response = await Dio().fetch(options);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        // Recurse through the interceptor chain for the retried error
        return handler.next(e);
      }
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: e,
      ));
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry on server errors and network failures
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final statusCode = err.response?.statusCode;
    // Retry on 5xx and 429 (rate limit)
    if (statusCode != null && (statusCode >= 500 || statusCode == 429)) {
      return true;
    }
    return false;
  }
}
