import 'package:equatable/equatable.dart';

/// Country available for dial-code selection.
class CountryEntity extends Equatable {
  const CountryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.iso2,
    required this.dialCode,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String iso2;
  final String dialCode;

  @override
  List<Object?> get props => [id, nameAr, nameEn, iso2, dialCode];
}
