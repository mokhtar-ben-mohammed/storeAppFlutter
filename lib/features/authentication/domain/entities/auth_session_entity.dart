import 'package:equatable/equatable.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';

/// Domain entity representing an authenticated session with access tokens.
class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.token,
    required this.user,
    this.refreshToken,
  });

  final String token;
  final UserEntity user;
  final String? refreshToken;

  @override
  List<Object?> get props => [token, user, refreshToken];
}
