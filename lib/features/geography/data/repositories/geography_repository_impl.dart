import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/geography/data/datasources/geography_remote_data_source.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/repositories/geography_repository.dart';

class GeographyRepositoryImpl implements GeographyRepository {
  const GeographyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final GeographyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<CountryEntity>>> getCountries() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await remoteDataSource.getCountries());
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<List<CityEntity>>> getCities(int countryId) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await remoteDataSource.getCities(countryId));
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }
}
