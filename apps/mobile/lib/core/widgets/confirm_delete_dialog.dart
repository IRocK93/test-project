import 'package:baby_mon/l10n/l10n_ext.dart';
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
          title ?? (itemType != null ? '${context.l10n.deleteLabel} $itemType' : context.l10n.confirmDelete),
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        content: Text(
          message ??
              (itemType != null
                  ? context.l10n.confirmDeleteItem(itemType)
                  : context.l10n.confirmDeleteDefault),
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.onSurfaceVariant,
            ),
            child: Text(
              context.l10n.cancelLabel,
              style: Theme.of(ctx).textTheme.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? context.colorScheme.error,
            ),
            child: Text(
              confirmLabel ?? context.l10n.deleteLabel,
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: confirmColor ?? context.colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
