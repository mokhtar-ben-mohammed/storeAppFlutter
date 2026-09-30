import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/storage/local_storage_service.dart';
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
    required this.storageService,
  }) : super(const AuthInitial());

  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final LocalStorageService storageService;

  /// Restores active session or guest browsing on app startup.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading(message: 'Checking session...'));
    final result = await getCurrentSessionUseCase(const NoParams());

    if (result.isSuccess) {
      final session = result.dataOrNull;
      if (session != null) {
        emit(Authenticated(session));
        return;
      }
      if (storageService.getBool(StorageKeys.guestMode) ?? false) {
        emit(const GuestBrowsing());
        return;
      }
      emit(const Unauthenticated());
      return;
    }

    emit(AuthFailure(result.failureOrNull!));
  }

  /// Allows browsing the app without an authenticated session.
  Future<void> continueAsGuest() async {
    await storageService.setBool(StorageKeys.guestMode, true);
    emit(const GuestBrowsing());
  }

  /// Sends 6-digit OTP for [phone] under [countryCode].
  Future<void> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    emit(const AuthLoading(message: 'Sending OTP...'));
    final result = await sendOtpUseCase(
      SendOtpParams(countryCode: countryCode, phone: phone),
    );

    result.fold(
      onSuccess: (_) => emit(AuthOtpSent(countryCode: countryCode, phone: phone)),
      onFailure: (failure) => emit(AuthFailure(failure)),
    );
  }

  /// Verifies OTP code and transitions to [Authenticated].
  Future<void> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
  }) async {
    emit(const AuthLoading(message: 'Verifying OTP...'));
    final result = await verifyOtpUseCase(
      VerifyOtpParams(countryCode: countryCode, phone: phone, otp: otp),
    );

    if (result.isSuccess) {
      await storageService.setBool(StorageKeys.guestMode, false);
      emit(Authenticated(result.dataOrNull!));
      return;
    }

    emit(AuthFailure(result.failureOrNull!));
  }

  /// Logs out the user and returns to the welcome gate.
  Future<void> logout() async {
    emit(const AuthLoading(message: 'Logging out...'));
    final result = await logoutUseCase(const NoParams());

    if (result.isSuccess) {
      await storageService.setBool(StorageKeys.guestMode, false);
      emit(const Unauthenticated());
      return;
    }

    emit(AuthFailure(result.failureOrNull!));
  }
}
