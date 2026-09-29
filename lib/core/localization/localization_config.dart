import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:store/core/constants/app_constants.dart';
import 'package:store/core/localization/app_locales.dart';

/// Configuration and widget wrapper for [EasyLocalization].
class LocalizationConfig {
  LocalizationConfig._();

  static const String path = AppConstants.translationsPath;
  static const Locale fallbackLocale = AppLocales.arabic;
  static const Locale startLocale = AppLocales.arabic;

  /// Wraps [child] with [EasyLocalization].
  static Widget wrap({required Widget child}) {
    return EasyLocalization(
      supportedLocales: AppLocales.supportedLocales,
      path: path,
      fallbackLocale: fallbackLocale,
      startLocale: startLocale,
      useOnlyLangCode: true,
      child: child,
    );
  }
}
