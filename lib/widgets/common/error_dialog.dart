import 'package:flutter/material.dart';
import '../../core/utils/error_handler.dart';
import '../../core/constants/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required AppError error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ErrorDialog(error: error, onRetry: onRetry, onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getErrorColor(error.type).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  ErrorHandler.getErrorIcon(error.type),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error Title
            Text(
              _getErrorTitle(error.type),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Error Message
            Text(
              error.message,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Dismiss Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDismiss?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: colorScheme.onSurface.withAlpha(50),
                      ),
                    ),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Retry Button (if retryable)
                if (error.canRetry && onRetry != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.noInternet:
        return 'No Internet Connection';
      case ErrorType.poorConnection:
        return 'Slow Connection';
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.authentication:
        return 'Authentication Failed';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.validation:
        return 'Invalid Input';
      case ErrorType.timeout:
        return 'Request Timeout';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.unknown:
        return 'Oops!';
    }
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.noInternet:
        return Colors.red;
      case ErrorType.poorConnection:
        return Colors.orange;
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.timeout:
        return Colors.orange;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }
}
