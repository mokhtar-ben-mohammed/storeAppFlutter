import 'package:equatable/equatable.dart';

/// Product variant model (color, size, material).
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.colorHex,
    this.priceModifierCny = 0,
    this.inStock = true,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String colorHex;
  final double priceModifierCny;
  final bool inStock;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, colorHex, priceModifierCny, inStock, imageUrl];
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
    this.marketPriceCny,
    this.isVerifiedSupplier = true,
    this.isFavorite = false,
    this.variants = const [],
    this.wholesaleTiers = const [],
    this.specs = const [],
    this.weightKg,
    this.estimatedDeliveryDays = '7-12 يوم عمل',
    this.storeUrl,
    this.featured = false,
  });

  final String id;
  final String title;
  final String store; // '1688' | 'taobao' | 'goofish' | 'aliexpress'
  final String supplierName;
  final double supplierRating;
  final double originalPriceCny;
  final double? marketPriceCny;
  final double rating;
  final int salesCount;
  final List<String> images;
  final String category;
  final String description;
  final bool isVerifiedSupplier;
  final bool isFavorite;
  final List<ProductVariant> variants;
  final List<WholesaleTier> wholesaleTiers;
  final List<ProductSpec> specs;
  final double? weightKg;
  final String estimatedDeliveryDays;
  final String? storeUrl;
  final bool featured;

  /// Standard conversion rate: 1 CNY = 75 YER
  double get priceYer => originalPriceCny * 75.0;

  /// Approximate SAR rate: 1 CNY = 0.525 SAR
  double get priceSar => originalPriceCny * 0.525;

  /// Approximate USD rate: 1 CNY = 0.14 USD
  double get priceUsd => originalPriceCny * 0.14;

  String get formattedPriceYer =>
      '${(originalPriceCny * 75).toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )} ر.ي';

  ProductEntity copyWith({
    String? id,
    String? title,
    String? store,
    String? supplierName,
    double? supplierRating,
    double? originalPriceCny,
    double? marketPriceCny,
    double? rating,
    int? salesCount,
    List<String>? images,
    String? category,
    String? description,
    bool? isVerifiedSupplier,
    bool? isFavorite,
    List<ProductVariant>? variants,
    List<WholesaleTier>? wholesaleTiers,
    List<ProductSpec>? specs,
    double? weightKg,
    String? estimatedDeliveryDays,
    String? storeUrl,
    bool? featured,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      store: store ?? this.store,
      supplierName: supplierName ?? this.supplierName,
      supplierRating: supplierRating ?? this.supplierRating,
      originalPriceCny: originalPriceCny ?? this.originalPriceCny,
      marketPriceCny: marketPriceCny ?? this.marketPriceCny,
      rating: rating ?? this.rating,
      salesCount: salesCount ?? this.salesCount,
      images: images ?? this.images,
      category: category ?? this.category,
      description: description ?? this.description,
      isVerifiedSupplier: isVerifiedSupplier ?? this.isVerifiedSupplier,
      isFavorite: isFavorite ?? this.isFavorite,
      variants: variants ?? this.variants,
      wholesaleTiers: wholesaleTiers ?? this.wholesaleTiers,
      specs: specs ?? this.specs,
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
        store,
        supplierName,
        supplierRating,
        originalPriceCny,
        marketPriceCny,
        rating,
        salesCount,
        images,
        category,
        description,
        isVerifiedSupplier,
        isFavorite,
        variants,
        wholesaleTiers,
        specs,
        weightKg,
        estimatedDeliveryDays,
        storeUrl,
        featured,
      ];
}
