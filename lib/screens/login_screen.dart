// lib/screens/login_screen.dart - VERSIÓN MEJORADA CON FIREBASE
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart'; // 🆕 Importar el servicio de autenticación

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await AuthService.signInWithEmail(email, password);
      
      // 🎯 Navegar al home si el login es exitoso
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot_password');
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: betterMeBackgroundColor,
      appBar: AppBar(
        backgroundColor: betterMeBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: betterMeTextColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎯 LOGO O ICONO
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: betterMePrimaryColor,
                ),
                const SizedBox(height: 20),
                
                // 🎯 TÍTULO
                const Text(
                  'Inicia Sesión en BetterMe',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: betterMePrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                Text(
                  'Tu asistente personal de nutrición y fitness',
                  style: TextStyle(
                    fontSize: 16,
                    color: betterMeTextColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 🎯 CAMPO EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: betterMeTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: betterMePrimaryColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.email, color: betterMePrimaryColor),
                  ),
                  style: TextStyle(color: betterMeTextColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 🎯 CAMPO CONTRASEÑA
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: betterMeTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: betterMePrimaryColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: betterMePrimaryColor),
                  ),
                  style: TextStyle(color: betterMeTextColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 🎯 OLVIDÉ CONTRASEÑA
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: betterMePrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🎯 MENSAJE DE ERROR
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[800]),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 20),

                // 🎯 BOTÓN INICIAR SESIÓN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: betterMePrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🎯 DIVISOR
                Row(
                  children: [
                    Expanded(child: Divider(color: betterMeTextColor.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o continúa con',
                        style: TextStyle(color: betterMeTextColor.withOpacity(0.7)),
                      ),
                    ),
                    Expanded(child: Divider(color: betterMeTextColor.withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 20),

                // 🎯 BOTÓN GOOGLE
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: betterMePrimaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continuar con Google',
                          style: TextStyle(
                            fontSize: 16,
                            color: betterMePrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🎯 REGISTRARSE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(color: betterMeTextColor),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: Text(
                        'Regístrate',
                        style: TextStyle(
                          color: betterMePrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}