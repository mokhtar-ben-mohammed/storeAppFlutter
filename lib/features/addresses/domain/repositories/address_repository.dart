import 'package:store/core/utils/result.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';

abstract interface class AddressRepository {
  Future<Result<List<UserAddressEntity>>> list();

  Future<Result<UserAddressEntity>> create(UserAddressDraft draft);

  Future<Result<UserAddressEntity>> update(int id, UserAddressDraft draft);

  Future<Result<void>> delete(int id);

  Future<Result<UserAddressEntity>> makeDefault(int id);
}
