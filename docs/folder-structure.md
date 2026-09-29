# Folder Structure — Burhan Customer Mobile App

```text
lib/
├── app/
│   ├── app.dart                   # Root application widget (wrappers, router, theme)
│   ├── bootstrap.dart             # Deterministic application startup sequence
│   ├── config/
│   │   ├── app_config.dart        # Static active environment accessor
│   │   └── env_config.dart        # Environment modes (dev, staging, prod)
│   ├── di/
│   │   └── injection_container.dart # Centralized GetIt dependency registration
│   └── router/
│       ├── app_router.dart        # GoRouter configuration & auth redirect guard
│       └── app_routes.dart        # Named paths and route names
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # System timeouts, viewport base dimensions, OTP length
│   │   └── storage_keys.dart      # SharedPreferences key constants
│   ├── errors/
│   │   └── failures.dart          # Domain failure hierarchy (Server, Network, Auth, etc.)
│   ├── exceptions/
│   │   └── app_exceptions.dart    # Infrastructure exceptions
│   ├── extensions/
│   │   └── context_extensions.dart # BuildContext helpers (locale, RTL, screen dimensions)
│   ├── firebase/
│   │   ├── analytics_service.dart # Analytics abstraction & implementation
│   │   ├── crashlytics_service.dart# Crash reporting abstraction & implementation
│   │   ├── firebase_service.dart  # Exactly-once Firebase initialization
│   │   ├── firestore_service.dart # Firestore abstraction & implementation
│   │   └── messaging_service.dart # FCM notification abstraction & implementation
│   ├── localization/
│   │   ├── app_locales.dart       # Arabic (default), English, RTL helper
│   │   └── localization_config.dart # EasyLocalization wrapper setup
│   ├── logging/
│   │   └── app_logger.dart        # Centralized logger with sensitive data masking
│   ├── network/
│   │   ├── api_client.dart        # Dio wrapper (GET, POST, PUT, DELETE, timeouts)
│   │   ├── api_endpoints.dart     # Centralized backend URL routes
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart     # Injects Bearer token from local storage
│   │   │   ├── language_interceptor.dart # Injects Accept-Language header
│   │   │   └── logging_interceptor.dart  # Sanitized request/response logging
│   │   ├── network_exceptions.dart       # Maps DioException to domain Failures
│   │   └── network_info.dart             # Network connectivity check abstraction
│   ├── responsive/
│   │   └── responsive_layout.dart # ScreenUtil wrapper & device type categorization
│   ├── storage/
│   │   ├── local_storage_service.dart     # Abstract contract for key-value storage
│   │   └── local_storage_service_impl.dart# SharedPreferences implementation
│   ├── theme/
│   │   ├── app_theme_mode.dart    # light, dark, system modes
│   │   ├── theme_cubit.dart       # Theme state management & persistence
│   │   └── theme_state.dart       # Theme state representation
│   └── utils/
│       ├── result.dart            # Sealed Result<T> monad (Ok, FailureResult)
│       └── usecase.dart           # UseCase<T, Params> & NoParams contracts
│
├── features/
│   ├── authentication/            # Complete reference architecture implementation
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── auth_session_model.dart
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── auth_session_entity.dart
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_current_session_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       ├── send_otp_usecase.dart
│   │   │       └── verify_otp_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── otp_page.dart
│   │       └── widgets/
│   ├── home/                      # Feature structure placeholders for next phase
│   ├── products/
│   ├── cart/
│   ├── checkout/
│   ├── orders/
│   ├── profile/
│   ├── favorites/
│   └── notifications/
│
└── main.dart                      # Ultra-lean entry point delegating to bootstrap()
```
