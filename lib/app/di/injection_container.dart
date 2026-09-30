import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/app/config/app_config.dart';
import 'package:store/app/config/env_config.dart';
import 'package:store/app/router/app_router.dart';
import 'package:store/core/firebase/analytics_service.dart';
import 'package:store/core/firebase/crashlytics_service.dart';
import 'package:store/core/firebase/firestore_service.dart';
import 'package:store/core/firebase/messaging_service.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/storage/local_storage_service_impl.dart';
import 'package:store/core/theme/theme_cubit.dart';
import 'package:store/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:store/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';
import 'package:store/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:store/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:store/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:store/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/geography/data/datasources/geography_remote_data_source.dart';
import 'package:store/features/geography/data/repositories/geography_repository_impl.dart';
import 'package:store/features/geography/domain/repositories/geography_repository.dart';
import 'package:store/features/geography/domain/usecases/get_countries_usecase.dart';

final GetIt sl = GetIt.instance;

/// Centralized dependency injection initialization.
Future<void> initDependencies({
  required SharedPreferences sharedPreferences,
  EnvConfig? envConfig,
}) async {
  final activeEnvConfig = envConfig ?? AppConfig.current;

  // 1. Environment Config
  sl.registerSingleton<EnvConfig>(activeEnvConfig);

  // 2. Storage
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<LocalStorageService>(
    LocalStorageServiceImpl(sl<SharedPreferences>()),
  );

  // 3. Network
  sl.registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      envConfig: sl<EnvConfig>(),
      storageService: sl<LocalStorageService>(),
    ),
  );

  // 4. Firebase Services
  if (!kIsWeb) {
    sl.registerLazySingleton<CrashlyticsService>(
      () => CrashlyticsServiceImpl(FirebaseCrashlytics.instance),
    );
  }
  sl.registerLazySingleton<MessagingService>(
    () => MessagingServiceImpl(FirebaseMessaging.instance),
  );
  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreServiceImpl(FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsServiceImpl(FirebaseAnalytics.instance),
  );

  // 5. Authentication Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      storageService: sl<LocalStorageService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<SendOtpUseCase>(
    () => SendOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentSessionUseCase>(
    () => GetCurrentSessionUseCase(sl<AuthRepository>()),
  );
  // Singleton so AppRouter redirect and UI share the same auth stream.
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      getCurrentSessionUseCase: sl<GetCurrentSessionUseCase>(),
      sendOtpUseCase: sl<SendOtpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      storageService: sl<LocalStorageService>(),
    ),
  );

  // 6. Geography Feature
  sl.registerLazySingleton<GeographyRemoteDataSource>(
    () => GeographyRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<GeographyRepository>(
    () => GeographyRepositoryImpl(
      remoteDataSource: sl<GeographyRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<GetCountriesUseCase>(
    () => GetCountriesUseCase(sl<GeographyRepository>()),
  );

  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<LocalStorageService>()),
  );

  // 7. Router
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(authCubit: sl<AuthCubit>()),
  );
}
