// lib/blocs/auth/auth_state.dart

import 'package:flutter/foundation.dart'; // Add this import

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String email;
  final String name;

  // The 'const' keyword has been removed here to fix the error.
  AuthSuccess(this.email, this.name);
}

class AuthFailure extends AuthState {
  final String error;

  // The 'const' keyword has been removed here to fix the error.
  AuthFailure(this.error);
}
