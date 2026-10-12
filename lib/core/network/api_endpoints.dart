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

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(int id) => '/addresses/$id';
  static String addressDefault(int id) => '/addresses/$id/default';

  // Commerce
  static const String favorites = '/favorites';
  static String favoriteById(String productId) =>
      '/favorites/${Uri.encodeComponent(productId)}';
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(int id) => '/cart/items/$id';

  // Checkout
  static const String checkoutServices = '/checkout/services';
  static const String checkoutShippingOptions = '/checkout/shipping-options';
  static const String checkoutPaymentMethods = '/checkout/payment-methods';
  static const String checkoutPreview = '/checkout/preview';

  // Geography
  static const String countries = '/countries';

  // Finance
  static const String currencies = '/currencies';

  // Platform content
  static const String contentPages = '/content-pages';

  static String orderById(int id) => '/orders/$id';
  static const String orderStatuses = '/order-statuses';

  // Notifications / FCM
  static const String deviceTokens = '/device-tokens';
  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';

  static const String chatSession = '/chats/session';
  static const String chatUnreadCount = '/chats/unread-count';
  static const String chatConversations = '/chats/conversations';
  static String chatConversation(String id) => '/chats/conversations/$id';
  static String chatMessages(String id) => '/chats/conversations/$id/messages';
  static String chatRead(String id) => '/chats/conversations/$id/read';
  static String chatLocales(String id) => '/chats/conversations/$id/locales';

  // Legacy placeholders
  static const String products = '/products';
  static const String categories = '/categories';
  static const String orders = '/orders';
}
