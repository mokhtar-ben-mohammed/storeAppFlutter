import 'package:equatable/equatable.dart';

/// Product variant / SKU option.
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.name,
    this.colorHex = '#94A3B8',
    this.priceModifierCny = 0,
    this.priceCny,
    this.inStock = true,
    this.imageUrl,
    this.attributes = const {},
  });

  final String id;
  final String name;
  final String colorHex;
  final double priceModifierCny;
  /// Absolute SKU price in CNY when known from API.
  final double? priceCny;
  final bool inStock;
  final String? imageUrl;
  final Map<String, String> attributes;

  @override
  List<Object?> get props => [
        id,
        name,
        colorHex,
        priceModifierCny,
        priceCny,
        inStock,
        imageUrl,
        attributes,
      ];
}

/// Dimension axis for HioBuy-style SKU pickers.
class SkuDimension extends Equatable {
  const SkuDimension({
    required this.name,
    required this.values,
  });

  final String name;
  final List<SkuDimensionValue> values;

  @override
  List<Object?> get props => [name, values];
}

class SkuDimensionValue extends Equatable {
  const SkuDimensionValue({
    required this.id,
    required this.label,
    this.image,
  });

  final String id;
  final String label;
  final String? image;

  @override
  List<Object?> get props => [id, label, image];
}

/// Wholesale bulk pricing tier for 1688 and factory-direct products.
class WholesaleTier extends Equatable {
  const WholesaleTier({
    required this.minQty,
    required this.priceCny,
  });

  final int minQty;
  final double priceCny;

  @override
  List<Object?> get props => [minQty, priceCny];
}

/// Key-value specification item.
class ProductSpec extends Equatable {
  const ProductSpec({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}

/// Product representation for Burhan catalog.
class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.title,
    required this.store,
    required this.supplierName,
    required this.supplierRating,
    required this.originalPriceCny,
    required this.rating,
    required this.salesCount,
    required this.images,
    required this.category,
    required this.description,
    this.titleOriginal,
    this.marketPriceCny,
    this.isVerifiedSupplier = true,
    this.isFavorite = false,
    this.variants = const [],
    this.skuDimensions = const [],
    this.wholesaleTiers = const [],
    this.specs = const [],
    this.descriptionImages = const [],
    this.moq,
    this.unit,
    this.videoUrl,
    this.stockQuantity,
    this.sellerType,
    this.shipping,
    this.reviewScores,
    this.badges = const [],
    this.weightKg,
    this.estimatedDeliveryDays = '7-12 يوم عمل',
    this.storeUrl,
    this.featured = false,
  });

  final String id;
  final String title;
  final String? titleOriginal;
  final String store; // channel_slug: '1688' | 'taobao' | ...
  final String supplierName;
  final double supplierRating;
  final double originalPriceCny;
  final double? marketPriceCny;
  final double rating;
  final int salesCount;
  final List<String> images;
  final List<String> descriptionImages;
  final String category;
  final String description;
  final bool isVerifiedSupplier;
  final bool isFavorite;
  final List<ProductVariant> variants;
  final List<SkuDimension> skuDimensions;
  final List<WholesaleTier> wholesaleTiers;
  final List<ProductSpec> specs;
  final int? moq;
  final String? unit;
  final String? videoUrl;
  final int? stockQuantity;
  final String? sellerType;
  final ProductShippingInfo? shipping;
  final ProductReviewScores? reviewScores;
  final List<String> badges;
  final double? weightKg;
  final String estimatedDeliveryDays;
  final String? storeUrl;
  final bool featured;

  bool get hasRealSkus =>
      variants.isNotEmpty && !(variants.length == 1 && variants.first.id == 'default');

  /// Standard conversion rate: 1 CNY = 75 YER
  double get priceYer => originalPriceCny * 75.0;

  double get priceSar => originalPriceCny * 0.525;

  double get priceUsd => originalPriceCny * 0.14;

  String get formattedPriceYer =>
      '${(originalPriceCny * 75).toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )} ر.ي';

  ProductEntity copyWith({
    String? id,
    String? title,
    String? titleOriginal,
    String? store,
    String? supplierName,
    double? supplierRating,
    double? originalPriceCny,
    double? marketPriceCny,
    double? rating,
    int? salesCount,
    List<String>? images,
    List<String>? descriptionImages,
    String? category,
    String? description,
    bool? isVerifiedSupplier,
    bool? isFavorite,
    List<ProductVariant>? variants,
    List<SkuDimension>? skuDimensions,
    List<WholesaleTier>? wholesaleTiers,
    List<ProductSpec>? specs,
    int? moq,
    String? unit,
    String? videoUrl,
    int? stockQuantity,
    String? sellerType,
    ProductShippingInfo? shipping,
    ProductReviewScores? reviewScores,
    List<String>? badges,
    double? weightKg,
    String? estimatedDeliveryDays,
    String? storeUrl,
    bool? featured,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      titleOriginal: titleOriginal ?? this.titleOriginal,
      store: store ?? this.store,
      supplierName: supplierName ?? this.supplierName,
      supplierRating: supplierRating ?? this.supplierRating,
      originalPriceCny: originalPriceCny ?? this.originalPriceCny,
      marketPriceCny: marketPriceCny ?? this.marketPriceCny,
      rating: rating ?? this.rating,
      salesCount: salesCount ?? this.salesCount,
      images: images ?? this.images,
      descriptionImages: descriptionImages ?? this.descriptionImages,
      category: category ?? this.category,
      description: description ?? this.description,
      isVerifiedSupplier: isVerifiedSupplier ?? this.isVerifiedSupplier,
      isFavorite: isFavorite ?? this.isFavorite,
      variants: variants ?? this.variants,
      skuDimensions: skuDimensions ?? this.skuDimensions,
      wholesaleTiers: wholesaleTiers ?? this.wholesaleTiers,
      specs: specs ?? this.specs,
      moq: moq ?? this.moq,
      unit: unit ?? this.unit,
      videoUrl: videoUrl ?? this.videoUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sellerType: sellerType ?? this.sellerType,
      shipping: shipping ?? this.shipping,
      reviewScores: reviewScores ?? this.reviewScores,
      badges: badges ?? this.badges,
      weightKg: weightKg ?? this.weightKg,
      estimatedDeliveryDays: estimatedDeliveryDays ?? this.estimatedDeliveryDays,
      storeUrl: storeUrl ?? this.storeUrl,
      featured: featured ?? this.featured,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleOriginal,
        store,
        supplierName,
        supplierRating,
        originalPriceCny,
        marketPriceCny,
        rating,
        salesCount,
        images,
        descriptionImages,
        category,
        description,
        isVerifiedSupplier,
        isFavorite,
        variants,
        skuDimensions,
        wholesaleTiers,
        specs,
        moq,
        unit,
        videoUrl,
        stockQuantity,
        sellerType,
        shipping,
        reviewScores,
        badges,
        weightKg,
        estimatedDeliveryDays,
        storeUrl,
        featured,
      ];
}

class ProductShippingInfo extends Equatable {
  const ProductShippingInfo({
    this.address,
    this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
  });

  final String? address;
  final double? weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;

  @override
  List<Object?> get props => [address, weightKg, lengthCm, widthCm, heightCm];
}

class ProductReviewScores extends Equatable {
  const ProductReviewScores({
    this.total,
    this.service,
    this.logistics,
    this.aftersale,
  });

  final double? total;
  final double? service;
  final double? logistics;
  final double? aftersale;

  @override
  List<Object?> get props => [total, service, logistics, aftersale];
}
