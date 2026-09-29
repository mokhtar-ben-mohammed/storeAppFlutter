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

  const testPhone = '+967770000000';
  const testOtp = '123456';
  const testSession = AuthSessionEntity(
    token: 'jwt_token_123',
    user: UserEntity(id: 'usr_1', phone: testPhone),
  );

  group('VerifyOtpUseCase', () {
    test('returns ValidationFailure when OTP is less than 6 digits', () async {
      final result = await useCase(const VerifyOtpParams(phone: testPhone, otp: '123'));

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('returns ValidationFailure when phone is empty', () async {
      final result = await useCase(const VerifyOtpParams(phone: '', otp: testOtp));

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('delegates to repository and returns AuthSessionEntity on valid inputs', () async {
      when(() => mockRepository.verifyOtp(phone: testPhone, otp: testOtp))
          .thenAnswer((_) async => const Result.ok(testSession));

      final result = await useCase(const VerifyOtpParams(phone: testPhone, otp: testOtp));

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(testSession));
      verify(() => mockRepository.verifyOtp(phone: testPhone, otp: testOtp)).called(1);
    });
  });
}
