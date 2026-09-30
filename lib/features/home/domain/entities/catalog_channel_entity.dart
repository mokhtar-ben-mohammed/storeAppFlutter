import 'package:equatable/equatable.dart';

/// Catalog marketplace channel shown on home.
class CatalogChannelEntity extends Equatable {
  const CatalogChannelEntity({
    required this.id,
    required this.slug,
    required this.externalCode,
    required this.nameAr,
    required this.nameEn,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.sortOrder = 0,
    this.supportsCategories = false,
  });

  final int id;
  final String slug;
  final String externalCode;
  final String nameAr;
  final String nameEn;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? primaryTextColor;
  final String? secondaryTextColor;
  final int sortOrder;
  final bool supportsCategories;

  @override
  List<Object?> get props => [
        id,
        slug,
        externalCode,
        nameAr,
        nameEn,
        logoUrl,
        primaryColor,
        secondaryColor,
        sortOrder,
      ];
}
