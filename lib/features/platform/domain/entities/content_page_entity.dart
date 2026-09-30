import 'package:equatable/equatable.dart';

class ContentPageEntity extends Equatable {
  const ContentPageEntity({
    required this.id,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    required this.requiresConsent,
    this.bodyAr,
    this.bodyEn,
    this.sortOrder = 0,
  });

  final int id;
  final String slug;
  final String titleAr;
  final String titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final bool requiresConsent;
  final int sortOrder;

  @override
  List<Object?> get props => [id, slug, titleAr, requiresConsent];
}
