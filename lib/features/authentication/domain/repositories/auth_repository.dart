import 'package:store/core/utils/result.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/registration_draft.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<bool>> sendOtp({
    required String countryCode,
    required String phone,
    required String intent,
  });

  Future<Result<AuthSessionEntity>> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
    RegistrationDraft? registration,
  });

  Future<Result<void>> logout();

  Future<Result<AuthSessionEntity?>> getCurrentSession();

  Future<Result<bool>> isAuthenticated();

  Future<Result<UserEntity>> getProfile();

  Future<Result<UserEntity>> updateProfile({
    String? name,
    int? cityId,
    int? currencyId,
    String? gender,
  });

  Future<Result<void>> deleteAccount();
}
