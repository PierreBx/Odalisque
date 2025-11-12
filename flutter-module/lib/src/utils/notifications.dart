import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Enhanced notification system for user feedback.
class AppNotifications {
  static FToast? _fToast;

  /// Initialize toast for the given context.
  static void init(BuildContext context) {
    _fToast = FToast();
    _fToast!.init(context);
  }

  /// Show a success notification.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      context,
      message,
      Icons.check_circle,
      Colors.green,
      duration,
    );
  }

  /// Show an error notification.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showToast(
      context,
      message,
      Icons.error,
      Colors.red,
      duration,
    );
  }

  /// Show an info notification.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      context,
      message,
      Icons.info,
      Colors.blue,
      duration,
    );
  }

  /// Show a warning notification.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      context,
      message,
      Icons.warning,
      Colors.orange,
      duration,
    );
  }

  /// Show a loading notification (persists until dismissed).
  static void showLoading(
    BuildContext context,
    String message,
  ) {
    _showToast(
      context,
      message,
      Icons.hourglass_empty,
      Colors.grey,
      const Duration(days: 1), // Very long duration
    );
  }

  /// Dismiss any active toast.
  static void dismiss() {
    _fToast?.removeCustomToast();
  }

  static void _showToast(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
    Duration duration,
  ) {
    final fToast = FToast();
    fToast.init(context);

    final toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: duration,
    );
  }

  /// Show a custom SnackBar (alternative to toast).
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show success with a SnackBar.
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      action: action,
    );
  }

  /// Show error with a SnackBar.
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      action: action,
    );
  }
}

/// Loading overlay widget for blocking operations.
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    this.message,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Progress indicator with percentage.
class ProgressIndicatorWithLabel extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? color;

  const ProgressIndicatorWithLabel({
    super.key,
    required this.progress,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
