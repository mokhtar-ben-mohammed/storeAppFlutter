import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:store/features/authentication/data/models/auth_session_model.dart';
import 'package:store/features/authentication/data/models/user_model.dart';
import 'package:store/features/authentication/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockLocalStorageService mockLocalStorageService;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalStorageService = MockLocalStorageService();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      storageService: mockLocalStorageService,
      networkInfo: mockNetworkInfo,
    );
  });

  const testCountryCode = '+967';
  const testPhone = '770000000';
  const testOtp = '123456';
  const testSessionModel = AuthSessionModel(
    token: 'jwt_token_abc',
    refreshToken: 'refresh_token_xyz',
    user: UserModel(id: 'usr_123', phone: testPhone),
  );

  group('AuthRepositoryImpl', () {
    test('returns NetworkFailure when device is offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.verifyOtp(
        countryCode: testCountryCode,
        phone: testPhone,
        otp: testOtp,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('stores session and returns AuthSessionEntity on successful verification', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.verifyOtp(
          countryCode: testCountryCode,
          phone: testPhone,
          otp: testOtp,
        ),
      ).thenAnswer((_) async => testSessionModel);
      when(() => mockLocalStorageService.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockLocalStorageService.setBool(any(), any()))
          .thenAnswer((_) async => true);

      final result = await repository.verifyOtp(
        countryCode: testCountryCode,
        phone: testPhone,
        otp: testOtp,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(testSessionModel));

      verify(() => mockLocalStorageService.setString(StorageKeys.authToken, 'jwt_token_abc')).called(1);
      verify(() => mockLocalStorageService.setBool(StorageKeys.isAuthenticated, true)).called(1);
    });

    test('clears local credentials on logout', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async {});
      when(() => mockLocalStorageService.remove(any())).thenAnswer((_) async => true);
      when(() => mockLocalStorageService.setBool(any(), any())).thenAnswer((_) async => true);

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => mockLocalStorageService.remove(StorageKeys.authToken)).called(1);
      verify(() => mockLocalStorageService.setBool(StorageKeys.isAuthenticated, false)).called(1);
    });
  });
}
