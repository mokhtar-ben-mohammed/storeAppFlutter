import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/registration_draft.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:store/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:store/features/authentication/domain/usecases/profile_usecases.dart';
import 'package:store/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:store/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.getCurrentSessionUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.deleteAccountUseCase,
    required this.storageService,
  }) : super(const AuthInitial());

  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final LocalStorageService storageService;

  RegistrationDraft? _pendingRegistration;

  RegistrationDraft? get pendingRegistration => _pendingRegistration;

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading(message: 'Checking session...'));
    final result = await getCurrentSessionUseCase(const NoParams());

    if (result.isSuccess) {
      final session = result.dataOrNull;
      if (session != null) {
        emit(Authenticated(session));
        // Refresh profile in background when online session exists.
        unawaited(refreshProfile().then((_) {}));
        return;
      }
      await storageService.setBool(StorageKeys.guestMode, false);
      emit(const Unauthenticated());
      return;
    }

    emit(AuthFailure(result.failureOrNull!));
  }

  Future<void> continueAsGuest() async {
    await storageService.setBool(StorageKeys.guestMode, true);
    emit(const GuestBrowsing());
  }

  Future<void> sendOtp({
    required String countryCode,
    required String phone,
    String intent = 'login',
    RegistrationDraft? registration,
  }) async {
    emit(const AuthLoading(message: 'Sending OTP...'));
    _pendingRegistration = intent == 'register' ? registration : null;

    final result = await sendOtpUseCase(
      SendOtpParams(
        countryCode: countryCode,
        phone: phone,
        intent: intent,
        registration: registration,
      ),
    );

    result.fold(
      onSuccess: (_) => emit(
        AuthOtpSent(
          countryCode: countryCode,
          phone: phone,
          isRegister: intent == 'register',
        ),
      ),
      onFailure: (failure) {
        _pendingRegistration = null;
        emit(AuthFailure(failure));
      },
    );
  }

  Future<void> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
  }) async {
    emit(const AuthLoading(message: 'Verifying OTP...'));
    final result = await verifyOtpUseCase(
      VerifyOtpParams(
        countryCode: countryCode,
        phone: phone,
        otp: otp,
        registration: _pendingRegistration,
      ),
    );

    if (result.isSuccess) {
      _pendingRegistration = null;
      await storageService.setBool(StorageKeys.guestMode, false);
      emit(Authenticated(result.dataOrNull!));
      return;
    }

    emit(AuthFailure(result.failureOrNull!));
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> refreshProfile() async {
    final current = state;
    if (current is! Authenticated) return null;

    final result = await getProfileUseCase(const NoParams());
    if (result.isSuccess) {
      emit(Authenticated(_sessionWithUser(current.session, result.dataOrNull!)));
      return null;
    }
    return result.failureOrNull?.message;
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> updateProfile({
    String? name,
    int? cityId,
    int? currencyId,
    String? gender,
  }) async {
    final current = state;
    if (current is! Authenticated) {
      return 'يجب تسجيل الدخول أولاً';
    }

    final result = await updateProfileUseCase(
      UpdateProfileParams(
        name: name,
        cityId: cityId,
        currencyId: currencyId,
        gender: gender,
      ),
    );

    if (result.isSuccess) {
      emit(Authenticated(_sessionWithUser(current.session, result.dataOrNull!)));
      return null;
    }
    return result.failureOrNull?.message ?? 'تعذّر تحديث الملف الشخصي';
  }

  Future<void> logout() async {
    final result = await logoutUseCase(const NoParams());
    _pendingRegistration = null;
    await storageService.setBool(StorageKeys.guestMode, false);

    if (result.isSuccess) {
      emit(const Unauthenticated());
      return;
    }

    // Local clear is best-effort; always leave session for router gate.
    emit(const Unauthenticated());
  }

  Future<String?> deleteAccount() async {
    final result = await deleteAccountUseCase(const NoParams());
    _pendingRegistration = null;
    await storageService.setBool(StorageKeys.guestMode, false);

    if (result.isSuccess) {
      emit(const Unauthenticated());
      return null;
    }

    return result.failureOrNull?.message ?? 'تعذّر حذف الحساب';
  }

  AuthSessionEntity _sessionWithUser(AuthSessionEntity session, UserEntity user) {
    return AuthSessionEntity(
      token: session.token,
      refreshToken: session.refreshToken,
      user: user,
    );
  }
}
