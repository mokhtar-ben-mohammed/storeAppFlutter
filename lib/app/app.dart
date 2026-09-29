import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/app/router/app_router.dart';
import 'package:store/core/constants/app_constants.dart';
import 'package:store/core/responsive/responsive_layout.dart';
import 'package:store/core/theme/theme_cubit.dart';
import 'package:store/core/theme/theme_state.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';

/// Root application widget for Burhan customer mobile application.
/// Houses the core technical wrappers (BLoC, Localization, Responsive, Router).
class BurhanApp extends StatelessWidget {
  const BurhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(
          value: sl<ThemeCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final appRouter = sl<AppRouter>();

          return ResponsiveWrapper(
            child: MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              // Localization delegates
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              // Theme mode (minimal technical bridge, visual styling agnostic)
              themeMode: themeState.mode.toFlutterThemeMode,
              theme: ThemeData(useMaterial3: false),
              darkTheme: ThemeData(useMaterial3: false, brightness: Brightness.dark),
              // Routing
              routerConfig: appRouter.router,
            ),
          );
        },
      ),
    );
  }
}
