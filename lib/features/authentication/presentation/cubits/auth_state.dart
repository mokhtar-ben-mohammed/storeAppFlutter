import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/authentication/domain/entities/auth_session_entity.dart';

/// Base state for authentication workflow.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to any action or session restoration.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Emitted while performing authentication operations (checking session, sending OTP, verifying OTP).
final class AuthLoading extends AuthState {
  const AuthLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when 6-digit OTP has been sent successfully to the phone number.
final class AuthOtpSent extends AuthState {
  const AuthOtpSent({
    required this.countryCode,
    required this.phone,
  });

  final String countryCode;
  final String phone;

  @override
  List<Object?> get props => [countryCode, phone];
}

/// Emitted when session is authenticated and active.
final class Authenticated extends AuthState {
  const Authenticated(this.session);

  final AuthSessionEntity session;

  @override
  List<Object?> get props => [session];
}

/// Emitted when user is not authenticated (after logout or first launch).
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Emitted when the user continues browsing without signing in.
final class GuestBrowsing extends AuthState {
  const GuestBrowsing();
}

/// Emitted when an authentication operation fails.
final class AuthFailure extends AuthState {
  const AuthFailure(this.failure);

  final Failure failure;

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
