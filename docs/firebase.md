# Firebase Integration & Abstraction

## 1. Project Configuration
- Connected to Firebase Project: **queenapp-37ad1**
- Android App ID: `1:274760210299:android:3bf4e550baece3433f0fde`
- iOS App ID: `1:274760210299:ios:4b5234855232675a3f0fde`
- Existing `lib/firebase_options.dart` and `android/app/google-services.json` are preserved.

## 2. Exactly-Once Initialization
`FirebaseService.initialize()` in `lib/core/firebase/firebase_service.dart`:
- Verifies if Firebase is already initialized before executing `Firebase.initializeApp()`.
- Wires up fatal Flutter errors to `FirebaseCrashlytics.instance.recordFlutterFatalError`.
- Wires up asynchronous uncaught errors via `PlatformDispatcher.instance.onError`.

## 3. Service Abstractions
The presentation and domain layers never import Firebase directly. Instead, they interact with clean service interfaces:

- **`CrashlyticsService` (`crashlytics_service.dart`):**
  - `recordError()`, `recordFlutterError()`, `log()`, `setUserId()`, `setCustomKey()`.
- **`MessagingService` (`messaging_service.dart`):**
  - Push notification permissions, token retrieval, token refresh stream, foreground messages stream, notification tap listeners.
- **`FirestoreService` (`firestore_service.dart`):**
  - Document read/write/update/delete, document/collection streaming, collection queries.
- **`AnalyticsService` (`analytics_service.dart`):**
  - Event logging, screen tracking, user ID assignment.
