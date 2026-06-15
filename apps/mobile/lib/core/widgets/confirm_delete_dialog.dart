import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/constants.dart';

/// A reusable confirmation dialog for delete operations.
/// Provides consistent styling across all screens.
class ConfirmDeleteDialog {
  /// Shows a delete confirmation dialog.
  /// Returns `true` if the user confirmed deletion.
  ///
  /// [title] defaults to "Delete {itemType}" if provided, otherwise "Confirm Delete".
  /// [message] defaults to a standard message based on [itemType].
  /// [confirmLabel] defaults to "Delete".
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
    String? itemType,
    String? confirmLabel,
    Color? confirmColor,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        title: Text(
          title ?? (itemType != null ? 'Delete $itemType' : 'Confirm Delete'),
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        content: Text(
          message ??
              (itemType != null
                  ? 'Are you sure you want to delete this $itemType? This action cannot be undone.'
                  : 'Are you sure?'),
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Cancel',
              style: Theme.of(ctx).textTheme.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? AppColors.error,
            ),
            child: Text(
              confirmLabel ?? 'Delete',
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: confirmColor ?? AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
