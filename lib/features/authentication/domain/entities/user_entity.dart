import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated Burhan user.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.phone,
    this.name,
    this.email,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;

  @override
  List<Object?> get props => [id, phone, name, email];
}
