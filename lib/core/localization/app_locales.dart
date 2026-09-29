import 'package:flutter/material.dart';

/// Supported locales and language codes in Burhan app.
class AppLocales {
  AppLocales._();

  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  static const List<Locale> supportedLocales = [
    arabic,
    english,
  ];

  static const Locale defaultLocale = arabic;

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}
