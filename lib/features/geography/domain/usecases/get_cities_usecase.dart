import 'package:equatable/equatable.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/repositories/geography_repository.dart';

class GetCitiesParams extends Equatable {
  const GetCitiesParams(this.countryId);

  final int countryId;

  @override
  List<Object?> get props => [countryId];
}

class GetCitiesUseCase implements UseCase<List<CityEntity>, GetCitiesParams> {
  const GetCitiesUseCase(this._repository);

  final GeographyRepository _repository;

  @override
  Future<Result<List<CityEntity>>> call(GetCitiesParams params) {
    return _repository.getCities(params.countryId);
  }
}
