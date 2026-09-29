import 'package:store/features/authentication/domain/entities/user_entity.dart';

/// Data model representing a user from API responses.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    super.name,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phone: entity.phone,
      name: entity.name,
      email: entity.email,
    );
  }
}
