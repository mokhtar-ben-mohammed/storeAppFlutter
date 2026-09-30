import 'package:store/features/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.store,
    required super.supplierName,
    required super.supplierRating,
    required super.originalPriceCny,
    required super.rating,
    required super.salesCount,
    required super.images,
    required super.category,
    required super.description,
    super.marketPriceCny,
    super.isVerifiedSupplier,
    super.isFavorite,
  });

  factory ProductModel.fromHomeJson(Map<String, dynamic> json) {
    final images = <String>[];
    final rawImages = json['image_urls'];
    if (rawImages is List) {
      for (final item in rawImages) {
        final url = item?.toString() ?? '';
        if (url.isNotEmpty) images.add(url);
      }
    }

    final price = (json['price_cny'] as num?)?.toDouble() ?? 0;
    final promo = (json['promotion_price_cny'] as num?)?.toDouble();

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      store: (json['channel_slug'] ?? json['store'] ?? '').toString(),
      supplierName: (json['seller_name'] ?? '').toString(),
      supplierRating: (json['rating'] as num?)?.toDouble() ?? 0,
      originalPriceCny: price,
      marketPriceCny: promo,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      salesCount: (json['sales_count'] as num?)?.toInt() ?? 0,
      images: images,
      category: '',
      description: '',
      isVerifiedSupplier: json['is_verified_supplier'] == true,
    );
  }
}
