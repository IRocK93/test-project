import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'error_mapper.dart';
import 'tier_required_exception.dart';

/// Extracts a user-friendly error message from any error type.
///
/// Priority:
///  1. Backend `code` field → localized fallback via [ErrorMapper]
///  2. HTTP status code → generic fallback key
///  3. Dio network error type → connection message
///
/// Never exposes raw backend `message` strings directly — they are
/// hardcoded English that leak to non-English users.
String extractErrorMessage(dynamic error) {
  if (error is DioException) {
    // Prefer localized messages via ErrorMapper (uses backend code field
    // or HTTP status code, never raw message text).
    final key = ErrorMapper.toKey(error);
    if (key != 'errorUnknown') {
      return ErrorMapper.fallbackMessage(key);
    }

    // Dio network-level errors (no HTTP response at all)
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Could not connect to the server.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == null) {
          return 'Something went wrong. Please try again.';
        }
        // Status codes already mapped by ErrorMapper.toKey above;
        // this branch only hits truly unmapped codes.
        return 'Something went wrong. Please try again.';
      default:
        return 'Network error. Please check your connection.';
    }
  }
  // Generic fallback — never show '$e' directly
  return 'Something went wrong. Please try again.';
}

/// Returns true if [error] is a DioException signalling that the user
/// needs to upgrade to PREMIUM (HTTP 402 with code UPGRADE_REQUIRED).
///
/// Use this to decide whether to show an upgrade prompt versus a
/// generic error state. Re-throw as [TierRequiredException] for the
/// cleanest integration with Riverpod FutureProvider error handling.
bool isTierRequiredError(dynamic error) {
  if (error is TierRequiredException) return true;
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final code =
        error.response?.data is Map ? error.response?.data['code'] : null;
    return statusCode == 402 || code == 'UPGRADE_REQUIRED';
  }
  return false;
}

/// Shows a localized user-friendly error snackbar.
///
/// Prefer this over [extractErrorMessage] in any widget context so users
/// see text in their chosen language. Falls back to English for
/// background / non-widget errors.
///
/// Call this directly in catch blocks:
/// ```dart
/// } catch (e) {
///   if (mounted) showError(context, e);
/// }
/// ```
void showError(BuildContext context, dynamic error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ErrorMapper.localize(context, error)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Shows a localized error snackbar with a retry action.
void showErrorWithRetry(
    BuildContext context, dynamic error, VoidCallback onRetry) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ErrorMapper.localize(context, error)),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(label: context.l10n.retry, onPressed: onRetry),
    ),
  );
}

/// Shows a success snackbar.
void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
  );
}
