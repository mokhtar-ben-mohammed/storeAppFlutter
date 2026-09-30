import 'package:equatable/equatable.dart';
import 'package:store/core/constants/app_constants.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({
    required this.countryCode,
    required this.phone,
    required this.otp,
  });

  final String countryCode;
  final String phone;
  final String otp;

  @override
  List<Object?> get props => [countryCode, phone, otp];
}

class VerifyOtpUseCase implements UseCase<AuthSessionEntity, VerifyOtpParams> {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSessionEntity>> call(VerifyOtpParams params) async {
    final cleanCode = params.countryCode.trim();
    final cleanPhone = params.phone.trim();
    final cleanOtp = params.otp.trim();

    if (cleanCode.isEmpty) {
      return const Result.failure(ValidationFailure('Country code is required.'));
    }

    if (cleanPhone.isEmpty) {
      return const Result.failure(ValidationFailure('Phone number is required.'));
    }

    if (cleanOtp.length != AppConstants.otpLength) {
      return const Result.failure(
        ValidationFailure('Verification code must be 6 digits.'),
      );
    }

    return _repository.verifyOtp(
      countryCode: cleanCode,
      phone: cleanPhone,
      otp: cleanOtp,
    );
  }
}
