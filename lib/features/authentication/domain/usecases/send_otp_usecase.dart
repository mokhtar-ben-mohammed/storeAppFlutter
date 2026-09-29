import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class SendOtpParams extends Equatable {
  const SendOtpParams(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class SendOtpUseCase implements UseCase<bool, SendOtpParams> {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(SendOtpParams params) async {
    final cleanPhone = params.phone.trim();
    if (cleanPhone.isEmpty || cleanPhone.length < 8) {
      return const Result.failure(ValidationFailure('Please enter a valid phone number.'));
    }
    return _repository.sendOtp(cleanPhone);
  }
}
