import 'package:store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:store/features/products/presentation/data/mock_products_data.dart';

/// Preloaded mock cart data matching storeAppUI.
class MockCartData {
  MockCartData._();

  static List<CartItemEntity> get initialItems {
    final p1 = MockProductsData.getById('prod-1')!;
    final p2 = MockProductsData.getById('prod-5')!;
    final p3 = MockProductsData.getById('prod-3')!;

    return [
      CartItemEntity(
        id: 'cart-1',
        productId: p1.id,
        product: p1,
        selectedVariant: p1.variants.first,
        quantity: 1,
        isSelected: true,
        addedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CartItemEntity(
        id: 'cart-2',
        productId: p2.id,
        product: p2,
        selectedVariant: p2.variants.first,
        quantity: 2,
        isSelected: true,
        addedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      CartItemEntity(
        id: 'cart-3',
        productId: p3.id,
        product: p3,
        selectedVariant: p3.variants.first,
        quantity: 1,
        isSelected: false,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
