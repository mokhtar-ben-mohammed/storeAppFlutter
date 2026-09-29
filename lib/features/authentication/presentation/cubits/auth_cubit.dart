import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:store/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:store/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:store/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

/// Cubit orchestrating presentation state for authentication flows.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.getCurrentSessionUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial());

  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;

  /// Restores active session on app startup.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading(message: 'Checking session...'));
    final result = await getCurrentSessionUseCase(const NoParams());

    result.fold(
      onSuccess: (session) {
        if (session != null) {
          emit(Authenticated(session));
        } else {
          emit(const Unauthenticated());
        }
      },
      onFailure: (failure) => emit(AuthFailure(failure)),
    );
  }

  /// Sends 6-digit OTP to the specified phone number.
  Future<void> sendOtp(String phone) async {
    emit(const AuthLoading(message: 'Sending OTP...'));
    final result = await sendOtpUseCase(SendOtpParams(phone));

    result.fold(
      onSuccess: (_) => emit(AuthOtpSent(phone: phone)),
      onFailure: (failure) => emit(AuthFailure(failure)),
    );
  }

  /// Verifies OTP code and transitions to [Authenticated].
  Future<void> verifyOtp({required String phone, required String otp}) async {
    emit(const AuthLoading(message: 'Verifying OTP...'));
    final result = await verifyOtpUseCase(VerifyOtpParams(phone: phone, otp: otp));

    result.fold(
      onSuccess: (session) => emit(Authenticated(session)),
      onFailure: (failure) => emit(AuthFailure(failure)),
    );
  }

  /// Logs out the user and clears state to [Unauthenticated].
  Future<void> logout() async {
    emit(const AuthLoading(message: 'Logging out...'));
    final result = await logoutUseCase(const NoParams());

    result.fold(
      onSuccess: (_) => emit(const Unauthenticated()),
      onFailure: (failure) => emit(AuthFailure(failure)),
    );
  }
}
