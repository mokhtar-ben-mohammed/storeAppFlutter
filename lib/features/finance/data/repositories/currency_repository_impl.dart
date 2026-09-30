import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/finance/data/datasources/currency_remote_data_source.dart';
import 'package:store/features/finance/domain/entities/currency_entity.dart';
import 'package:store/features/finance/domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  const CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final CurrencyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<CurrencyEntity>>> getCurrencies() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await remoteDataSource.getCurrencies());
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }
}
