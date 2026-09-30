import 'package:store/core/utils/result.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/entities/product_page_result.dart';

abstract interface class CatalogRepository {
  Future<Result<ProductPageResult>> getChannelProducts({
    required String channelSlug,
    int page = 1,
    int size = 20,
    String? q,
    String? sort,
  });

  Future<Result<ProductEntity>> getProductDetail(String productId);

  Future<Result<void>> addFavorite({
    required String productId,
    required String title,
    String? channelSlug,
    String? imageUrl,
    double? priceCny,
  });

  Future<Result<void>> removeFavorite(String productId);

  Future<Result<void>> addToCart({
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
