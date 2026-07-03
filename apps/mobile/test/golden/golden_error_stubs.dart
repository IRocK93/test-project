import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';

/// Error banner widget for golden testing.
class GoldenErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const GoldenErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

/// Loading spinner overlay for golden testing.
class GoldenLoadingOverlay extends StatelessWidget {
  final String? message;
  const GoldenLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.5),
          if (message != null) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
