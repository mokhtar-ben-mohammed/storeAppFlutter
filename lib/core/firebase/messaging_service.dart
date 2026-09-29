import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:store/core/logging/app_logger.dart';

/// Contract for push notification messaging service.
abstract interface class MessagingService {
  Future<NotificationSettings> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Stream<RemoteMessage> get onForegroundMessage;
  Future<RemoteMessage?> getInitialMessage();
  void onMessageOpenedApp(void Function(RemoteMessage message) handler);
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
}

/// Firebase Cloud Messaging implementation.
class MessagingServiceImpl implements MessagingService {
  MessagingServiceImpl(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      AppLogger.info('Notification permission status: ${settings.authorizationStatus}', tag: 'FCM');
      return settings;
    } catch (e, st) {
      AppLogger.error('Failed to request notification permission', tag: 'FCM', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      AppLogger.info('FCM Token retrieved', tag: 'FCM');
      return token;
    } catch (e, st) {
      AppLogger.error('Failed to get FCM token', tag: 'FCM', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  @override
  void onMessageOpenedApp(void Function(RemoteMessage message) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      AppLogger.warning('Failed to subscribe to topic $topic: $e', tag: 'FCM');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      AppLogger.warning('Failed to unsubscribe from topic $topic: $e', tag: 'FCM');
    }
  }
}
