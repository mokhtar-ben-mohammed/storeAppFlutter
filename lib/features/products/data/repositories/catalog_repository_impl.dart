import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/products/data/datasources/catalog_remote_data_source.dart';
import 'package:store/features/products/data/datasources/commerce_remote_data_source.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/entities/product_page_result.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl({
    required this.catalogRemote,
    required this.commerceRemote,
    required this.networkInfo,
  });

  final CatalogRemoteDataSource catalogRemote;
  final CommerceRemoteDataSource commerceRemote;
  final NetworkInfo networkInfo;

  @override
  Future<Result<ProductPageResult>> getChannelProducts({
    required String channelSlug,
    int page = 1,
    int size = 20,
    String? q,
    String? sort,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      final pageResult = await catalogRemote.getChannelProducts(
        channelSlug: channelSlug,
        page: page,
        size: size,
        q: q,
        sort: sort,
      );
      return Result.ok(pageResult);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<ProductEntity>> getProductDetail(String productId) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await catalogRemote.getProductDetail(productId));
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<void>> addFavorite({
    required String productId,
    required String title,
    String? channelSlug,
    String? imageUrl,
    double? priceCny,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      await commerceRemote.addFavorite(
        productId: productId,
        title: title,
        channelSlug: channelSlug,
        imageUrl: imageUrl,
        priceCny: priceCny,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<void>> removeFavorite(String productId) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      await commerceRemote.removeFavorite(productId);
      return const Result.ok(null);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<void>> addToCart({
    required String productId,
    required String skuId,
    required String title,
    String? skuLabel,
    String? channelSlug,
    String? imageUrl,
    double? unitPriceCny,
    int quantity = 1,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      await commerceRemote.addCartItem(
        productId: productId,
        skuId: skuId,
        title: title,
        skuLabel: skuLabel,
        channelSlug: channelSlug,
        imageUrl: imageUrl,
        unitPriceCny: unitPriceCny,
        quantity: quantity,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }
}
