import 'package:store/core/utils/result.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';

/// Contract for geography lookups used by auth and profile.
abstract interface class GeographyRepository {
  Future<Result<List<CountryEntity>>> getCountries();
}
