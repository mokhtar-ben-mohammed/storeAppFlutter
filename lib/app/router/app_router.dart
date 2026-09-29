import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/authentication/presentation/pages/login_page.dart';
import 'package:store/features/authentication/presentation/pages/otp_page.dart';
import 'package:store/features/cart/presentation/pages/cart_page.dart';
import 'package:store/features/checkout/presentation/pages/checkout_page.dart';
import 'package:store/features/favorites/presentation/pages/favorites_page.dart';
import 'package:store/features/home/presentation/pages/home_page.dart';
import 'package:store/features/notifications/presentation/pages/notifications_page.dart';
import 'package:store/features/orders/presentation/pages/orders_page.dart';
import 'package:store/features/products/presentation/pages/products_page.dart';
import 'package:store/features/profile/presentation/pages/profile_page.dart';

/// Adapter converting a Stream to a [ChangeNotifier] for [GoRouter.refreshListenable].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central routing configuration with auth guard and deep-linking support.
class AppRouter {
  AppRouter({required this.authCubit});

  final AuthCubit authCubit;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      final location = state.uri.path;
      final isLoggingIn = location == AppRoutes.login || location == AppRoutes.otp;

      // When authentication state is confirmed
      if (authState is Authenticated) {
        // Redirect authenticated users away from login pages
        if (isLoggingIn) return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: AppRoutes.otpName,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpPage(phone: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.products,
        name: AppRoutes.productsName,
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: AppRoutes.cartName,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRoutes.checkoutName,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: AppRoutes.ordersName,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: AppRoutes.favoritesName,
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
