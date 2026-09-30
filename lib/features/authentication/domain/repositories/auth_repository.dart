import 'package:store/core/utils/result.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';

/// Contract for authentication operations and session state.
abstract interface class AuthRepository {
  /// Request a 6-digit OTP for [phone] under [countryCode].
  Future<Result<bool>> sendOtp({
    required String countryCode,
    required String phone,
  });

  /// Verify the 6-digit [otp] and establish session.
  Future<Result<AuthSessionEntity>> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
  });

  /// Terminate the active session and clear local credentials.
  Future<Result<void>> logout();

  /// Retrieve active session if present.
  Future<Result<AuthSessionEntity?>> getCurrentSession();

  /// Check whether an authenticated session currently exists.
  Future<Result<bool>> isAuthenticated();
}
