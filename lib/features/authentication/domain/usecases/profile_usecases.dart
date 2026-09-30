import 'package:equatable/equatable.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<UserEntity, NoParams> {
  const GetProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserEntity>> call(NoParams params) {
    return _repository.getProfile();
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    this.name,
    this.cityId,
    this.currencyId,
    this.gender,
  });

  final String? name;
  final int? cityId;
  final int? currencyId;
  final String? gender;

  @override
  List<Object?> get props => [name, cityId, currencyId, gender];
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      name: params.name,
      cityId: params.cityId,
      currencyId: params.currencyId,
      gender: params.gender,
    );
  }
}

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.deleteAccount();
  }
}
