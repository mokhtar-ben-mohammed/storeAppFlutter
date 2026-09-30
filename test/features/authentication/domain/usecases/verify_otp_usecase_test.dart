import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';
import 'package:store/features/authentication/domain/usecases/verify_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyOtpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepository);
  });

  const testCountryCode = '+967';
  const testPhone = '770000000';
  const testOtp = '123456';
  const testSession = AuthSessionEntity(
    token: 'jwt_token_123',
    user: UserEntity(id: 'usr_1', phone: testPhone),
  );

  group('VerifyOtpUseCase', () {
    test('returns ValidationFailure when OTP is less than 6 digits', () async {
      final result = await useCase(
        const VerifyOtpParams(
          countryCode: testCountryCode,
          phone: testPhone,
          otp: '123',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('delegates to repository on valid inputs', () async {
      when(
        () => mockRepository.verifyOtp(
          countryCode: testCountryCode,
          phone: testPhone,
          otp: testOtp,
          registration: null,
        ),
      ).thenAnswer((_) async => const Result.ok(testSession));

      final result = await useCase(
        const VerifyOtpParams(
          countryCode: testCountryCode,
          phone: testPhone,
          otp: testOtp,
        ),
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => mockRepository.verifyOtp(
          countryCode: testCountryCode,
          phone: testPhone,
          otp: testOtp,
          registration: null,
        ),
      ).called(1);
    });
  });
}
