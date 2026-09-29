import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';

/// Sealed class representing the outcome of an operation.
sealed class Result<T> extends Equatable {
  const Result();

  /// Creates a successful result holding [data].
  const factory Result.ok(T data) = Ok<T>;

  /// Creates a failed result holding [failure].
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// Returns `true` if this result is a success.
  bool get isSuccess => this is Ok<T>;

  /// Returns `true` if this result is a failure.
  bool get isFailure => this is FailureResult<T>;

  /// Returns the data if successful, or null otherwise.
  T? get dataOrNull => switch (this) {
        Ok<T>(data: final data) => data,
        FailureResult<T>() => null,
      };

  /// Returns the failure if failed, or null otherwise.
  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        FailureResult<T>(failure: final failure) => failure,
      };

  /// Pattern matching fold over success and failure outcomes.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Ok<T>(data: final data) => onSuccess(data),
      FailureResult<T>(failure: final failure) => onFailure(failure),
    };
  }

  /// Transforms the success value [T] to [R].
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Ok<T>(data: final data) => Result.ok(transform(data)),
      FailureResult<T>(failure: final failure) => Result.failure(failure),
    };
  }
}

/// Success variant of [Result].
final class Ok<T> extends Result<T> {
  const Ok(this.data);

  final T data;

  @override
  List<Object?> get props => [data];

  @override
  String toString() => 'Result.ok($data)';
}

/// Failure variant of [Result].
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'Result.failure($failure)';
}
