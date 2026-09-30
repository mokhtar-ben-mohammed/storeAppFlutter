/// Supported environment modes.
enum Environment {
  development,
  staging,
  production;

  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;
}

/// Environment configuration contract and presets.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.baseUrl,
    required this.apiVersion,
    required this.isDebug,
    required this.enableLogging,
  });

  final Environment environment;
  final String baseUrl;
  final String apiVersion;
  final bool isDebug;
  final bool enableLogging;

  String get fullApiUrl => '$baseUrl/$apiVersion';

  /// Development environment preset.
  factory EnvConfig.development() {
    return const EnvConfig(
      environment: Environment.development,
      baseUrl: 'http://192.168.8.231:8000/api',
      apiVersion: 'v1',
      isDebug: true,
      enableLogging: true,
    );
  }

  /// Staging environment preset.
  factory EnvConfig.staging() {
    return const EnvConfig(
      environment: Environment.staging,
      baseUrl: 'https://staging-api.burhan.app',
      apiVersion: 'v1',
      isDebug: true,
      enableLogging: true,
    );
  }

  /// Production environment preset.
  factory EnvConfig.production() {
    return const EnvConfig(
      environment: Environment.production,
      baseUrl: 'https://api.burhan.app',
      apiVersion: 'v1',
      isDebug: false,
      enableLogging: false,
    );
  }
}
