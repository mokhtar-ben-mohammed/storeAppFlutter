import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:store/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:store/features/authentication/domain/usecases/profile_usecases.dart';
import 'package:store/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:store/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

class MockGetCurrentSessionUseCase extends Mock implements GetCurrentSessionUseCase {}
class MockSendOtpUseCase extends Mock implements SendOtpUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}
class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late AuthCubit cubit;
  late MockGetCurrentSessionUseCase mockGetCurrentSessionUseCase;
  late MockSendOtpUseCase mockSendOtpUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockDeleteAccountUseCase mockDeleteAccountUseCase;
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockGetCurrentSessionUseCase = MockGetCurrentSessionUseCase();
    mockSendOtpUseCase = MockSendOtpUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockDeleteAccountUseCase = MockDeleteAccountUseCase();
    mockStorage = MockLocalStorageService();
    when(() => mockStorage.getBool(any())).thenReturn(false);
    when(() => mockStorage.setBool(any(), any())).thenAnswer((_) async => true);

    cubit = AuthCubit(
      getCurrentSessionUseCase: mockGetCurrentSessionUseCase,
      sendOtpUseCase: mockSendOtpUseCase,
      verifyOtpUseCase: mockVerifyOtpUseCase,
      logoutUseCase: mockLogoutUseCase,
      getProfileUseCase: mockGetProfileUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      deleteAccountUseCase: mockDeleteAccountUseCase,
      storageService: mockStorage,
    );
  });

  const testCountryCode = '+967';
  const testPhone = '770000000';
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
      'emits [AuthLoading, AuthOtpSent] on successful sendOtp login',
      build: () {
        when(
          () => mockSendOtpUseCase(
            const SendOtpParams(countryCode: testCountryCode, phone: testPhone),
          ),
        ).thenAnswer((_) async => const Result.ok(true));
        return cubit;
      },
      act: (cubit) => cubit.sendOtp(countryCode: testCountryCode, phone: testPhone),
      expect: () => [
        const AuthLoading(message: 'Sending OTP...'),
        const AuthOtpSent(countryCode: testCountryCode, phone: testPhone),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] on successful verifyOtp',
      build: () {
        when(
          () => mockVerifyOtpUseCase(
            const VerifyOtpParams(
              countryCode: testCountryCode,
              phone: testPhone,
              otp: testOtp,
            ),
          ),
        ).thenAnswer((_) async => const Result.ok(testSession));
        return cubit;
      },
      act: (cubit) => cubit.verifyOtp(
            countryCode: testCountryCode,
            phone: testPhone,
            otp: testOtp,
          ),
      expect: () => [
        const AuthLoading(message: 'Verifying OTP...'),
        const Authenticated(testSession),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] on successful logout',
      build: () {
        when(() => mockLogoutUseCase(const NoParams()))
            .thenAnswer((_) async => const Result.ok(null));
        return cubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const Unauthenticated(),
      ],
      verify: (_) {
        verify(() => mockStorage.setBool(StorageKeys.guestMode, false)).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthFailure when sendOtp fails',
      build: () {
        when(
          () => mockSendOtpUseCase(
            const SendOtpParams(countryCode: testCountryCode, phone: '123'),
          ),
        ).thenAnswer(
          (_) async => const Result.failure(ValidationFailure('Invalid phone number.')),
        );
        return cubit;
      },
      act: (cubit) => cubit.sendOtp(countryCode: testCountryCode, phone: '123'),
      expect: () => [
        const AuthLoading(message: 'Sending OTP...'),
        const AuthFailure(ValidationFailure('Invalid phone number.')),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'updateProfile emits Authenticated with updated user',
      build: () {
        when(
          () => mockUpdateProfileUseCase(const UpdateProfileParams(name: 'سارة')),
        ).thenAnswer(
          (_) async => const Result.ok(
            UserEntity(id: 'usr_1', phone: testPhone, name: 'سارة'),
          ),
        );
        return cubit;
      },
      seed: () => const Authenticated(testSession),
      act: (cubit) => cubit.updateProfile(name: 'سارة'),
      expect: () => [
        const Authenticated(
          AuthSessionEntity(
            token: 'jwt_123',
            user: UserEntity(id: 'usr_1', phone: testPhone, name: 'سارة'),
          ),
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'deleteAccount emits Unauthenticated on success',
      build: () {
        when(() => mockDeleteAccountUseCase(const NoParams()))
            .thenAnswer((_) async => const Result.ok(null));
        return cubit;
      },
      seed: () => const Authenticated(testSession),
      act: (cubit) => cubit.deleteAccount(),
      expect: () => [const Unauthenticated()],
    );
  });
}
