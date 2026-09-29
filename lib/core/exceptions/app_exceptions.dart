/// Base exception class for the application.
class AppException implements Exception {
  const AppException(this.message, [this.statusCode, this.code]);

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => '$runtimeType: $message (code: $code, status: $statusCode)';
}

/// Thrown when server responds with an error payload or status code >= 400.
class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode, super.code]);
}

/// Thrown when there is no internet connection or network request times out.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred', super.statusCode, super.code]);
}

/// Thrown when authentication fails (invalid credentials, expired token, unauthorized).
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.statusCode, super.code]);
}

/// Thrown when local storage read/write operation fails.
class CacheException extends AppException {
  const CacheException(super.message, [super.statusCode, super.code]);
}

/// Thrown when request payload or user input validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message, [super.statusCode, super.code]);
}
