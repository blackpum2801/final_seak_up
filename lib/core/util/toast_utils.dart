import 'package:flutter/material.dart';

class ToastUtils {
  static void showToast(BuildContext context, String message,
      {Color backgroundColor = Colors.black87,
      Duration duration = const Duration(seconds: 2)}) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccessToast(BuildContext context, String message) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorToast(BuildContext context, String message) {
    showToast(context, message, backgroundColor: Colors.red);
  }

  static void showProgressToastAndNavigate(
    BuildContext context,
    String message,
    Duration duration,
    VoidCallback onComplete,
  ) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ],
      ),
      duration: duration,
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Future.delayed(duration, onComplete);
  }
}
