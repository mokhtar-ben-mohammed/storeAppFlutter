import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logger abstraction with production-safe filtering and secret masking.
class AppLogger {
  AppLogger._();

  static bool _isDebug = kDebugMode;

  /// Configure logging mode (defaults to [kDebugMode]).
  static void initialize({bool isDebug = kDebugMode}) {
    _isDebug = isDebug;
  }

  /// Keys that must be masked to prevent leaking sensitive credentials.
  static final RegExp _sensitivePattern = RegExp(
    r'(password|token|otp|secret|authorization|refresh_token|access_token|credit_card|cvv)\s*[:=]\s*([^\s,;]+)',
    caseSensitive: false,
  );

  /// Sanitize messages containing sensitive parameters.
  static String sanitize(String message) {
    return message.replaceAllMapped(_sensitivePattern, (match) {
      final key = match.group(1);
      return '$key=***REDACTED***';
    });
  }

  /// Informational messages.
  static void info(String message, {String tag = 'APP', Object? error, StackTrace? stackTrace}) {
    if (!_isDebug) return;
    final sanitized = sanitize(message);
    developer.log('[INFO] $sanitized', name: tag, error: error, stackTrace: stackTrace);
  }

  /// Debug-only diagnostic messages.
  static void debug(String message, {String tag = 'DEBUG', Object? error, StackTrace? stackTrace}) {
    if (!_isDebug) return;
    final sanitized = sanitize(message);
    developer.log('[DEBUG] $sanitized', name: tag, error: error, stackTrace: stackTrace);
  }

  /// Warning messages (logged in both debug and release).
  static void warning(String message, {String tag = 'WARNING', Object? error, StackTrace? stackTrace}) {
    final sanitized = sanitize(message);
    developer.log('[WARNING] $sanitized', name: tag, level: 900, error: error, stackTrace: stackTrace);
  }

  /// Error messages (always logged, safe sanitized).
  static void error(
    String message, {
    String tag = 'ERROR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    final sanitized = sanitize(message);
    developer.log(
      '[ERROR] $sanitized',
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
