# Architecture Guide — Burhan Customer Mobile App

## 1. Architectural Style
The project adheres strictly to **Clean Architecture** combined with **MVVM** and **Feature-First** packaging.

```
Presentation (Widgets / Pages)
       ↓
ViewModel / Cubit (Presentation State)
       ↓
Use Case (Domain Business Logic)
       ↓
Repository Interface (Domain Layer Contract)
       ↓
Repository Implementation (Data Layer)
       ↓
Data Source (Remote API / Local Preferences / Firebase)
```

## 2. Layer Responsibilities

### Presentation Layer
- **Pages & Widgets:** UI components consuming Cubits/Blocs.
- **Cubits:** Expose immutable states and orchestrate UseCases. Free of Direct API/Firebase calls.
- **Agnostic:** Free from hardcoded Material Design assumptions to accommodate Burhan's custom visual design system.

### Domain Layer
- **Entities:** Pure Dart domain models representing core business concepts (e.g. `UserEntity`, `AuthSessionEntity`).
- **Use Cases:** Encapsulate single units of business logic (e.g. `SendOtpUseCase`, `VerifyOtpUseCase`).
- **Repository Contracts:** Interfaces defining data operations without infrastructure details.
- **Failures & Result:** Type-safe error handling via `Result<T>` and `Failure` hierarchy.

### Data Layer
- **Models:** Serialized DTOs (Data Transfer Objects) extending domain entities with JSON mapping.
- **Data Sources:** Abstract contracts and implementations for network (`ApiClient`), local persistence (`LocalStorageService`), and cloud storage (`FirestoreService`).
- **Repositories:** Concrete implementations coordinating data sources, handling network failures, caching, and mapping exceptions to domain Failures.

### Core & Infrastructure Layer
- Houses cross-cutting concerns: `network`, `storage`, `firebase`, `localization`, `theme`, `logging`, `errors`, `responsive`, and `constants`.
- Everything in `core/` is decoupled behind interfaces for testability and maintainability.

## 3. Guiding Principles
- **Dependency Inversion Principle (DIP):** Presentation and domain layers depend upon abstractions, not concrete implementations.
- **Single Responsibility Principle (SRP):** Each class (UseCase, Cubit, DataSource, Repository) has one clearly defined responsibility.
- **Zero UI Coupling to Infrastructure:** Widgets never import Dio, SharedPreferences, or Firebase packages directly.
