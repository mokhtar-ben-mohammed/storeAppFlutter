import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.countryId,
    required this.nameAr,
    required this.nameEn,
  });

  final int id;
  final int countryId;
  final String nameAr;
  final String nameEn;

  @override
  List<Object?> get props => [id, countryId, nameAr, nameEn];
}
