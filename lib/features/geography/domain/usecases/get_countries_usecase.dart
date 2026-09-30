import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/repositories/geography_repository.dart';

class GetCountriesUseCase implements UseCase<List<CountryEntity>, NoParams> {
  const GetCountriesUseCase(this._repository);

  final GeographyRepository _repository;

  @override
  Future<Result<List<CountryEntity>>> call(NoParams params) {
    return _repository.getCountries();
  }
}
