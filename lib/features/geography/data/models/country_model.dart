import 'package:store/features/geography/domain/entities/country_entity.dart';

/// Data model for a country from the geography API.
class CountryModel extends CountryEntity {
  const CountryModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.iso2,
    required super.dialCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      iso2: (json['iso2'] ?? '').toString(),
      dialCode: (json['dial_code'] ?? '').toString(),
    );
  }
}
