import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:store/core/localization/app_locales.dart';

/// Extension helpers on [BuildContext] for responsive measurements and localization.
extension ContextExtensions on BuildContext {
  // Localization
  Locale get currentLocale => locale;
  bool get isRtl => AppLocales.isRtl(locale);
  bool get isLtr => !isRtl;

  // Media Query
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);
  EdgeInsets get screenViewInsets => MediaQuery.viewInsetsOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  // Platform brightness
  Brightness get platformBrightness => MediaQuery.platformBrightnessOf(this);
  bool get isDarkMode => platformBrightness == Brightness.dark;
}
