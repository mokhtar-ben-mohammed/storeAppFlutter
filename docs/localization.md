# Localization Guide — EasyLocalization

## 1. Setup & Defaults
- Managed by `easy_localization`.
- **Default & Initial Language:** Arabic (`ar`).
- **Supported Locales:**
  - Arabic: `Locale('ar')` (RTL)
  - English: `Locale('en')` (LTR)
- **Path:** `assets/translations/` (`ar.json`, `en.json`).

## 2. Directionality & RTL Support
- Use `context.isRtl` or `context.isLtr` from `context_extensions.dart`.
- The root `MaterialApp.router` receives `localizationsDelegates`, `supportedLocales`, and `locale` from `BuildContext`.

## 3. Switching Language at Runtime
To change language anywhere in the UI:
```dart
await context.setLocale(AppLocales.english);
```
`LanguageInterceptor` automatically adds the active language code to the `Accept-Language` header on all outgoing HTTP requests.
