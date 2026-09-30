import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/products/data/models/product_model.dart';
import 'package:store/features/products/domain/entities/product_page_result.dart';

abstract interface class CatalogRemoteDataSource {
  Future<ProductPageResult> getChannelProducts({
    required String channelSlug,
    int page = 1,
    int size = 20,
    String? q,
    String? sort,
  });

  Future<ProductModel> getProductDetail(String productId);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  const CatalogRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProductPageResult> getChannelProducts({
    required String channelSlug,
    int page = 1,
    int size = 20,
    String? q,
    String? sort,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.channelProducts(channelSlug),
      queryParameters: query,
    );
    final data = ApiResponseParser.requireDataMap(response);
    final itemsRaw = data['items'];
    final paginate = data['paginate'];
    final items = <ProductModel>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map) {
          items.add(ProductModel.fromCardJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final pageMap = paginate is Map ? Map<String, dynamic>.from(paginate) : <String, dynamic>{};
    return ProductPageResult(
      items: items,
      currentPage: (pageMap['current'] as num?)?.toInt() ?? page,
      pageSize: (pageMap['size'] as num?)?.toInt() ?? size,
      total: (pageMap['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<ProductModel> getProductDetail(String productId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productDetail(productId),
    );
    final data = ApiResponseParser.requireDataMap(response);
    return ProductModel.fromDetailJson(data);
  }
}
