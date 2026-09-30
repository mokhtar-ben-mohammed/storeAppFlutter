import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/finance/data/models/currency_model.dart';

abstract interface class CurrencyRemoteDataSource {
  Future<List<CurrencyModel>> getCurrencies();
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  const CurrencyRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.currencies,
    );
    final list = ApiResponseParser.requireDataList(response);
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => CurrencyModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
