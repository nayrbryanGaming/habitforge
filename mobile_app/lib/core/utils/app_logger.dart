import 'package:flutter/foundation.dart';

/// A production-safe logging utility for HabitForge.
/// Ensures logs are only visible during development and never leak to release builds.
class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      print('DEBUG: [HabitForge] $message');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('ERROR: [HabitForge] $message');
      if (error != null) print('DETAILS: $error');
      if (stackTrace != null) print('STACK: $stackTrace');
    }
    // In production, you would send this to Sentry/Firebase Crashlytics here.
  }

  static void i(String message) {
    if (kDebugMode) {
      print('INFO: [HabitForge] $message');
    }
  }
}
