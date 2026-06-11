import 'package:flutter/material.dart';

class SnackBarHelper {
  SnackBarHelper._();

  static const Duration _successDuration = Duration(seconds: 2);
  static const Duration _infoDuration = Duration(seconds: 3);
  static const Duration _warningDuration = Duration(seconds: 4);
  static const Duration _errorDuration = Duration(seconds: 4);
  static const Duration _undoDuration = Duration(seconds: 2);

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      duration: _successDuration,
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
    );
  }

  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      duration: _errorDuration,
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      duration: _warningDuration,
      backgroundColor: const Color(0xFFE65100),
      foregroundColor: Colors.white,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      duration: _infoDuration,
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
    );
  }

  static void showUndo(
    BuildContext context,
    String message, {
    required String undoLabel,
    required VoidCallback onUndo,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.undo_rounded, color: cs.onPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: cs.onPrimary),
              ),
            ),
          ],
        ),
        duration: _undoDuration,
        behavior: theme.snackBarTheme.behavior ?? SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: theme.snackBarTheme.shape,
        backgroundColor: cs.primary,
        action: SnackBarAction(
          label: undoLabel,
          textColor: cs.onPrimary.withAlpha(200),
          onPressed: onUndo,
        ),
      ),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Duration duration,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foregroundColor),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: theme.snackBarTheme.behavior ?? SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: theme.snackBarTheme.shape,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
