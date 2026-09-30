/// Application route names and path constants.
class AppRoutes {
  const AppRoutes._();

  // Root / Home
  static const String home = '/';
  static const String homeName = 'home';

  // Auth routes (Public)
  static const String splash = '/splash';
  static const String splashName = 'splash';
  static const String welcome = '/welcome';
  static const String welcomeName = 'welcome';
  static const String login = '/login';
  static const String loginName = 'login';
  static const String otp = '/otp';
  static const String otpName = 'otp';

  // Feature routes (Protected/Private)
  static const String products = '/products';
  static const String productsName = 'products';
  static const String cart = '/cart';
  static const String cartName = 'cart';
  static const String checkout = '/checkout';
  static const String checkoutName = 'checkout';
  static const String orders = '/orders';
  static const String ordersName = 'orders';
  static const String profile = '/profile';
  static const String profileName = 'profile';
  static const String favorites = '/favorites';
  static const String favoritesName = 'favorites';
  static const String notifications = '/notifications';
  static const String notificationsName = 'notifications';

  /// Set of public routes accessible without authentication.
  static const Set<String> publicRoutes = {
    splash,
    welcome,
    login,
    otp,
  };
}
