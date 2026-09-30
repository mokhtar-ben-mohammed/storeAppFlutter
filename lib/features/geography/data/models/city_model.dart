import 'package:store/features/geography/domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.countryId,
    required super.nameAr,
    required super.nameEn,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      countryId: (json['country_id'] as num?)?.toInt() ?? 0,
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
    );
  }
}
