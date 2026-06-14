import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/utils/error_handler.dart';

void main() {
  group('extractErrorMessage', () {
    group('DioException — timeout types', () {
      test('connectionTimeout returns timeout message', () {
        final error = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Connection timed out. Please check your internet and try again.',
        );
      });

      test('sendTimeout returns timeout message', () {
        final error = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Connection timed out. Please check your internet and try again.',
        );
      });

      test('receiveTimeout returns timeout message', () {
        final error = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Connection timed out. Please check your internet and try again.',
        );
      });
    });

    group('DioException — connection error', () {
      test('connectionError returns connection message', () {
        final error = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Could not connect to the server. Is the backend running?',
        );
      });
    });

    group('DioException — bad response status codes', () {
      DioException badResponse(int statusCode, {dynamic data}) {
        return DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
            data: data,
          ),
        );
      }

      test('400 returns invalid request message', () {
        expect(
          extractErrorMessage(badResponse(400)),
          'Invalid request. Please check your input.',
        );
      });

      test('401 returns session expired message', () {
        expect(
          extractErrorMessage(badResponse(401)),
          'Session expired. Please log in again.',
        );
      });

      test('403 returns permission message', () {
        expect(
          extractErrorMessage(badResponse(403)),
          "You don't have permission to do that.",
        );
      });

      test('404 returns not found message', () {
        expect(
          extractErrorMessage(badResponse(404)),
          'Not found. The feature may not be available yet.',
        );
      });

      test('409 returns conflict message', () {
        expect(
          extractErrorMessage(badResponse(409)),
          'This already exists. Please use a different value.',
        );
      });

      test('429 returns rate limit message', () {
        expect(
          extractErrorMessage(badResponse(429)),
          'Too many requests. Please wait a moment and try again.',
        );
      });

      test('500 returns server error message', () {
        expect(
          extractErrorMessage(badResponse(500)),
          'Server error. Please try again later.',
        );
      });

      test('502 returns server error message', () {
        expect(
          extractErrorMessage(badResponse(502)),
          'Server error. Please try again later.',
        );
      });

      test('503 returns server error message', () {
        expect(
          extractErrorMessage(badResponse(503)),
          'Server error. Please try again later.',
        );
      });

      test('418 returns generic wrong message', () {
        expect(
          extractErrorMessage(badResponse(418)),
          'Something went wrong. Please try again.',
        );
      });

      test('null statusCode returns generic message', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Something went wrong. Please try again.',
        );
      });
    });

    group('DioException — server message override', () {
      test('uses server message when available', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 'Email already registered'},
          ),
        );
        expect(extractErrorMessage(error), 'Email already registered');
      });

      test('ignores empty server message', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': ''},
          ),
        );
        expect(
          extractErrorMessage(error),
          'Invalid request. Please check your input.',
        );
      });

      test('ignores non-string server message', () {
        final error = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 123},
          ),
        );
        expect(
          extractErrorMessage(error),
          'Invalid request. Please check your input.',
        );
      });
    });

    group('DioException — other types', () {
      test('cancel returns network error message', () {
        final error = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Network error. Please check your connection.',
        );
      });

      test('unknown returns network error message', () {
        final error = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(
          extractErrorMessage(error),
          'Network error. Please check your connection.',
        );
      });
    });

    group('non-DioException errors', () {
      test('generic Exception returns fallback message', () {
        expect(
          extractErrorMessage(Exception('something broke')),
          'Something went wrong. Please try again.',
        );
      });

      test('String error returns fallback message', () {
        expect(
          extractErrorMessage('unexpected string'),
          'Something went wrong. Please try again.',
        );
      });

      test('null error returns fallback message', () {
        expect(
          extractErrorMessage(null),
          'Something went wrong. Please try again.',
        );
      });

      test('int error returns fallback message', () {
        expect(
          extractErrorMessage(42),
          'Something went wrong. Please try again.',
        );
      });
    });
  });
}
