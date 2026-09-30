import 'package:equatable/equatable.dart';

/// Nested city snapshot on the authenticated user profile.
class UserCityEntity extends Equatable {
  const UserCityEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.countryId,
  });

  final int id;
  final String nameAr;
  final String? nameEn;
  final int? countryId;

  @override
  List<Object?> get props => [id, nameAr, nameEn, countryId];
}

/// Nested currency snapshot on the authenticated user profile.
class UserCurrencyEntity extends Equatable {
  const UserCurrencyEntity({
    required this.id,
    required this.code,
    required this.nameAr,
    this.nameEn,
    this.symbol,
  });

  final int id;
  final String code;
  final String nameAr;
  final String? nameEn;
  final String? symbol;

  @override
  List<Object?> get props => [id, code, nameAr, nameEn, symbol];
}

/// Domain entity representing an authenticated Burhan user.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.countryCode,
    this.gender,
    this.avatarUrl,
    this.city,
    this.currency,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? countryCode;
  final String? gender;
  final String? avatarUrl;
  final UserCityEntity? city;
  final UserCurrencyEntity? currency;

  String get displayName => (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'عميل برهان';

  String get displayPhone {
    final code = countryCode?.trim() ?? '';
    final local = phone.trim();
    if (code.isEmpty) return local;
    return '$code $local';
  }

  String get displayCity {
    final cityName = city?.nameAr.trim();
    if (cityName == null || cityName.isEmpty) return '—';
    return cityName;
  }

  UserEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? countryCode,
    String? gender,
    String? avatarUrl,
    UserCityEntity? city,
    UserCurrencyEntity? currency,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        name,
        email,
        countryCode,
        gender,
        avatarUrl,
        city,
        currency,
      ];
}
