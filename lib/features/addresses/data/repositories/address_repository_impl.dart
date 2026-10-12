import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/addresses/data/datasources/address_remote_data_source.dart';
import 'package:store/features/addresses/data/models/user_address_model.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';
import 'package:store/features/addresses/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final AddressRemoteDataSource remote;
  final NetworkInfo networkInfo;

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await run());
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<List<UserAddressEntity>>> list() => _guard(
        () async => (await remote.list()).map(mapUserAddress).toList(),
      );

  @override
  Future<Result<UserAddressEntity>> create(UserAddressDraft draft) => _guard(
        () async => mapUserAddress(await remote.create(draft.toJson())),
      );

  @override
  Future<Result<UserAddressEntity>> update(int id, UserAddressDraft draft) =>
      _guard(
        () async => mapUserAddress(await remote.update(id, draft.toJson())),
      );

  @override
  Future<Result<void>> delete(int id) => _guard(() async {
        await remote.delete(id);
      });

  @override
  Future<Result<UserAddressEntity>> makeDefault(int id) => _guard(
        () async => mapUserAddress(await remote.makeDefault(id)),
      );
}
