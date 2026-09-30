import 'package:equatable/equatable.dart';

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

  /// Approximate rate: 1 CNY = 75 YER
  double get priceYer => originalPriceCny * 75.0;

  String get formattedPriceYer => '${(originalPriceCny * 75).toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )} ر.ي';

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
      ];
}
