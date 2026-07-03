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

  /// Extracts per-field validation errors from a backend response.
  ///
  /// When the backend returns `details: [{ field: 'email', code: 'INVALID_EMAIL' }]`,
  /// this maps each field to a localized error message suitable for
  /// `TextFormField.errorText`.
  static Map<String, String> getFieldErrors(BuildContext context, dynamic error) {
    if (error is! DioException) return const {};

    final data = error.response?.data;
    if (data is! Map || data['details'] is! List) return const {};

    final l10n = context.l10n;
    final Map<String, String> fieldErrors = {};

    for (final detail in data['details']) {
      if (detail is! Map) continue;
      final field = detail['field'] as String?;
      final code = detail['code'] as String?;
      if (field == null || code == null) continue;

      fieldErrors[field] = switch (code) {
        'INVALID_EMAIL' => l10n.valInvalidEmail,
        'REQUIRED' => l10n.valRequired,
        'MIN_LENGTH' => l10n.valMinLength,
        'MAX_LENGTH' => l10n.valMaxLength,
        'INVALID_FORMAT' => l10n.valInvalidFormat,
        'INVALID_DATE' => l10n.valInvalidDate,
        'INVALID_TYPE' => l10n.valInvalidType,
        'INVALID_VALUE' => l10n.valInvalidValue,
        'UNEXPECTED_FIELD' => l10n.valUnexpectedField,
        _ => l10n.valInvalidInput,
      };
    }

    return fieldErrors;
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
      // Allergies
      'errorAllergyNotFound' => l10n.errorAllergyNotFound,
      'errorAllergyEventNotFound' => l10n.errorAllergyEventNotFound,
      'errorAllergyAlreadyCured' => l10n.errorAllergyAlreadyCured,
      'errorAllergyAlreadyActive' => l10n.errorAllergyAlreadyActive,
      // Growth
      'errorGrowthRecordNotFound' => l10n.errorGrowthRecordNotFound,
      'errorGrowthRecordUnauthorized' => l10n.errorGrowthRecordUnauthorized,
      // Sleep
      'errorSleepLogNotFound' => l10n.errorSleepLogNotFound,
      'errorSleepLogUnauthorized' => l10n.errorSleepLogUnauthorized,
      // Media
      'errorMediaNotFound' => l10n.errorMediaNotFound,
      'errorMediaUnauthorized' => l10n.errorMediaUnauthorized,
      'errorMediaInvalidType' => l10n.errorMediaInvalidType,
      'errorMediaTooLarge' => l10n.errorMediaTooLarge,
      'errorInvalidFileType' => l10n.errorInvalidFileType,
      'errorFileTooLarge' => l10n.errorFileTooLarge,
      // Companion
      'errorCompanionNotFound' => l10n.errorCompanionNotFound,
      'errorCompanionUnauthorized' => l10n.errorCompanionUnauthorized,
      'errorRoutineNotFound' => l10n.errorRoutineNotFound,
      'errorModelNotConfigured' => l10n.errorModelNotConfigured,
      'errorModelDownloadFailed' => l10n.errorModelDownloadFailed,
      // Journal / Proposals
      'errorJournalProposalNotFound' => l10n.errorJournalProposalNotFound,
      'errorJournalProposalUnauthorized' => l10n.errorJournalProposalUnauthorized,
      'errorJournalNotFound' => l10n.errorJournalNotFound,
      'errorJournalUnauthorized' => l10n.errorJournalUnauthorized,
      'errorProposalNotFound' => l10n.errorProposalNotFound,
      'errorProposalAlreadyResolved' => l10n.errorProposalAlreadyResolved,
      // S3
      'errorS3NotConfigured' => l10n.errorS3NotConfigured,
      // Export
      'errorExportNoData' => l10n.errorExportNoData,
      // Stripe
      'errorStripeNotConfigured' => l10n.errorStripeNotConfigured,
      'errorStripeSubscriptionNotFound' => l10n.errorStripeSubscriptionNotFound,
      'errorStripeWebhookInvalid' => l10n.errorStripeWebhookInvalid,
      // Admin
      'errorAdminUnauthorized' => l10n.errorAdminUnauthorized,
      'errorAdminUserNotFound' => l10n.errorAdminUserNotFound,
      // Evolution
      'errorEvolutionNotFound' => l10n.errorEvolutionNotFound,
      'errorEvolutionUnauthorized' => l10n.errorEvolutionUnauthorized,
      // Stage Content
      'errorStageContentNotFound' => l10n.errorStageContentNotFound,
      // Partners
      'errorPartnerUnauthorized' => l10n.errorPartnerUnauthorized,
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
    // Allergies
    'ALLERGY_NOT_FOUND': 'errorAllergyNotFound',
    'ALLERGY_EVENT_NOT_FOUND': 'errorAllergyEventNotFound',
    'ALLERGY_ALREADY_CURED': 'errorAllergyAlreadyCured',
    'ALLERGY_ALREADY_ACTIVE': 'errorAllergyAlreadyActive',
    // Growth
    'GROWTH_RECORD_NOT_FOUND': 'errorGrowthRecordNotFound',
    'GROWTH_RECORD_UNAUTHORIZED': 'errorGrowthRecordUnauthorized',
    // Sleep
    'SLEEP_LOG_NOT_FOUND': 'errorSleepLogNotFound',
    'SLEEP_LOG_UNAUTHORIZED': 'errorSleepLogUnauthorized',
    // Media
    'MEDIA_NOT_FOUND': 'errorMediaNotFound',
    'MEDIA_UNAUTHORIZED': 'errorMediaUnauthorized',
    'MEDIA_INVALID_TYPE': 'errorMediaInvalidType',
    'MEDIA_TOO_LARGE': 'errorMediaTooLarge',
    'INVALID_FILE_TYPE': 'errorInvalidFileType',
    'FILE_TOO_LARGE': 'errorFileTooLarge',
    // Companion
    'COMPANION_NOT_FOUND': 'errorCompanionNotFound',
    'COMPANION_UNAUTHORIZED': 'errorCompanionUnauthorized',
    'ROUTINE_NOT_FOUND': 'errorRoutineNotFound',
    'MODEL_NOT_CONFIGURED': 'errorModelNotConfigured',
    'MODEL_DOWNLOAD_FAILED': 'errorModelDownloadFailed',
    // Journal / Proposals
    'JOURNAL_PROPOSAL_NOT_FOUND': 'errorJournalProposalNotFound',
    'JOURNAL_PROPOSAL_UNAUTHORIZED': 'errorJournalProposalUnauthorized',
    'JOURNAL_NOT_FOUND': 'errorJournalNotFound',
    'JOURNAL_UNAUTHORIZED': 'errorJournalUnauthorized',
    'PROPOSAL_NOT_FOUND': 'errorProposalNotFound',
    'PROPOSAL_ALREADY_RESOLVED': 'errorProposalAlreadyResolved',
    // S3
    'S3_NOT_CONFIGURED': 'errorS3NotConfigured',
    // Export
    'EXPORT_NO_DATA': 'errorExportNoData',
    // Stripe
    'STRIPE_NOT_CONFIGURED': 'errorStripeNotConfigured',
    'STRIPE_SUBSCRIPTION_NOT_FOUND': 'errorStripeSubscriptionNotFound',
    'STRIPE_WEBHOOK_INVALID': 'errorStripeWebhookInvalid',
    // Admin
    'ADMIN_UNAUTHORIZED': 'errorAdminUnauthorized',
    'ADMIN_USER_NOT_FOUND': 'errorAdminUserNotFound',
    // Evolution
    'EVOLUTION_NOT_FOUND': 'errorEvolutionNotFound',
    'EVOLUTION_UNAUTHORIZED': 'errorEvolutionUnauthorized',
    // Stage Content
    'STAGE_CONTENT_NOT_FOUND': 'errorStageContentNotFound',
    // Partners
    'PARTNER_UNAUTHORIZED': 'errorPartnerUnauthorized',
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
    // Allergies
    'errorAllergyNotFound': 'Allergy not found.',
    'errorAllergyEventNotFound': 'Allergy event not found.',
    'errorAllergyAlreadyCured': 'Allergy is already marked as cured.',
    'errorAllergyAlreadyActive': 'Allergy is already active.',
    // Growth
    'errorGrowthRecordNotFound': 'Growth record not found.',
    'errorGrowthRecordUnauthorized': 'Only the owner can manage growth records.',
    // Sleep
    'errorSleepLogNotFound': 'Sleep log not found.',
    'errorSleepLogUnauthorized': 'You do not have permission to access this sleep log.',
    // Media
    'errorMediaNotFound': 'Media not found.',
    'errorMediaUnauthorized': 'Only the owner can manage media.',
    'errorMediaInvalidType': 'Invalid file type. Allowed: JPEG, PNG, GIF, WebP, MP4, MOV.',
    'errorMediaTooLarge': 'File too large. Maximum size is 50MB.',
    'errorInvalidFileType': 'Invalid file type.',
    'errorFileTooLarge': 'File too large.',
    // Companion
    'errorCompanionNotFound': 'Companion content not found.',
    'errorCompanionUnauthorized': 'You do not have permission to access companion content.',
    'errorRoutineNotFound': 'No routine found for today.',
    'errorModelNotConfigured': 'AI model is not configured.',
    'errorModelDownloadFailed': 'Model download failed. Please try again.',
    // Journal / Proposals
    'errorJournalProposalNotFound': 'Journal proposal not found.',
    'errorJournalProposalUnauthorized': 'You do not have permission to access this proposal.',
    'errorJournalNotFound': 'Journal entry not found.',
    'errorJournalUnauthorized': 'You do not have permission to access this journal.',
    'errorProposalNotFound': 'Proposal not found.',
    'errorProposalAlreadyResolved': 'This proposal has already been resolved.',
    // S3
    'errorS3NotConfigured': 'File storage is not configured.',
    // Export
    'errorExportNoData': 'No data available to export.',
    // Stripe
    'errorStripeNotConfigured': 'Payment provider is not configured. Please contact support.',
    'errorStripeSubscriptionNotFound': 'No active subscription found.',
    'errorStripeWebhookInvalid': 'Payment webhook verification failed. Please contact support.',
    // Admin
    'errorAdminUnauthorized': 'Admin action not allowed.',
    'errorAdminUserNotFound': 'User not found.',
    // Evolution
    'errorEvolutionNotFound': 'Evolution data not found.',
    'errorEvolutionUnauthorized': 'You do not have permission to view evolution data.',
    // Stage Content
    'errorStageContentNotFound': 'Stage content not found.',
    // Partners
    'errorPartnerUnauthorized': 'You do not have permission to manage partners.',
    'errorUnknown': 'Something went wrong. Please try again.',
  };
}
