import 'package:equatable/equatable.dart';
import 'package:store/features/home/domain/entities/catalog_channel_entity.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';

/// Aggregated home feed from GET /home.
class HomeFeedEntity extends Equatable {
  const HomeFeedEntity({
    required this.channels,
    required this.featuredProducts,
    this.banners = const [],
  });

  final List<CatalogChannelEntity> channels;
  final List<ProductEntity> featuredProducts;
  final List<dynamic> banners;

  @override
  List<Object?> get props => [channels, featuredProducts, banners];
}
