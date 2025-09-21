// lib/blocs/auth/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Método para verificar si ya hay una sesión activa
  Future<void> checkAuthStatus() async {
    try {
      final userBox = await Hive.openBox('userProfile');
      final user = userBox.get('user');

      if (user != null && user['loggedIn'] == true) {
        emit(AuthSuccess(user['email'], user['name'] ?? 'Usuario'));
      }
    } catch (e) {
      // No emitimos error, solo mantenemos el estado inicial
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulamos

      final userBox = await Hive.openBox('userProfile');
      await userBox.put('user', {
        'email': email,
        'loggedIn': true,
        'lastLogin': DateTime.now().toString(),
      });

      emit(AuthSuccess(email, 'Usuario'));
    } catch (e) {
      emit(AuthFailure('Error en login: $e'));
    }
  }

  Future<void> logout() async {
    try {
      final userBox = await Hive.openBox('userProfile');
      await userBox.put('user', null);
      emit(AuthInitial());
    } catch (e) {
      // Manejo de errores si la operación de logout falla
      print('Error durante el logout: $e');
    }
  }
}