import 'package:store/features/addresses/domain/entities/user_address_entity.dart';

UserAddressEntity mapUserAddress(Map<String, dynamic> json) {
  final country = json['country'] as Map<String, dynamic>?;
  final city = json['city'] as Map<String, dynamic>?;
  return UserAddressEntity(
    id: (json['id'] as num).toInt(),
    label: (json['label'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    countryId: (json['country_id'] as num).toInt(),
    cityId: (json['city_id'] as num).toInt(),
    countryNameAr: country?['name_ar']?.toString(),
    cityNameAr: city?['name_ar']?.toString(),
    latitude: json['latitude'] == null ? null : (json['latitude'] as num).toDouble(),
    longitude: json['longitude'] == null ? null : (json['longitude'] as num).toDouble(),
    isDefault: json['is_default'] == true,
  );
}
