import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/finance/domain/entities/currency_entity.dart';
import 'package:store/features/finance/domain/repositories/currency_repository.dart';

class GetCurrenciesUseCase implements UseCase<List<CurrencyEntity>, NoParams> {
  const GetCurrenciesUseCase(this._repository);

  final CurrencyRepository _repository;

  @override
  Future<Result<List<CurrencyEntity>>> call(NoParams params) {
    return _repository.getCurrencies();
  }
}
