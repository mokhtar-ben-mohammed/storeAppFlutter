import 'package:store/core/utils/result.dart';
import 'package:store/features/finance/domain/entities/currency_entity.dart';

abstract interface class CurrencyRepository {
  Future<Result<List<CurrencyEntity>>> getCurrencies();
}
