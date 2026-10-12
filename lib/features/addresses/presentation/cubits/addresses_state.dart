import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';

sealed class AddressesState extends Equatable {
  const AddressesState();

  @override
  List<Object?> get props => [];
}

class AddressesInitial extends AddressesState {
  const AddressesInitial();
}

class AddressesLoading extends AddressesState {
  const AddressesLoading();
}

class AddressesReady extends AddressesState {
  const AddressesReady(this.items);

  final List<UserAddressEntity> items;

  UserAddressEntity? get defaultAddress {
    for (final item in items) {
      if (item.isDefault) return item;
    }
    return items.isEmpty ? null : items.first;
  }

  @override
  List<Object?> get props => [items];
}

class AddressesFailure extends AddressesState {
  const AddressesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
