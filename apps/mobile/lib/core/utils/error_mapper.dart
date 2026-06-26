import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';

/// Maps backend error codes to localization keys.
///
/// The backend returns `{ code: 'UNAUTHORIZED', message: '...' }` in error
/// responses. The mobile app should prefer localized strings over raw
/// backend messages so users see text in their chosen language.
///
/// Usage:
/// ```dart
/// final message = ErrorMapper.toMessage(context, error);
/// ```
class ErrorMapper {
  ErrorMapper._();

  /// Maps an error (DioException, Exception, etc.) to a localization key.
  ///
  /// Priority:
  ///  1. Backend `code` field → known key
  ///  2. HTTP status code → generic key
  ///  3. Fallback → generic network/server key
  static String toKey(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['code'] is String) {
        final code = data['code'] as String;
        final key = _codeToKey[code];
        if (key != null) return key;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return _statusToKey(statusCode) ?? 'errorUnknown';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'errorConnectionTimeout';
        case DioExceptionType.connectionError:
          return 'errorConnectionFailed';
        default:
          return 'errorNetwork';
      }
    }

    // Handle plain error-code strings emitted by client-side code
    // (e.g., auth provider social-login failures).
    if (error is String) {
      final key = _codeToKey[error];
      if (key != null) return key;
    }

    return 'errorUnknown';
  }

  /// Returns a localized error message for the given error.
  ///
  /// Prefer this over [fallbackMessage] in any widget context so users
  /// see text in their chosen language.
  static String localize(BuildContext context, dynamic error) {
    final key = toKey(error);
    final l10n = context.l10n;
    return switch (key) {
      'errorInternal' => l10n.errorInternal,
      'errorDatabase' => l10n.errorDatabase,
      'errorValidation' => l10n.errorValidation,
      'errorNotFound' => l10n.errorNotFound,
      'errorUnauthorized' => l10n.errorUnauthorized,
      'errorInvalidToken' => l10n.errorInvalidToken,
      'errorTokenExpired' => l10n.errorTokenExpired,
      'errorUserNotFound' => l10n.errorUserNotFound,
      'errorAccountDeleted' => l10n.errorAccountDeleted,
      'errorOAuthRequired' => l10n.errorOAuthRequired,
      'errorDuplicateEmail' => l10n.errorDuplicateEmail,
      'errorInvalidOperation' => l10n.errorInvalidOperation,
      'errorRateLimited' => l10n.errorRateLimited,
      'errorTrialExpired' => l10n.errorTrialExpired,
      'errorLimitReached' => l10n.errorLimitReached,
      'errorUpgradeRequired' => l10n.errorUpgradeRequired,
      'errorEmailInUse' => l10n.errorEmailInUse,
      'errorInvalidPassword' => l10n.errorInvalidPassword,
      'errorBadRequest' => l10n.errorBadRequest,
      'errorForbidden' => l10n.errorForbidden,
      'errorConflict' => l10n.errorConflict,
      'errorServer' => l10n.errorServer,
      'errorConnectionTimeout' => l10n.errorConnectionTimeout,
      'errorConnectionFailed' => l10n.errorConnectionFailed,
      'errorNetwork' => l10n.errorNetwork,
      'errorBabyMonNotFound' => l10n.errorBabyMonNotFound,
      'errorMilestoneNotFound' => l10n.errorMilestoneNotFound,
      'errorFeedLogNotFound' => l10n.errorFeedLogNotFound,
      'errorHealthRecordNotFound' => l10n.errorHealthRecordNotFound,
      'errorInvitationNotFound' => l10n.errorInvitationNotFound,
      'errorCannotInviteSelf' => l10n.errorCannotInviteSelf,
      'errorInvitationAlreadyProcessed' => l10n.errorInvitationAlreadyProcessed,
      'errorInvitationExpired' => l10n.errorInvitationExpired,
      'errorLinkNotFound' => l10n.errorLinkNotFound,
      'errorPromoCodeInvalid' => l10n.errorPromoCodeInvalid,
      'errorPromoCodeExpired' => l10n.errorPromoCodeExpired,
      'errorPromoCodeLimitReached' => l10n.errorPromoCodeLimitReached,
      'errorPromoCodeAlreadyUsed' => l10n.errorPromoCodeAlreadyUsed,
      'errorAppleSignInUnavailable' => l10n.errorAppleSignInUnavailable,
      'errorAppleNoIdentityToken' => l10n.errorAppleNoIdentityToken,
      'errorFacebookNoAccessToken' => l10n.errorFacebookNoAccessToken,
      _ => fallbackMessage(key),
    };
  }

  /// Returns a human-readable English fallback message for an error key.
  ///
  /// This is used when localization is not yet loaded or when showing
  /// errors outside of a widget context (e.g., background tasks).
  static String fallbackMessage(String key) {
    return _fallbackMessages[key] ?? 'Something went wrong. Please try again.';
  }

  static final Map<String, String> _codeToKey = {
    'INTERNAL_ERROR': 'errorInternal',
    'DATABASE_ERROR': 'errorDatabase',
    'VALIDATION_ERROR': 'errorValidation',
    'NOT_FOUND': 'errorNotFound',
    'UNAUTHORIZED': 'errorUnauthorized',
    'INVALID_TOKEN': 'errorInvalidToken',
    'TOKEN_EXPIRED': 'errorTokenExpired',
    'USER_NOT_FOUND': 'errorUserNotFound',
    'ACCOUNT_DELETED': 'errorAccountDeleted',
    'OAUTH_REQUIRED': 'errorOAuthRequired',
    'DUPLICATE': 'errorDuplicateEmail',
    'DUPLICATE_EMAIL': 'errorDuplicateEmail',
    'INVALID_OPERATION': 'errorInvalidOperation',
    'RATE_LIMITED': 'errorRateLimited',
    'TRIAL_EXPIRED': 'errorTrialExpired',
    'LIMIT_REACHED': 'errorLimitReached',
    'UPGRADE_REQUIRED': 'errorUpgradeRequired',
    'EMAIL_IN_USE': 'errorEmailInUse',
    'INVALID_PASSWORD': 'errorInvalidPassword',
    'BABYMON_NOT_FOUND': 'errorBabyMonNotFound',
    'MILESTONE_NOT_FOUND': 'errorMilestoneNotFound',
    'FEED_LOG_NOT_FOUND': 'errorFeedLogNotFound',
    'HEALTH_RECORD_NOT_FOUND': 'errorHealthRecordNotFound',
    'INVITATION_NOT_FOUND': 'errorInvitationNotFound',
    'CANNOT_INVITE_SELF': 'errorCannotInviteSelf',
    'INVITATION_ALREADY_PROCESSED': 'errorInvitationAlreadyProcessed',
    'INVITATION_EXPIRED': 'errorInvitationExpired',
    'LINK_NOT_FOUND': 'errorLinkNotFound',
    'PROMO_CODE_INVALID': 'errorPromoCodeInvalid',
    'PROMO_CODE_EXPIRED': 'errorPromoCodeExpired',
    'PROMO_CODE_LIMIT_REACHED': 'errorPromoCodeLimitReached',
    'PROMO_CODE_ALREADY_USED': 'errorPromoCodeAlreadyUsed',
    // Client-side codes (set by mobile auth providers)
    'APPLE_SIGN_IN_UNAVAILABLE': 'errorAppleSignInUnavailable',
    'APPLE_NO_IDENTITY_TOKEN': 'errorAppleNoIdentityToken',
    'FACEBOOK_NO_ACCESS_TOKEN': 'errorFacebookNoAccessToken',
  };

  static String? _statusToKey(int statusCode) {
    return switch (statusCode) {
      400 => 'errorBadRequest',
      401 => 'errorUnauthorized',
      402 => 'errorUpgradeRequired',
      403 => 'errorForbidden',
      404 => 'errorNotFound',
      409 => 'errorConflict',
      429 => 'errorRateLimited',
      500 || 502 || 503 => 'errorServer',
      _ => null,
    };
  }

  static final Map<String, String> _fallbackMessages = {
    'errorInternal': 'Something went wrong. Please try again.',
    'errorDatabase': 'A database error occurred. Please try again.',
    'errorValidation': 'Invalid request. Please check your input.',
    'errorNotFound': 'Not found. The feature may not be available yet.',
    'errorUnauthorized': 'Session expired. Please log in again.',
    'errorInvalidToken': 'Invalid token. Please log in again.',
    'errorTokenExpired': 'Your session has expired. Please log in again.',
    'errorUserNotFound': 'User not found.',
    'errorAccountDeleted': 'This account has been deleted.',
    'errorOAuthRequired': 'Please use social login for this account.',
    'errorDuplicateEmail': 'This email is already registered.',
    'errorInvalidOperation': 'Invalid operation. Please try again.',
    'errorRateLimited': 'Too many requests. Please wait a moment.',
    'errorTrialExpired': 'Your free trial has expired. Please upgrade.',
    'errorLimitReached': 'You have reached the limit for this feature.',
    'errorUpgradeRequired': 'This feature requires a Premium subscription.',
    'errorEmailInUse': 'Email already in use.',
    'errorInvalidPassword': 'Invalid password.',
    'errorBadRequest': 'Invalid request. Please check your input.',
    'errorForbidden': 'You do not have permission to do that.',
    'errorConflict': 'This already exists. Please use a different value.',
    'errorServer': 'Server error. Please try again later.',
    'errorConnectionTimeout': 'Connection timed out. Please check your internet.',
    'errorConnectionFailed': 'Could not connect to the server.',
    'errorNetwork': 'Network error. Please check your connection.',
    'errorAppleSignInUnavailable': 'Apple Sign-In is not available on this device.',
    'errorAppleNoIdentityToken': 'No identity token received from Apple.',
    'errorFacebookNoAccessToken': 'No access token received from Facebook.',
    'errorUnknown': 'Something went wrong. Please try again.',
  };
}
