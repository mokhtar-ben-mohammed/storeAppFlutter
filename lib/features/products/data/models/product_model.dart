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
    super.titleOriginal,
    super.marketPriceCny,
    super.isVerifiedSupplier,
    super.isFavorite,
    super.variants,
    super.skuDimensions,
    super.wholesaleTiers,
    super.specs,
    super.descriptionImages,
    super.moq,
    super.unit,
    super.videoUrl,
    super.stockQuantity,
    super.sellerType,
    super.shipping,
    super.reviewScores,
    super.badges,
    super.storeUrl,
    super.featured,
    super.weightKg,
  });

  factory ProductModel.fromCardJson(Map<String, dynamic> json) {
    final images = _parseImages(json['image_urls']);
    final price = (json['price_cny'] as num?)?.toDouble() ?? 0;
    final promo = (json['promotion_price_cny'] as num?)?.toDouble();
    final rating = (json['rating'] as num?)?.toDouble() ?? 0;

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      store: (json['channel_slug'] ?? json['store'] ?? '').toString(),
      supplierName: (json['seller_name'] ?? '').toString(),
      supplierRating: rating,
      originalPriceCny: price,
      marketPriceCny: promo,
      rating: rating,
      salesCount: (json['sales_count'] as num?)?.toInt() ?? 0,
      images: images,
      category: '',
      description: '',
      isVerifiedSupplier: json['is_verified_supplier'] == true,
    );
  }

  /// Backward-compatible alias used by home feed.
  factory ProductModel.fromHomeJson(Map<String, dynamic> json) =>
      ProductModel.fromCardJson(json);

  factory ProductModel.fromDetailJson(Map<String, dynamic> json) {
    final images = _parseImages(json['image_urls']);
    final descriptionImages = _parseImages(json['description_images']);
    final price = (json['price_cny'] as num?)?.toDouble() ?? 0;
    final promo = (json['promotion_price_cny'] as num?)?.toDouble();
    final rating = (json['rating'] as num?)?.toDouble() ?? 0;
    final variants = _parseSkus(json['skus'], basePrice: price);
    final dimensions = _parseDimensions(json['sku_dimensions']);
    final tiers = _parseTiers(json['wholesale_tiers']);
    final specs = _parseSpecs(json['attributes']);
    final review = _parseReview(json['review']);
    final shipping = _parseShipping(json['shipping']);
    final badges = <String>[];
    final rawBadges = json['badges'];
    if (rawBadges is List) {
      for (final b in rawBadges) {
        final label = b?.toString() ?? '';
        if (label.isNotEmpty) badges.add(label);
      }
    }

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      titleOriginal: json['title_original']?.toString(),
      store: (json['channel_slug'] ?? json['store'] ?? '').toString(),
      supplierName: (json['seller_name'] ?? '').toString(),
      supplierRating: review?.total ?? rating,
      originalPriceCny: price,
      marketPriceCny: promo,
      rating: review?.total ?? rating,
      salesCount: (json['sales_count'] as num?)?.toInt() ?? 0,
      images: images,
      descriptionImages: descriptionImages,
      category: (json['category'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isVerifiedSupplier: json['is_verified_supplier'] == true,
      variants: variants,
      skuDimensions: dimensions,
      wholesaleTiers: tiers,
      specs: specs,
      moq: (json['moq'] as num?)?.toInt(),
      unit: json['unit']?.toString(),
      videoUrl: json['video_url']?.toString(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      sellerType: json['seller_type']?.toString(),
      shipping: shipping,
      reviewScores: review,
      badges: badges,
      storeUrl: json['store_url']?.toString(),
      weightKg: shipping?.weightKg,
    );
  }

  static List<String> _parseImages(dynamic raw) {
    final images = <String>[];
    if (raw is List) {
      for (final item in raw) {
        final url = item?.toString() ?? '';
        if (url.isNotEmpty) images.add(url);
      }
    }
    return images;
  }

  static List<ProductVariant> _parseSkus(dynamic raw, {required double basePrice}) {
    if (raw is! List) return const [];
    final out = <ProductVariant>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = (map['id'] ?? '').toString();
      if (id.isEmpty) continue;
      final price = (map['price_cny'] as num?)?.toDouble() ?? basePrice;
      final stock = map['stock'];
      final attrs = <String, String>{};
      final rawAttrs = map['attributes'];
      if (rawAttrs is List) {
        for (final a in rawAttrs) {
          if (a is Map) {
            final name = (a['name'] ?? '').toString();
            final value = (a['value'] ?? '').toString();
            if (name.isNotEmpty && value.isNotEmpty) attrs[name] = value;
          }
        }
      }
      out.add(
        ProductVariant(
          id: id,
          name: (map['name'] ?? id).toString(),
          priceCny: price,
          priceModifierCny: price - basePrice,
          inStock: stock == null ? true : ((stock as num).toInt() > 0),
          imageUrl: map['image_url']?.toString(),
          attributes: attrs,
        ),
      );
    }
    return out;
  }

  static List<SkuDimension> _parseDimensions(dynamic raw) {
    if (raw is! List) return const [];
    final out = <SkuDimension>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = (map['name'] ?? '').toString();
      final valuesRaw = map['values'];
      if (name.isEmpty || valuesRaw is! List) continue;
      final values = <SkuDimensionValue>[];
      for (final v in valuesRaw) {
        if (v is! Map) continue;
        final vm = Map<String, dynamic>.from(v);
        final label = (vm['label'] ?? '').toString();
        if (label.isEmpty) continue;
        values.add(
          SkuDimensionValue(
            id: (vm['id'] ?? '$name|$label').toString(),
            label: label,
            image: vm['image']?.toString(),
          ),
        );
      }
      if (values.isNotEmpty) {
        out.add(SkuDimension(name: name, values: values));
      }
    }
    return out;
  }

  static List<WholesaleTier> _parseTiers(dynamic raw) {
    if (raw is! List) return const [];
    final out = <WholesaleTier>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final minQty = (map['min_qty'] as num?)?.toInt() ?? 0;
      final price = (map['price_cny'] as num?)?.toDouble() ?? 0;
      if (minQty > 0 && price > 0) {
        out.add(WholesaleTier(minQty: minQty, priceCny: price));
      }
    }
    return out;
  }

  static List<ProductSpec> _parseSpecs(dynamic raw) {
    if (raw is! List) return const [];
    final out = <ProductSpec>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final label = (map['name'] ?? map['label'] ?? '').toString();
      final value = (map['value'] ?? '').toString();
      if (label.isNotEmpty && value.isNotEmpty) {
        out.add(ProductSpec(label: label, value: value));
      }
    }
    return out;
  }

  static ProductReviewScores? _parseReview(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    return ProductReviewScores(
      total: (map['total'] as num?)?.toDouble(),
      service: (map['service'] as num?)?.toDouble(),
      logistics: (map['logistics'] as num?)?.toDouble(),
      aftersale: (map['aftersale'] as num?)?.toDouble(),
    );
  }

  static ProductShippingInfo? _parseShipping(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    return ProductShippingInfo(
      address: map['address']?.toString(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      lengthCm: (map['length_cm'] as num?)?.toDouble(),
      widthCm: (map['width_cm'] as num?)?.toDouble(),
      heightCm: (map['height_cm'] as num?)?.toDouble(),
    );
  }
}
