import 'package:equatable/equatable.dart';

class CurrencyEntity extends Equatable {
  const CurrencyEntity({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    this.symbol,
  });

  final int id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String? symbol;

  String get displayLabel => '$nameAr ($code)';

  String get flagEmoji {
    return switch (code.toUpperCase()) {
      'YER' => '🇾🇪',
      'SAR' => '🇸🇦',
      'USD' => '🇺🇸',
      'CNY' => '🇨🇳',
      'EUR' => '🇪🇺',
      _ => '💱',
    };
  }

  @override
  List<Object?> get props => [id, code, nameAr, nameEn, symbol];
}
