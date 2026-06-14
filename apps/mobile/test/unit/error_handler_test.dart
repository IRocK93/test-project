import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:baby_mon/core/utils/error_handler.dart';

void main() {
  group('extractErrorMessage', () {
    group('DioException with server message', () {
      test('returns server message when response body has message field', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 'Email already registered'},
          ),
        );

        expect(extractErrorMessage(error), 'Email already registered');
      });
    });

    group('DioException timeout errors', () {
      test('returns timeout message for connectionTimeout', () {
        final error = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(extractErrorMessage(error), contains('timed out'));
      });

      test('returns timeout message for sendTimeout', () {
        final error = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(extractErrorMessage(error), contains('timed out'));
      });

      test('returns timeout message for receiveTimeout', () {
        final error = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(extractErrorMessage(error), contains('timed out'));
      });
    });

    group('DioException connection error', () {
      test('returns connection error message', () {
        final error = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(extractErrorMessage(error), contains('connect'));
      });
    });

    group('DioException bad response status codes', () {
      test('returns session expired for 401', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );

        expect(extractErrorMessage(error), contains('Session expired'));
      });

      test('returns permission message for 403', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 403,
          ),
        );

        expect(extractErrorMessage(error), contains('permission'));
      });

      test('returns not found message for 404', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
          ),
        );

        expect(extractErrorMessage(error), contains('Not found'));
      });

      test('returns conflict message for 409', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 409,
          ),
        );

        expect(extractErrorMessage(error), contains('already exists'));
      });

      test('returns rate limit message for 429', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 429,
          ),
        );

        expect(extractErrorMessage(error), contains('Too many requests'));
      });

      test('returns server error for 500', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );

        expect(extractErrorMessage(error), contains('Server error'));
      });

      test('returns generic message for unknown status code', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 418,
          ),
        );

        expect(extractErrorMessage(error), contains('Something went wrong'));
      });
    });

    group('generic errors', () {
      test('returns generic message for non-DioException errors', () {
        expect(extractErrorMessage(Exception('something')), contains('Something went wrong'));
      });

      test('returns generic message for string errors', () {
        expect(extractErrorMessage('raw string error'), contains('Something went wrong'));
      });

      test('returns generic message for null', () {
        expect(extractErrorMessage(null), contains('Something went wrong'));
      });
    });

    group('server message takes priority', () {
      test('prefers server message over status code message', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
            data: {'message': 'Custom auth error from backend'},
          ),
        );

        expect(extractErrorMessage(error), 'Custom auth error from backend');
      });
    });
  });
}
