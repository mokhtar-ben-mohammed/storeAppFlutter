import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/geography/data/models/country_model.dart';

/// Remote geography endpoints.
abstract interface class GeographyRemoteDataSource {
  Future<List<CountryModel>> getCountries();
}

class GeographyRemoteDataSourceImpl implements GeographyRemoteDataSource {
  const GeographyRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.countries);
    final list = ApiResponseParser.requireDataList(response);
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => CountryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
