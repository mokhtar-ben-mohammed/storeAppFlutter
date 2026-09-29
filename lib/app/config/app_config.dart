import 'package:store/app/config/env_config.dart';

/// Holds the runtime active configuration for the application.
class AppConfig {
  AppConfig._();

  static late final EnvConfig _current;

  static void initialize(EnvConfig config) {
    _current = config;
  }

  static EnvConfig get current => _current;

  static Environment get environment => _current.environment;
  static String get baseUrl => _current.baseUrl;
  static String get apiVersion => _current.apiVersion;
  static String get fullApiUrl => _current.fullApiUrl;
  static bool get isDebug => _current.isDebug;
  static bool get enableLogging => _current.enableLogging;
}
