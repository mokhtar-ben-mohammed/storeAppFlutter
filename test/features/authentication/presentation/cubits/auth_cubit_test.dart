import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:store/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:store/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:store/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

class MockGetCurrentSessionUseCase extends Mock implements GetCurrentSessionUseCase {}
class MockSendOtpUseCase extends Mock implements SendOtpUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late AuthCubit cubit;
  late MockGetCurrentSessionUseCase mockGetCurrentSessionUseCase;
  late MockSendOtpUseCase mockSendOtpUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUp(() {
    mockGetCurrentSessionUseCase = MockGetCurrentSessionUseCase();
    mockSendOtpUseCase = MockSendOtpUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockLogoutUseCase = MockLogoutUseCase();

    cubit = AuthCubit(
      getCurrentSessionUseCase: mockGetCurrentSessionUseCase,
      sendOtpUseCase: mockSendOtpUseCase,
      verifyOtpUseCase: mockVerifyOtpUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  const testPhone = '+967770000000';
  const testOtp = '123456';
  const testSession = AuthSessionEntity(
    token: 'jwt_123',
    user: UserEntity(id: 'usr_1', phone: testPhone),
  );

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(cubit.state, equals(const AuthInitial()));
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when session is found on checkAuthStatus',
      build: () {
        when(() => mockGetCurrentSessionUseCase(const NoParams()))
            .thenAnswer((_) async => const Result.ok(testSession));
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(message: 'Checking session...'),
        const Authenticated(testSession),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] when no session found on checkAuthStatus',
      build: () {
        when(() => mockGetCurrentSessionUseCase(const NoParams()))
            .thenAnswer((_) async => const Result.ok(null));
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(message: 'Checking session...'),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpSent] on successful sendOtp',
      build: () {
        when(() => mockSendOtpUseCase(const SendOtpParams(testPhone)))
            .thenAnswer((_) async => const Result.ok(true));
        return cubit;
      },
      act: (cubit) => cubit.sendOtp(testPhone),
      expect: () => [
        const AuthLoading(message: 'Sending OTP...'),
        const AuthOtpSent(phone: testPhone),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] when sendOtp fails with validation error',
      build: () {
        when(() => mockSendOtpUseCase(const SendOtpParams('123')))
            .thenAnswer((_) async => const Result.failure(ValidationFailure('Invalid phone number.')));
        return cubit;
      },
      act: (cubit) => cubit.sendOtp('123'),
      expect: () => [
        const AuthLoading(message: 'Sending OTP...'),
        const AuthFailure(ValidationFailure('Invalid phone number.')),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] on successful verifyOtp',
      build: () {
        when(() => mockVerifyOtpUseCase(const VerifyOtpParams(phone: testPhone, otp: testOtp)))
            .thenAnswer((_) async => const Result.ok(testSession));
        return cubit;
      },
      act: (cubit) => cubit.verifyOtp(phone: testPhone, otp: testOtp),
      expect: () => [
        const AuthLoading(message: 'Verifying OTP...'),
        const Authenticated(testSession),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] on successful logout',
      build: () {
        when(() => mockLogoutUseCase(const NoParams()))
            .thenAnswer((_) async => const Result.ok(null));
        return cubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const AuthLoading(message: 'Logging out...'),
        const Unauthenticated(),
      ],
    );
  });
}
