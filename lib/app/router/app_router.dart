import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/authentication/presentation/pages/login_page.dart';
import 'package:store/features/authentication/presentation/pages/otp_page.dart';
import 'package:store/features/authentication/presentation/pages/splash_page.dart';
import 'package:store/features/authentication/presentation/pages/welcome_page.dart';
import 'package:store/app/router/main_scaffold.dart';
import 'package:store/core/widgets/bottom_nav.dart';
import 'package:store/features/cart/presentation/pages/cart_page.dart';
import 'package:store/features/checkout/presentation/pages/checkout_page.dart';
import 'package:store/features/favorites/presentation/pages/favorites_page.dart';
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

/// Central routing configuration with auth gate and deep-linking support.
class AppRouter {
  AppRouter({required this.authCubit});

  final AuthCubit authCubit;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      final location = state.uri.path;
      final isGateRoute = location == AppRoutes.splash ||
          location == AppRoutes.welcome ||
          location == AppRoutes.login ||
          location == AppRoutes.otp;

      if (authState is AuthInitial || authState is AuthLoading) {
        if (location != AppRoutes.splash && !isGateRoute) {
          return AppRoutes.splash;
        }
        return null;
      }

      final canBrowse = authState is Authenticated || authState is GuestBrowsing;

      if (canBrowse) {
        if (location == AppRoutes.splash ||
            location == AppRoutes.welcome ||
            location == AppRoutes.login) {
          return AppRoutes.home;
        }
        return null;
      }

      // Unauthenticated / failure → keep on gate routes only
      if (!isGateRoute) {
        return AppRoutes.welcome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const MainScaffold(initialTab: MainTab.home),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'login';
          return LoginPage(isRegister: mode == 'register');
        },
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: AppRoutes.otpName,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final countryCode = state.uri.queryParameters['country_code'] ?? '+967';
          final isRegister = state.uri.queryParameters['is_register'] == 'true';
          return OtpPage(
            phone: phone,
            countryCode: countryCode,
            isRegister: isRegister,
          );
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
