import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';

abstract interface class AddressRemoteDataSource {
  Future<List<Map<String, dynamic>>> list();

  Future<Map<String, dynamic>> create(Map<String, dynamic> body);

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> body);

  Future<void> delete(int id);

  Future<Map<String, dynamic>> makeDefault(int id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  const AddressRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Map<String, dynamic>>> list() async {
    final response = await _apiClient.get<dynamic>(ApiEndpoints.addresses);
    final list = ApiResponseParser.requireDataList(response);
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.addresses,
      data: body,
    );
    return ApiResponseParser.requireDataMap(response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> body) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.addressById(id),
      data: body,
    );
    return ApiResponseParser.requireDataMap(response);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete<Map<String, dynamic>>(ApiEndpoints.addressById(id));
  }

  @override
  Future<Map<String, dynamic>> makeDefault(int id) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.addressDefault(id),
    );
    return ApiResponseParser.requireDataMap(response);
  }
}
