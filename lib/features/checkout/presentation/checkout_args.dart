import 'package:equatable/equatable.dart';
import 'package:store/features/cart/domain/entities/cart_item_entity.dart';

class CheckoutArgs extends Equatable {
  const CheckoutArgs({
    required this.selectedItemIds,
    required this.items,
  });

  final List<int> selectedItemIds;
  final List<CartItemEntity> items;

  double get estimatedUnits =>
      items.fold(0.0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [selectedItemIds, items];
}
