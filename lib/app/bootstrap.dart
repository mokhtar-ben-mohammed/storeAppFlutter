import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/app/app.dart';
import 'package:store/app/config/app_config.dart';
import 'package:store/app/config/env_config.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/core/firebase/firebase_service.dart';
import 'package:store/core/localization/localization_config.dart';
import 'package:store/core/logging/app_logger.dart';

/// Central application bootstrapper.
/// Orchestrates startup sequence deterministically before rendering UI.
Future<void> bootstrap({EnvConfig? envConfig}) async {
  // 1. Ensure Flutter widget bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize environment configuration
  final config = envConfig ?? EnvConfig.development();
  AppConfig.initialize(config);

  // 3. Initialize logging with environment settings
  AppLogger.initialize(isDebug: config.isDebug);
  AppLogger.info('Starting Burhan App in ${config.environment.name} mode');

  // 4. Initialize Firebase (Queen/Burhan configuration)
  await FirebaseService.initialize();

  // 5. Initialize local preferences storage (SharedPreferences)
  final sharedPreferences = await SharedPreferences.getInstance();

  // 6. Initialize Dependency Injection with GetIt
  await initDependencies(
    sharedPreferences: sharedPreferences,
    envConfig: config,
  );

  // 7. Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // 8. Run App with Localization wrapper
  runApp(
    LocalizationConfig.wrap(
      child: const BurhanApp(),
    ),
  );
}
