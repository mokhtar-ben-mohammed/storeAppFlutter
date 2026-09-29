import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:store/core/logging/app_logger.dart';

/// Centralized crash and error reporting abstraction.
abstract interface class CrashlyticsService {
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  });

  Future<void> recordFlutterError(FlutterErrorDetails details, {bool fatal = false});

  Future<void> log(String message);

  Future<void> setUserId(String userId);

  Future<void> setCustomKey(String key, Object value);
}

/// Firebase Crashlytics implementation.
class CrashlyticsServiceImpl implements CrashlyticsService {
  CrashlyticsServiceImpl(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    try {
      AppLogger.error('Crashlytics error recorded: $exception', error: exception, stackTrace: stack);
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (e, st) {
      AppLogger.error('Failed to report error to Crashlytics: $e', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details, {bool fatal = false}) async {
    try {
      await _crashlytics.recordFlutterError(details, fatal: fatal);
    } catch (e, st) {
      AppLogger.error('Failed to report Flutter error to Crashlytics: $e', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      final sanitized = AppLogger.sanitize(message);
      await _crashlytics.log(sanitized);
    } catch (e) {
      AppLogger.warning('Crashlytics log error: $e');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      AppLogger.warning('Crashlytics setUserId error: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      AppLogger.warning('Crashlytics setCustomKey error: $e');
    }
  }
}
