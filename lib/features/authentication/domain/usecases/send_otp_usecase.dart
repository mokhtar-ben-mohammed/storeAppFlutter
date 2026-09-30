import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class SendOtpParams extends Equatable {
  const SendOtpParams({
    required this.countryCode,
    required this.phone,
  });

  final String countryCode;
  final String phone;

  @override
  List<Object?> get props => [countryCode, phone];
}

class SendOtpUseCase implements UseCase<bool, SendOtpParams> {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(SendOtpParams params) async {
    final cleanCode = params.countryCode.trim();
    final cleanPhone = params.phone.trim();

    if (cleanCode.isEmpty) {
      return const Result.failure(ValidationFailure('Please select a country code.'));
    }

    if (cleanPhone.isEmpty || cleanPhone.length < 8) {
      return const Result.failure(ValidationFailure('Please enter a valid phone number.'));
    }

    return _repository.sendOtp(countryCode: cleanCode, phone: cleanPhone);
  }
}
