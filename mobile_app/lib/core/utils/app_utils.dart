import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../theme/app_colors.dart';
import 'app_logger.dart';

class AppUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  static Future<void> launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication)) {
        AppLogger.e('Could not launch $url');
      }
    } catch (e) {
      AppLogger.e('Error launching $url: $e');
    }
  }
}
