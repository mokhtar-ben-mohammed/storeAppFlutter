import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();
  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

final class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading({this.preview});
  final ProductEntity? preview;
  @override
  List<Object?> get props => [preview];
}

final class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded(this.product, {this.isFavorite = false});
  final ProductEntity product;
  final bool isFavorite;
  @override
  List<Object?> get props => [product, isFavorite];
}

final class ProductDetailFailure extends ProductDetailState {
  const ProductDetailFailure(this.failure, {this.preview});
  final Failure failure;
  final ProductEntity? preview;
  String get message => failure.message;
  @override
  List<Object?> get props => [failure, preview];
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({required this.catalogRepository})
      : super(const ProductDetailInitial());

  final CatalogRepository catalogRepository;

  Future<void> load(String productId, {ProductEntity? preview}) async {
    emit(ProductDetailLoading(preview: preview));
    final result = await catalogRepository.getProductDetail(productId);
    if (result.isSuccess) {
      emit(ProductDetailLoaded(result.dataOrNull!));
      return;
    }
    emit(ProductDetailFailure(result.failureOrNull!, preview: preview));
  }

  Future<String?> toggleFavorite({required bool currentlyFavorite}) async {
    final current = state;
    if (current is! ProductDetailLoaded) return 'المنتج غير جاهز';
    final product = current.product;
    final result = currentlyFavorite
        ? await catalogRepository.removeFavorite(product.id)
        : await catalogRepository.addFavorite(
            productId: product.id,
            title: product.title,
            channelSlug: product.store,
            imageUrl: product.images.isNotEmpty ? product.images.first : null,
            priceCny: product.originalPriceCny,
          );
    if (result.isSuccess) {
      emit(ProductDetailLoaded(product, isFavorite: !currentlyFavorite));
      return null;
    }
    return result.failureOrNull?.message ?? 'تعذّر تحديث المفضلة';
  }

  Future<String?> addToCart({
    required String skuId,
    String? skuLabel,
    required int quantity,
    double? unitPriceCny,
  }) async {
    final current = state;
    final product = current is ProductDetailLoaded
        ? current.product
        : (current is ProductDetailLoading ? current.preview : null);
    if (product == null) return 'المنتج غير جاهز';

    final result = await catalogRepository.addToCart(
      productId: product.id,
      skuId: skuId,
      skuLabel: skuLabel,
      title: product.title,
      channelSlug: product.store,
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      unitPriceCny: unitPriceCny ?? product.originalPriceCny,
      quantity: quantity,
    );
    return result.isSuccess
        ? null
        : (result.failureOrNull?.message ?? 'تعذّر الإضافة إلى السلة');
  }
}
