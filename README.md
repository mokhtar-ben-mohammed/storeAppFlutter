# Burhan Customer Mobile App — Technical Foundation

Burhan is an enterprise-grade mobile commerce application built with Flutter, architected using **Clean Architecture**, **MVVM**, and **Feature-First** structure.

---

## 🛠 Architectural Foundation

- **Clean Architecture & MVVM:** Distinct separation between Presentation, Domain, Data, and Core layers.
- **State Management:** `flutter_bloc` / `bloc` (Cubit for feature states; strictly no Riverpod).
- **Dependency Injection:** `get_it` with lifecycle scopes (singletons, lazy singletons, factories) and constructor injection.
- **Networking:** `dio` wrapped inside `ApiClient` with auth, language, and logging interceptors.
- **Local Storage:** `shared_preferences` behind `LocalStorageService` abstraction (no extraneous database packages).
- **Localization:** `easy_localization` with **Arabic (default)** and English support, full RTL/LTR awareness.
- **Routing:** `go_router` with declarative routes, route parameters, and auth state redirection.
- **Firebase Platform:** Configured for `queenapp-37ad1` with abstractions for Core, Crashlytics, Cloud Messaging, Firestore, and Analytics.
- **Design System Agnostic:** Completely decoupled from Material Design assumptions; ready for Burhan's custom visual identity in Phase 2.
- **Responsive Utility:** `flutter_screenutil` technical wrapper (`ResponsiveWrapper`) without hardcoded visual styling locks.

---

## 📁 Project Structure

```text
lib/
├── app/               # Application configuration, DI, router, bootstrap, root widget
├── core/              # Cross-cutting concerns (network, storage, firebase, errors, logging)
├── features/          # Feature modules (authentication reference, home, products, cart, etc.)
└── main.dart          # Lean entry point delegating to bootstrap()
```

For complete structural details, see [`docs/folder-structure.md`](docs/folder-structure.md).

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK:** `>= 3.44.0` (Dart `>= 3.12.0`)
- **Android Studio / Xcode** configured for mobile deployment
- **Firebase CLI & FlutterFire CLI** (Project: `queenapp-37ad1`)

### Setup
```bash
# Clone the repository and install dependencies
flutter pub get
```

### Running the App
```bash
# Development mode
flutter run -t lib/main.dart

# Or target specific devices
flutter run -d chrome
flutter run -d <device_id>
```

---

## 🧪 Testing & Code Quality

### Run Unit Tests
```bash
flutter test
```

### Run Static Analysis
```bash
flutter analyze
```

---

## 📚 Technical Documentation

Detailed architectural and operational documentation can be found in the [`docs/`](docs/) directory:
- [Architecture Overview](docs/architecture.md)
- [Folder Structure](docs/folder-structure.md)
- [State Management (BLoC / Cubit)](docs/state-management.md)
- [Dependency Injection (GetIt)](docs/dependency-injection.md)
- [Firebase Integration](docs/firebase.md)
- [Localization & RTL](docs/localization.md)
- [Environment Configuration](docs/environments.md)
- [Testing Foundation](docs/testing.md)
