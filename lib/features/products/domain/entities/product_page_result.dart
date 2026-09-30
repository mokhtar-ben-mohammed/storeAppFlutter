import 'package:equatable/equatable.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';

class ProductPageResult extends Equatable {
  const ProductPageResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.total,
  });

  final List<ProductEntity> items;
  final int currentPage;
  final int pageSize;
  final int total;

  bool get hasMore => currentPage * pageSize < total;

  @override
  List<Object?> get props => [items, currentPage, pageSize, total];
}
