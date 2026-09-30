import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';

abstract interface class CommerceRemoteDataSource {
  Future<void> addFavorite({
    required String productId,
    required String title,
    String? channelSlug,
    String? imageUrl,
    double? priceCny,
  });

  Future<void> removeFavorite(String productId);

  Future<Map<String, dynamic>> addCartItem({
    required String productId,
    required String skuId,
    required String title,
    String? skuLabel,
    String? channelSlug,
    String? imageUrl,
    double? unitPriceCny,
    int quantity = 1,
  });
}

class CommerceRemoteDataSourceImpl implements CommerceRemoteDataSource {
  const CommerceRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> addFavorite({
    required String productId,
    required String title,
    String? channelSlug,
    String? imageUrl,
    double? priceCny,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.favorites,
      data: {
        'product_id': productId,
        'title': title,
        if (channelSlug != null) 'channel_slug': channelSlug,
        if (imageUrl != null) 'image_url': imageUrl,
        if (priceCny != null) 'price_cny': priceCny,
      },
    );
    ApiResponseParser.requireSuccessData(response);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.favoriteById(productId),
    );
    ApiResponseParser.requireSuccessData(response);
  }

  @override
  Future<Map<String, dynamic>> addCartItem({
    required String productId,
    required String skuId,
    required String title,
    String? skuLabel,
    String? channelSlug,
    String? imageUrl,
    double? unitPriceCny,
    int quantity = 1,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.cartItems,
      data: {
        'product_id': productId,
        'sku_id': skuId,
        'title': title,
        'quantity': quantity,
        if (skuLabel != null) 'sku_label': skuLabel,
        if (channelSlug != null) 'channel_slug': channelSlug,
        if (imageUrl != null) 'image_url': imageUrl,
        if (unitPriceCny != null) 'unit_price_cny': unitPriceCny,
      },
    );
    return ApiResponseParser.requireDataMap(response);
  }
}
