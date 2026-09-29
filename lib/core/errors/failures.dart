import 'package:equatable/equatable.dart';

/// Base Failure class representing domain-level errors.
abstract class Failure extends Equatable {
  const Failure(this.message, [this.statusCode, this.code]);

  final String message;
  final int? statusCode;
  final String? code;

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode, code: $code)';
}

/// Represents failure originating from server/API responses.
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode, super.code]);
}

/// Represents network connectivity failures (offline, connection lost, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.statusCode, super.code]);
}

/// Represents failures in authentication/session state.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.statusCode, super.code]);
}

/// Represents validation errors (e.g. invalid phone number, invalid OTP).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.statusCode, super.code]);
}

/// Represents local persistence/cache failures.
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.statusCode, super.code]);
}

/// Represents unexpected or unhandled failures.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred', super.statusCode, super.code]);
}
