import 'package:store/features/platform/domain/entities/content_page_entity.dart';

class ContentPageModel extends ContentPageEntity {
  const ContentPageModel({
    required super.id,
    required super.slug,
    required super.titleAr,
    required super.titleEn,
    required super.requiresConsent,
    super.bodyAr,
    super.bodyEn,
    super.sortOrder,
  });

  factory ContentPageModel.fromJson(Map<String, dynamic> json) {
    return ContentPageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: (json['slug'] ?? '').toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      titleEn: (json['title_en'] ?? '').toString(),
      bodyAr: json['body_ar'] as String?,
      bodyEn: json['body_en'] as String?,
      requiresConsent: json['requires_consent'] == true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
