import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:store/core/logging/app_logger.dart';

/// Contract for application analytics tracking.
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setUserId(String? userId);
  Future<void> setCurrentScreen(String screenName);
}

/// Firebase Analytics implementation.
class AnalyticsServiceImpl implements AnalyticsService {
  AnalyticsServiceImpl(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      AppLogger.warning('Analytics logEvent error: $e', tag: 'ANALYTICS');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      AppLogger.warning('Analytics setUserId error: $e', tag: 'ANALYTICS');
    }
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      AppLogger.warning('Analytics setCurrentScreen error: $e', tag: 'ANALYTICS');
    }
  }
}
