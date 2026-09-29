# Testing Guide

## 1. Principles
- Tests do not require real APIs, live Firebase, or network connectivity.
- Architecture facilitates full mocking via `mocktail` and `bloc_test`.

## 2. Test Suite Structure
```text
test/
├── core/
│   └── storage/
│       └── local_storage_service_test.dart  # Utility / Service unit test
├── features/
│   └── authentication/
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart # Repository offline & caching behavior
│       ├── domain/
│       │   └── usecases/
│       │       └── verify_otp_usecase_test.dart   # Domain business logic & validation test
│       └── presentation/
│           └── cubits/
│               └── auth_cubit_test.dart           # BLoC / Cubit state transition test
└── widget_test.dart                               # Constants smoke test
```

## 3. Running Tests
Run the entire unit test suite:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```
