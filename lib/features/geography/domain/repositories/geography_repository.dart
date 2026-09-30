import 'package:store/core/utils/result.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';

abstract interface class GeographyRepository {
  Future<Result<List<CountryEntity>>> getCountries();
  Future<Result<List<CityEntity>>> getCities(int countryId);
}
