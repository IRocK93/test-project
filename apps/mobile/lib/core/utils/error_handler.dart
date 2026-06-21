import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// Extracts a user-friendly error message from any error type.
///
/// Prefers backend-provided messages, then falls back to generic text.
/// Never exposes raw stack traces or DioException internals to users.
String extractErrorMessage(dynamic error) {
  if (error is DioException) {
    // Backend often returns { message: '...' } in the response body
    final serverMessage =
        error.response?.data is Map ? error.response?.data['message'] : null;
    if (serverMessage is String && serverMessage.isNotEmpty) {
      return serverMessage;
    }
    // DioException has human-readable messages for common HTTP errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet and try again.';
      case DioExceptionType.connectionError:
        return 'Could not connect to the server. Is the backend running?';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == null) {
          return 'Something went wrong. Please try again.';
        }
        switch (statusCode) {
          case 400:
            return 'Invalid request. Please check your input.';
          case 401:
            return 'Session expired. Please log in again.';
          case 403:
            return 'You don\'t have permission to do that.';
          case 404:
            return 'Not found. The feature may not be available yet.';
          case 409:
            return 'This already exists. Please use a different value.';
          case 429:
            return 'Too many requests. Please wait a moment and try again.';
          case 500:
          case 502:
          case 503:
            return 'Server error. Please try again later.';
          default:
            return 'Something went wrong. Please try again.';
        }
      default:
        return 'Network error. Please check your connection.';
    }
  }
  // Generic fallback — never show '$e' directly
  return 'Something went wrong. Please try again.';
}

/// Shows a user-friendly error snackbar.
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
      content: Text(extractErrorMessage(error)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Shows an error snackbar with a retry action.
void showErrorWithRetry(
    BuildContext context, dynamic error, VoidCallback onRetry) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(extractErrorMessage(error)),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(label: 'Retry', onPressed: onRetry),
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
