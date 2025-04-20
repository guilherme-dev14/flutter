import 'package:equatable/equatable.dart';
import '../../../data/models/auth.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthModel auth;

  AuthAuthenticated(this.auth);

  @override
  List<Object?> get props => [auth];
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {}