import 'package:store/features/authentication/data/models/user_model.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';

/// Data model representing an authentication session from API response.
class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required super.token,
    required UserModel super.user,
    super.refreshToken,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    return AuthSessionModel(
      token: (json['token'] ?? json['access_token'] ?? '').toString(),
      refreshToken: json['refresh_token'] as String?,
      user: UserModel.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': (user as UserModel).toJson(),
    };
  }
}
