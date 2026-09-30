import 'dart:convert';

import 'package:store/features/authentication/domain/entities/user_entity.dart';

/// Data model representing a user from API responses.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    super.name,
    super.email,
    super.countryCode,
    super.gender,
    super.avatarUrl,
    super.city,
    super.currency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      countryCode: (json['country_code'] as String?)?.trim(),
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      city: _parseCity(json['city']),
      currency: _parseCurrency(json['currency']),
    );
  }

  static UserCityEntity? _parseCity(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = (map['id'] as num?)?.toInt() ?? 0;
    if (id < 1) return null;
    return UserCityEntity(
      id: id,
      nameAr: (map['name_ar'] ?? '').toString(),
      nameEn: map['name_en'] as String?,
      countryId: (map['country_id'] as num?)?.toInt(),
    );
  }

  static UserCurrencyEntity? _parseCurrency(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = (map['id'] as num?)?.toInt() ?? 0;
    if (id < 1) return null;
    return UserCurrencyEntity(
      id: id,
      code: (map['code'] ?? '').toString(),
      nameAr: (map['name_ar'] ?? '').toString(),
      nameEn: map['name_en'] as String?,
      symbol: map['symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (countryCode != null) 'country_code': countryCode,
      if (gender != null) 'gender': gender,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (city != null)
        'city': {
          'id': city!.id,
          'name_ar': city!.nameAr,
          if (city!.nameEn != null) 'name_en': city!.nameEn,
          if (city!.countryId != null) 'country_id': city!.countryId,
        },
      if (currency != null)
        'currency': {
          'id': currency!.id,
          'code': currency!.code,
          'name_ar': currency!.nameAr,
          if (currency!.nameEn != null) 'name_en': currency!.nameEn,
          if (currency!.symbol != null) 'symbol': currency!.symbol,
        },
    };
  }

  String toStorageJson() => jsonEncode(toJson());

  factory UserModel.fromStorageJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return const UserModel(id: '', phone: '');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(decoded));
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phone: entity.phone,
      name: entity.name,
      email: entity.email,
      countryCode: entity.countryCode,
      gender: entity.gender,
      avatarUrl: entity.avatarUrl,
      city: entity.city,
      currency: entity.currency,
    );
  }
}
