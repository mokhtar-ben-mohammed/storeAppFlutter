/// Centralized API endpoint constants.
class ApiEndpoints {
  const ApiEndpoints._();

  // Authentication
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String refreshToken = '/auth/refresh';

  // Products & Home (Placeholders)
  static const String home = '/home';
  static const String products = '/products';
  static const String categories = '/categories';

  // Cart & Checkout (Placeholders)
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  // Orders (Placeholders)
  static const String orders = '/orders';

  // Notifications (Placeholders)
  static const String notifications = '/notifications';
}
