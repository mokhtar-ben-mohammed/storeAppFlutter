# State Management Guide — BLoC & Cubit

## 1. Principles
- State management uses `flutter_bloc` and `bloc`.
- **Cubit** is preferred for standard feature states (loading, success, failure, data).
- **Bloc** is reserved for complex event-driven workflows with event transformations (throttling, debouncing).
- Riverpod is explicitly excluded.

## 2. Standard State Modeling
States are modeled as sealed classes or immutable Equatable hierarchies:

```dart
sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState { ... }
final class AuthLoading extends AuthState { ... }
final class Authenticated extends AuthState { ... }
final class Unauthenticated extends AuthState { ... }
final class AuthFailure extends AuthState { ... }
```

## 3. Cubit Guidelines
- **Constructor Injection:** Cubits receive UseCases through constructors.
- **No Direct Infrastructure Calls:** Never call `Dio`, `SharedPreferences`, or `Firebase` inside a Cubit.
- **Predictable States:** UseCases return `Result<T>`. Cubits fold results into UI states:
  ```dart
  final result = await _useCase(params);
  result.fold(
    onSuccess: (data) => emit(DataLoaded(data)),
    onFailure: (failure) => emit(FeatureFailure(failure)),
  );
  ```
- **Lifecycle:** Registered in GetIt as `factory` (for transient page-level Cubits) or `lazySingleton` (for app-wide state like `ThemeCubit`).
