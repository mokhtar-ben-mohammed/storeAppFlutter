import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class GetCurrentSessionUseCase implements UseCase<AuthSessionEntity?, NoParams> {
  const GetCurrentSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSessionEntity?>> call(NoParams params) {
    return _repository.getCurrentSession();
  }
}
