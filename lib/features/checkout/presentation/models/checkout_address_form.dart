import 'package:equatable/equatable.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';

/// Selected delivery address for checkout (saved address id preferred).
class CheckoutAddressForm extends Equatable {
  const CheckoutAddressForm({
    this.userAddressId,
    this.label = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.cityId,
    this.addressLine = '',
    this.cityNameAr,
    this.latitude,
    this.longitude,
  });

  final int? userAddressId;
  final String label;
  final String recipientName;
  final String recipientPhone;
  final int? cityId;
  final String addressLine;
  final String? cityNameAr;
  final double? latitude;
  final double? longitude;

  factory CheckoutAddressForm.fromEntity(UserAddressEntity address) {
    return CheckoutAddressForm(
      userAddressId: address.id,
      label: address.label,
      recipientPhone: address.phone,
      cityId: address.cityId,
      addressLine: address.description,
      cityNameAr: address.cityNameAr,
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }

  CheckoutAddressForm copyWith({
    int? userAddressId,
    String? label,
    String? recipientName,
    String? recipientPhone,
    int? cityId,
    String? addressLine,
    String? cityNameAr,
    double? latitude,
    double? longitude,
    bool clearSelection = false,
  }) {
    return CheckoutAddressForm(
      userAddressId: clearSelection ? null : (userAddressId ?? this.userAddressId),
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      cityId: cityId ?? this.cityId,
      addressLine: addressLine ?? this.addressLine,
      cityNameAr: cityNameAr ?? this.cityNameAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (userAddressId == null) {
      errors['userAddressId'] = 'اختر عنوان التوصيل';
    }
    return errors;
  }

  @override
  List<Object?> get props => [
        userAddressId,
        label,
        recipientName,
        recipientPhone,
        cityId,
        addressLine,
        cityNameAr,
        latitude,
        longitude,
      ];
}
