/// Global application-level constants.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Burhan';
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;

  static const String defaultLanguage = 'ar';
  static const String translationsPath = 'assets/translations';

  // Responsive design base viewport dimensions (Figma reference canvas)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  // OTP constraints
  static const int otpLength = 6;
}
