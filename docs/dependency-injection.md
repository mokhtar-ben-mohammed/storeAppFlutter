# Dependency Injection Guide — GetIt

## 1. Centralized Registration
All application dependencies are registered inside `lib/app/di/injection_container.dart` via `initDependencies()`.

```dart
final sl = GetIt.instance;
```

## 2. Lifecycles & Scopes
- **Singleton (`registerSingleton`):** Used for instances initialized once during bootstrap:
  - `SharedPreferences`
  - `LocalStorageService`
  - `EnvConfig`
- **Lazy Singleton (`registerLazySingleton`):** Instantiated on first request and preserved:
  - `NetworkInfo`
  - `ApiClient`
  - `Firebase services` (Crashlytics, Messaging, Firestore, Analytics)
  - Data Sources (`AuthRemoteDataSource`)
  - Repositories (`AuthRepository`)
  - Use Cases (`SendOtpUseCase`, `VerifyOtpUseCase`, etc.)
  - `ThemeCubit`
  - `AppRouter`
- **Factory (`registerFactory`):** Created fresh on every access:
  - Feature Cubits (`AuthCubit`)

## 3. Dependency Inversion Rule
Widgets and classes must use **constructor injection** when receiving dependencies.
Do not scatter `sl<T>()` service-locator lookups within business logic, domain entities, or UI widgets.
