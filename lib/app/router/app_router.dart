import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/authentication/presentation/pages/login_page.dart';
import 'package:store/features/authentication/presentation/pages/otp_page.dart';
import 'package:store/features/authentication/presentation/pages/splash_page.dart';
import 'package:store/app/router/main_scaffold.dart';
import 'package:store/core/widgets/bottom_nav.dart';
import 'package:store/features/cart/presentation/pages/cart_page.dart';
import 'package:store/features/checkout/presentation/pages/checkout_page.dart';
import 'package:store/features/favorites/presentation/pages/favorites_page.dart';
import 'package:store/features/notifications/presentation/pages/notifications_page.dart';
import 'package:store/features/orders/presentation/pages/orders_page.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';
import 'package:store/features/products/presentation/pages/products_page.dart';
import 'package:store/features/products/presentation/pages/store_products_page.dart';
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
          location == AppRoutes.login ||
          location == AppRoutes.otp;

      // 1. NEVER redirect away while on the splash screen!
      // SplashPage will show its animation and navigate after session check.
      if (location == AppRoutes.splash) {
        return null;
      }

      if (authState is AuthInitial || authState is AuthLoading) {
        if (!isGateRoute) {
          return AppRoutes.splash;
        }
        return null;
      }

      final canBrowse = authState is Authenticated || authState is GuestBrowsing;

      // 2. If user is authenticated or chose guest browsing while on login, send to home
      if (canBrowse) {
        if (location == AppRoutes.login) {
          return AppRoutes.home;
        }
        return null;
      }

      // 3. Unauthenticated / failure → keep on gate routes (direct to login)
      if (!isGateRoute) {
        return AppRoutes.login;
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
        builder: (context, state) {
          final initialStore = state.uri.queryParameters['store'] ?? 'all';
          return ProductsPage(initialStore: initialStore);
        },
      ),
      GoRoute(
        path: AppRoutes.storeProducts,
        name: AppRoutes.storeProductsName,
        builder: (context, state) {
          final storeId = state.uri.queryParameters['store'] ?? '1688';
          return StoreProductsPage(storeId: storeId);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: AppRoutes.productDetailsName,
        builder: (context, state) {
          final product = state.extra as ProductEntity?;
          final productId =
              state.uri.queryParameters['id'] ?? product?.id;
          return ProductDetailsPage(
            product: product,
            productId: productId,
          );
        },
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
