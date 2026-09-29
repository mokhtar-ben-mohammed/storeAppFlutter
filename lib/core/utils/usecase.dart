import 'package:equatable/equatable.dart';
import 'package:store/core/utils/result.dart';

/// Base contract for asynchronous use cases returning [Result].
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Base contract for streaming use cases returning [Stream] of [Result].
abstract interface class StreamUseCase<T, Params> {
  Stream<Result<T>> call(Params params);
}

/// Marker class used as parameter when a usecase requires no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
