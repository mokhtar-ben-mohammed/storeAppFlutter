import 'package:equatable/equatable.dart';

class UserAddressEntity extends Equatable {
  const UserAddressEntity({
    required this.id,
    required this.label,
    required this.description,
    required this.phone,
    required this.countryId,
    required this.cityId,
    this.countryNameAr,
    this.cityNameAr,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String description;
  final String phone;
  final int countryId;
  final int cityId;
  final String? countryNameAr;
  final String? cityNameAr;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  String get subtitle {
    final city = cityNameAr ?? '';
    final country = countryNameAr ?? '';
    final place = [city, country].where((e) => e.isNotEmpty).join(' - ');
    return place.isEmpty ? description : '$place · $description';
  }

  @override
  List<Object?> get props => [
        id,
        label,
        description,
        phone,
        countryId,
        cityId,
        countryNameAr,
        cityNameAr,
        latitude,
        longitude,
        isDefault,
      ];
}

class UserAddressDraft {
  const UserAddressDraft({
    this.label = '',
    this.description = '',
    this.phone = '',
    this.countryId,
    this.cityId,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String label;
  final String description;
  final String phone;
  final int? countryId;
  final int? cityId;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  UserAddressDraft copyWith({
    String? label,
    String? description,
    String? phone,
    int? countryId,
    int? cityId,
    double? latitude,
    double? longitude,
    bool? isDefault,
    bool clearCity = false,
    bool clearCoords = false,
  }) {
    return UserAddressDraft(
      label: label ?? this.label,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      countryId: countryId ?? this.countryId,
      cityId: clearCity ? null : (cityId ?? this.cityId),
      latitude: clearCoords ? null : (latitude ?? this.latitude),
      longitude: clearCoords ? null : (longitude ?? this.longitude),
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (label.trim().isEmpty) errors['label'] = 'أدخل اسم العنوان';
    if (description.trim().isEmpty) errors['description'] = 'أدخل وصف العنوان';
    if (phone.trim().isEmpty) errors['phone'] = 'أدخل رقم الهاتف';
    if (countryId == null) errors['countryId'] = 'اختر الدولة';
    if (cityId == null) errors['cityId'] = 'اختر المدينة';
    return errors;
  }

  Map<String, dynamic> toJson() => {
        'label': label.trim(),
        'description': description.trim(),
        'phone': phone.trim(),
        'country_id': countryId,
        'city_id': cityId,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };
}
