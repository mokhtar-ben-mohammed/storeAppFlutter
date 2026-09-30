import 'package:equatable/equatable.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';

/// Represents an item in the user's shopping cart.
class CartItemEntity extends Equatable {
  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.product,
    required this.selectedVariant,
    required this.quantity,
    this.isSelected = true,
    required this.addedAt,
  });

  final String id;
  final String productId;
  final ProductEntity product;
  final ProductVariant selectedVariant;
  final int quantity;
  final bool isSelected;
  final DateTime addedAt;

  double get unitPriceCny {
    final basePrice = product.originalPriceCny;
    final modifier = selectedVariant.priceModifierCny;
    return basePrice + modifier;
  }

  double get totalPriceCny => unitPriceCny * quantity;
  double get totalPriceYer => totalPriceCny * 75.0;
  double get totalPriceSar => totalPriceCny * 0.525;
  double get totalPriceUsd => totalPriceCny * 0.14;

  CartItemEntity copyWith({
    String? id,
    String? productId,
    ProductEntity? product,
    ProductVariant? selectedVariant,
    int? quantity,
    bool? isSelected,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        product,
        selectedVariant,
        quantity,
        isSelected,
        addedAt,
      ];
}
