import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';
import 'package:store/features/addresses/domain/repositories/address_repository.dart';
import 'package:store/features/addresses/presentation/cubits/addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit({required this.repository}) : super(const AddressesInitial());

  final AddressRepository repository;

  Future<void> load() async {
    emit(const AddressesLoading());
    final result = await repository.list();
    result.fold(
      onSuccess: (items) => emit(AddressesReady(items)),
      onFailure: (failure) => emit(AddressesFailure(failure)),
    );
  }

  Future<UserAddressEntity?> create(UserAddressDraft draft) async {
    final current = state;
    final result = await repository.create(draft);
    return result.fold(
      onSuccess: (address) {
        if (current is AddressesReady) {
          final items = [address, ...current.items.where((e) => e.id != address.id)];
          emit(AddressesReady(_normalizeDefaults(items, address)));
        } else {
          emit(AddressesReady([address]));
        }
        return address;
      },
      onFailure: (_) => null,
    );
  }

  Future<UserAddressEntity?> update(int id, UserAddressDraft draft) async {
    final current = state;
    final result = await repository.update(id, draft);
    return result.fold(
      onSuccess: (address) {
        if (current is AddressesReady) {
          final items = current.items
              .map((e) => e.id == address.id ? address : e)
              .toList();
          emit(AddressesReady(_normalizeDefaults(items, address)));
        }
        return address;
      },
      onFailure: (_) => null,
    );
  }

  Future<bool> remove(int id) async {
    final current = state;
    final result = await repository.delete(id);
    return result.fold(
      onSuccess: (_) {
        if (current is AddressesReady) {
          emit(AddressesReady(current.items.where((e) => e.id != id).toList()));
        }
        return true;
      },
      onFailure: (_) => false,
    );
  }

  Future<UserAddressEntity?> makeDefault(int id) async {
    final current = state;
    final result = await repository.makeDefault(id);
    return result.fold(
      onSuccess: (address) {
        if (current is AddressesReady) {
          final items = current.items
              .map(
                (e) => UserAddressEntity(
                  id: e.id,
                  label: e.label,
                  description: e.description,
                  phone: e.phone,
                  countryId: e.countryId,
                  cityId: e.cityId,
                  countryNameAr: e.countryNameAr,
                  cityNameAr: e.cityNameAr,
                  latitude: e.latitude,
                  longitude: e.longitude,
                  isDefault: e.id == address.id,
                ),
              )
              .toList();
          emit(AddressesReady(items));
        }
        return address;
      },
      onFailure: (_) => null,
    );
  }

  List<UserAddressEntity> _normalizeDefaults(
    List<UserAddressEntity> items,
    UserAddressEntity changed,
  ) {
    if (!changed.isDefault) return items;
    return items
        .map(
          (e) => UserAddressEntity(
            id: e.id,
            label: e.label,
            description: e.description,
            phone: e.phone,
            countryId: e.countryId,
            cityId: e.cityId,
            countryNameAr: e.countryNameAr,
            cityNameAr: e.cityNameAr,
            latitude: e.latitude,
            longitude: e.longitude,
            isDefault: e.id == changed.id,
          ),
        )
        .toList();
  }

  Failure? get lastFailure {
    final current = state;
    return current is AddressesFailure ? current.failure : null;
  }
}
