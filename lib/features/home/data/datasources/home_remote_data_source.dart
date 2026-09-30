import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/home/data/models/catalog_channel_model.dart';
import 'package:store/features/home/data/models/product_model.dart';
import 'package:store/features/home/domain/entities/home_feed_entity.dart';

abstract interface class HomeRemoteDataSource {
  Future<HomeFeedEntity> getHomeFeed();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HomeFeedEntity> getHomeFeed() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.home);
    final data = ApiResponseParser.requireDataMap(response);

    final channelsRaw = data['channels'];
    final productsRaw = data['featured_products'];

    final channels = <CatalogChannelModel>[];
    if (channelsRaw is List) {
      for (final item in channelsRaw) {
        if (item is Map) {
          channels.add(CatalogChannelModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final products = <ProductModel>[];
    if (productsRaw is List) {
      for (final item in productsRaw) {
        if (item is Map) {
          products.add(ProductModel.fromHomeJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return HomeFeedEntity(
      channels: channels,
      featuredProducts: products,
      banners: data['banners'] is List ? List<dynamic>.from(data['banners'] as List) : const [],
    );
  }
}
