# Environment Configuration Guide

## 1. Supported Environments
The application separates configuration from source code using `EnvConfig`:

| Environment | Base URL | API Version | Debug Mode | Logging |
|---|---|---|---|---|
| **Development** | `https://dev-api.burhan.app` | `v1` | `true` | `true` |
| **Staging** | `https://staging-api.burhan.app` | `v1` | `true` | `true` |
| **Production** | `https://api.burhan.app` | `v1` | `false` | `false` |

## 2. Bootstrapping with Specific Environment
Pass the desired preset into `bootstrap()`:

```dart
// Development
await bootstrap(envConfig: EnvConfig.development());

// Staging
await bootstrap(envConfig: EnvConfig.staging());

// Production
await bootstrap(envConfig: EnvConfig.production());
```

## 3. Secret Management & Safety
- Never check production API keys or tokens into source control.
- `AppLogger` automatically redacts sensitive query parameters, tokens, and passwords (`***REDACTED***`).
- Release builds automatically disable diagnostic HTTP payload logging.
