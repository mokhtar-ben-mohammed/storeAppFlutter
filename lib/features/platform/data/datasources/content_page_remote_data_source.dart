import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/platform/data/models/content_page_model.dart';

abstract interface class ContentPageRemoteDataSource {
  Future<List<ContentPageModel>> getPages();
  Future<ContentPageModel> getPage(String slug);
}

class ContentPageRemoteDataSourceImpl implements ContentPageRemoteDataSource {
  const ContentPageRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ContentPageModel>> getPages() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.contentPages);
    final list = ApiResponseParser.requireDataList(response);
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => ContentPageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<ContentPageModel> getPage(String slug) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiEndpoints.contentPages}/$slug',
    );
    final data = ApiResponseParser.requireDataMap(response);
    return ContentPageModel.fromJson(data);
  }
}
