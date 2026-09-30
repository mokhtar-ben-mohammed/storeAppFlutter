import 'package:store/features/home/domain/entities/catalog_channel_entity.dart';

class CatalogChannelModel extends CatalogChannelEntity {
  const CatalogChannelModel({
    required super.id,
    required super.slug,
    required super.externalCode,
    required super.nameAr,
    required super.nameEn,
    super.logoUrl,
    super.primaryColor,
    super.secondaryColor,
    super.primaryTextColor,
    super.secondaryTextColor,
    super.sortOrder,
    super.supportsCategories,
  });

  factory CatalogChannelModel.fromJson(Map<String, dynamic> json) {
    return CatalogChannelModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: (json['slug'] ?? '').toString(),
      externalCode: (json['external_code'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      logoUrl: json['logo_url'] as String?,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      primaryTextColor: json['primary_text_color'] as String?,
      secondaryTextColor: json['secondary_text_color'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      supportsCategories: json['supports_categories'] == true,
    );
  }
}
