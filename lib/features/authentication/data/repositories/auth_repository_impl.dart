import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:store/features/authentication/data/models/user_model.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';
import 'package:store/features/authentication/domain/entities/registration_draft.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService storageService;
  final NetworkInfo networkInfo;

  Future<void> _persistSession({
    required String token,
    required UserEntity user,
    String? refreshToken,
  }) async {
    await storageService.setString(StorageKeys.authToken, token);
    if (refreshToken != null) {
      await storageService.setString(StorageKeys.refreshToken, refreshToken);
    }
    await storageService.setString(StorageKeys.userId, user.id);
    await storageService.setString(StorageKeys.userPhone, user.phone);
    await storageService.setString(
      StorageKeys.userProfileJson,
      UserModel.fromEntity(user).toStorageJson(),
    );
    await storageService.setBool(StorageKeys.isAuthenticated, true);
  }

  Future<void> _persistUser(UserEntity user) async {
    await storageService.setString(StorageKeys.userId, user.id);
    await storageService.setString(StorageKeys.userPhone, user.phone);
    await storageService.setString(
      StorageKeys.userProfileJson,
      UserModel.fromEntity(user).toStorageJson(),
    );
  }

  Future<void> _clearSession() async {
    await storageService.remove(StorageKeys.authToken);
    await storageService.remove(StorageKeys.refreshToken);
    await storageService.remove(StorageKeys.userId);
    await storageService.remove(StorageKeys.userPhone);
    await storageService.remove(StorageKeys.userProfileJson);
    await storageService.setBool(StorageKeys.isAuthenticated, false);
  }

  UserEntity _userFromStorage({
    required String userId,
    required String phone,
  }) {
    final raw = storageService.getString(StorageKeys.userProfileJson);
    if (raw != null && raw.isNotEmpty) {
      try {
        final model = UserModel.fromStorageJson(raw);
        if (model.id.isNotEmpty) return model;
      } catch (_) {}
    }
    return UserEntity(id: userId, phone: phone);
  }

  @override
  Future<Result<bool>> sendOtp({
    required String countryCode,
    required String phone,
    required String intent,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final success = await remoteDataSource.sendOtp(
        countryCode: countryCode,
        phone: phone,
        intent: intent,
      );
      return Result.ok(success);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
    RegistrationDraft? registration,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final session = await remoteDataSource.verifyOtp(
        countryCode: countryCode,
        phone: phone,
        otp: otp,
        registration: registration,
      );

      await _persistSession(
        token: session.token,
        refreshToken: session.refreshToken,
        user: session.user,
      );

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
        } catch (_) {}
      }

      await _clearSession();
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
      return Result.ok(
        AuthSessionEntity(
          token: token,
          refreshToken: refreshToken,
          user: _userFromStorage(userId: userId, phone: phone),
        ),
      );
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

  @override
  Future<Result<UserEntity>> getProfile() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getProfile();
      await _persistUser(user);
      return Result.ok(user);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    String? name,
    int? cityId,
    int? currencyId,
    String? gender,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.updateProfile(
        name: name,
        cityId: cityId,
        currencyId: currencyId,
        gender: gender,
      );
      await _persistUser(user);
      return Result.ok(user);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteAccount();
      await _clearSession();
      return const Result.ok(null);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }
}
