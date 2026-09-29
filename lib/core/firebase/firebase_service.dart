import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:store/core/logging/app_logger.dart';
import 'package:store/firebase_options.dart';

/// Central initializer for Firebase services.
/// Ensures Firebase is initialized exactly once with Queen/Burhan project configuration.
class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.warning('Firebase is already initialized. Skipping.');
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isInitialized = true;
      AppLogger.info('Firebase initialized successfully for Queen/Burhan project.');

      // Setup Crashlytics error handlers for Flutter & async errors
      if (!kIsWeb) {
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (e, st) {
      AppLogger.error('Firebase initialization failed', error: e, stackTrace: st);
    }
  }
}
