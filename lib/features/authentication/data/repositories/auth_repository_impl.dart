import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

/// Concrete repository coordinating between [AuthRemoteDataSource] and [LocalStorageService].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService storageService;
  final NetworkInfo networkInfo;

  @override
  Future<Result<bool>> sendOtp(String phone) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final success = await remoteDataSource.sendOtp(phone);
      return Result.ok(success);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final session = await remoteDataSource.verifyOtp(phone: phone, otp: otp);

      // Persist session tokens and user identifiers locally
      await storageService.setString(StorageKeys.authToken, session.token);
      if (session.refreshToken != null) {
        await storageService.setString(StorageKeys.refreshToken, session.refreshToken!);
      }
      await storageService.setString(StorageKeys.userId, session.user.id);
      await storageService.setString(StorageKeys.userPhone, session.user.phone);
      await storageService.setBool(StorageKeys.isAuthenticated, true);

      return Result.ok(session);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (_) {
          // Proceed with local cleanup even if remote logout fails
        }
      }

      await storageService.remove(StorageKeys.authToken);
      await storageService.remove(StorageKeys.refreshToken);
      await storageService.remove(StorageKeys.userId);
      await storageService.remove(StorageKeys.userPhone);
      await storageService.setBool(StorageKeys.isAuthenticated, false);

      return const Result.ok(null);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to clear local credentials: $e'));
    }
  }

  @override
  Future<Result<AuthSessionEntity?>> getCurrentSession() async {
    try {
      final token = storageService.getString(StorageKeys.authToken);
      final userId = storageService.getString(StorageKeys.userId);
      final phone = storageService.getString(StorageKeys.userPhone);

      if (token == null || token.isEmpty || userId == null || phone == null) {
        return const Result.ok(null);
      }

      final refreshToken = storageService.getString(StorageKeys.refreshToken);
      final session = AuthSessionEntity(
        token: token,
        refreshToken: refreshToken,
        user: UserEntity(id: userId, phone: phone),
      );

      return Result.ok(session);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to retrieve active session: $e'));
    }
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    try {
      final isAuth = storageService.getBool(StorageKeys.isAuthenticated) ?? false;
      final hasToken = (storageService.getString(StorageKeys.authToken) ?? '').isNotEmpty;
      return Result.ok(isAuth && hasToken);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to check authentication status: $e'));
    }
  }
}
