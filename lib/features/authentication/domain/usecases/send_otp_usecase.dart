import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/registration_draft.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class SendOtpParams extends Equatable {
  const SendOtpParams({
    required this.countryCode,
    required this.phone,
    this.intent = 'login',
    this.registration,
  });

  final String countryCode;
  final String phone;
  final String intent;
  final RegistrationDraft? registration;

  @override
  List<Object?> get props => [countryCode, phone, intent, registration];
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

    if (cleanPhone.isEmpty || cleanPhone.length < 7) {
      return const Result.failure(ValidationFailure('Please enter a valid phone number.'));
    }

    if (params.intent == 'register') {
      final draft = params.registration;
      if (draft == null || draft.name.trim().isEmpty) {
        return const Result.failure(ValidationFailure('يرجى إدخال الاسم الكامل.'));
      }
      if (draft.cityId < 1) {
        return const Result.failure(ValidationFailure('يرجى اختيار المدينة.'));
      }
      if (draft.gender != 'male' && draft.gender != 'female') {
        return const Result.failure(ValidationFailure('يرجى اختيار الجنس.'));
      }
    }

    return _repository.sendOtp(
      countryCode: cleanCode,
      phone: cleanPhone,
      intent: params.intent,
    );
  }
}
