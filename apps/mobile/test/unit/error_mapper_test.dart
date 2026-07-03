import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/utils/error_mapper.dart';

void main() {
  group('ErrorMapper.toKey', () {
    group('DioException with backend code in response data', () {
      DioException backendError(String code, {int? statusCode}) {
        return DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode ?? 400,
            data: {'code': code, 'message': 'Server message'},
          ),
        );
      }

      test('maps UNAUTHORIZED to errorUnauthorized', () {
        expect(ErrorMapper.toKey(backendError('UNAUTHORIZED')), 'errorUnauthorized');
      });

      test('maps NOT_FOUND to errorNotFound', () {
        expect(ErrorMapper.toKey(backendError('NOT_FOUND')), 'errorNotFound');
      });

      test('maps BABYMON_NOT_FOUND to errorBabyMonNotFound', () {
        expect(ErrorMapper.toKey(backendError('BABYMON_NOT_FOUND')), 'errorBabyMonNotFound');
      });

      test('maps PROMO_CODE_INVALID to errorPromoCodeInvalid', () {
        expect(ErrorMapper.toKey(backendError('PROMO_CODE_INVALID')), 'errorPromoCodeInvalid');
      });

      test('maps unknown backend code to status fallback', () {
        expect(ErrorMapper.toKey(backendError('UNKNOWN_CODE', statusCode: 404)), 'errorNotFound');
      });
    });

    group('DioException with HTTP status code only', () {
      DioException statusError(int statusCode) {
        return DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          ),
        );
      }

      test('maps 400 to errorBadRequest', () {
        expect(ErrorMapper.toKey(statusError(400)), 'errorBadRequest');
      });

      test('maps 401 to errorUnauthorized', () {
        expect(ErrorMapper.toKey(statusError(401)), 'errorUnauthorized');
      });

      test('maps 402 to errorUpgradeRequired', () {
        expect(ErrorMapper.toKey(statusError(402)), 'errorUpgradeRequired');
      });

      test('maps 403 to errorForbidden', () {
        expect(ErrorMapper.toKey(statusError(403)), 'errorForbidden');
      });

      test('maps 404 to errorNotFound', () {
        expect(ErrorMapper.toKey(statusError(404)), 'errorNotFound');
      });

      test('maps 409 to errorConflict', () {
        expect(ErrorMapper.toKey(statusError(409)), 'errorConflict');
      });

      test('maps 429 to errorRateLimited', () {
        expect(ErrorMapper.toKey(statusError(429)), 'errorRateLimited');
      });

      test('maps 500 to errorServer', () {
        expect(ErrorMapper.toKey(statusError(500)), 'errorServer');
      });

      test('maps 502 to errorServer', () {
        expect(ErrorMapper.toKey(statusError(502)), 'errorServer');
      });

      test('maps 503 to errorServer', () {
        expect(ErrorMapper.toKey(statusError(503)), 'errorServer');
      });

      test('maps unmapped status code to errorUnknown', () {
        expect(ErrorMapper.toKey(statusError(418)), 'errorUnknown');
      });
    });

    group('DioException network types', () {
      test('maps connectionTimeout to errorConnectionTimeout', () {
        final error = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(ErrorMapper.toKey(error), 'errorConnectionTimeout');
      });

      test('maps sendTimeout to errorConnectionTimeout', () {
        final error = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(ErrorMapper.toKey(error), 'errorConnectionTimeout');
      });

      test('maps receiveTimeout to errorConnectionTimeout', () {
        final error = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(ErrorMapper.toKey(error), 'errorConnectionTimeout');
      });

      test('maps connectionError to errorConnectionFailed', () {
        final error = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(ErrorMapper.toKey(error), 'errorConnectionFailed');
      });

      test('maps cancel to errorNetwork', () {
        final error = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(ErrorMapper.toKey(error), 'errorNetwork');
      });

      test('maps unknown to errorNetwork', () {
        final error = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
        );
        expect(ErrorMapper.toKey(error), 'errorNetwork');
      });
    });

    group('Plain String error codes (client-side)', () {
      test('maps APPLE_SIGN_IN_UNAVAILABLE to errorAppleSignInUnavailable', () {
        expect(
          ErrorMapper.toKey('APPLE_SIGN_IN_UNAVAILABLE'),
          'errorAppleSignInUnavailable',
        );
      });

      test('maps APPLE_NO_IDENTITY_TOKEN to errorAppleNoIdentityToken', () {
        expect(
          ErrorMapper.toKey('APPLE_NO_IDENTITY_TOKEN'),
          'errorAppleNoIdentityToken',
        );
      });

      test('maps FACEBOOK_NO_ACCESS_TOKEN to errorFacebookNoAccessToken', () {
        expect(
          ErrorMapper.toKey('FACEBOOK_NO_ACCESS_TOKEN'),
          'errorFacebookNoAccessToken',
        );
      });

      test('maps unknown string to errorUnknown', () {
        expect(ErrorMapper.toKey('SOME_RANDOM_STRING'), 'errorUnknown');
      });
    });

    group('Unknown error types', () {
      test('maps Exception to errorUnknown', () {
        expect(ErrorMapper.toKey(Exception('random')), 'errorUnknown');
      });

      test('maps null to errorUnknown', () {
        expect(ErrorMapper.toKey(null), 'errorUnknown');
      });

      test('maps int to errorUnknown', () {
        expect(ErrorMapper.toKey(500), 'errorUnknown');
      });
    });
  });

  group('ErrorMapper.fallbackMessage', () {
    test('returns English message for known key', () {
      expect(
        ErrorMapper.fallbackMessage('errorUnauthorized'),
        'Session expired. Please log in again.',
      );
    });

    test('returns generic fallback for unknown key', () {
      expect(
        ErrorMapper.fallbackMessage('unknown_key_xyz'),
        'Something went wrong. Please try again.',
      );
    });
  });

  group('ErrorMapper.localize — pure function smoke test', () {
    test('toKey + fallbackMessage round-trip for Apple Sign-In unavailable', () {
      final key = ErrorMapper.toKey('APPLE_SIGN_IN_UNAVAILABLE');
      expect(key, 'errorAppleSignInUnavailable');
      expect(
        ErrorMapper.fallbackMessage(key),
        'Apple Sign-In is not available on this device.',
      );
    });
  });
}
