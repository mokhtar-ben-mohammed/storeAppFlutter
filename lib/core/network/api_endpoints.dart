/// Centralized API endpoint constants.
class ApiEndpoints {
  const ApiEndpoints._();

  // Authentication
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String deleteAccount = '/auth/account';
  static const String refreshToken = '/auth/refresh';

  // Home & Catalog
  static const String home = '/home';
  static const String catalogChannels = '/catalog/channels';
  static String channelProducts(String slug) => '/catalog/channels/$slug/products';
  static String productDetail(String productId) =>
      '/catalog/products/${Uri.encodeComponent(productId)}';

  // Commerce
  static const String favorites = '/favorites';
  static String favoriteById(String productId) =>
      '/favorites/${Uri.encodeComponent(productId)}';
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(int id) => '/cart/items/$id';

  // Geography
  static const String countries = '/countries';

  // Finance
  static const String currencies = '/currencies';

  // Platform content
  static const String contentPages = '/content-pages';

  // Legacy placeholders
  static const String products = '/products';
  static const String categories = '/categories';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String notifications = '/notifications';
}
