// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      
      await AuthService.resetPassword(email);
      
      setState(() {
        _isLoading = false;
        _emailSent = true;
        _successMessage = 'Hemos enviado un enlace de recuperación a $email';
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _tryAgain() {
    setState(() {
      _emailSent = false;
      _emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: betterMeBackgroundColor,
      appBar: AppBar(
        backgroundColor: betterMeBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: betterMeTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🎯 ICONO
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: betterMePrimaryColor,
                ),
                const SizedBox(height: 20),
                
                // 🎯 TÍTULO
                Text(
                  _emailSent ? 'Revisa tu Email' : 'Recuperar Contraseña',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: betterMePrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                Text(
                  _emailSent 
                    ? 'Sigue las instrucciones que enviamos a tu correo'
                    : 'Ingresa tu email para restablecer tu contraseña',
                  style: TextStyle(
                    fontSize: 16,
                    color: betterMeTextColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                if (!_emailSent) ...[
                  // 🎯 CAMPO EMAIL (SOLO SI NO SE HA ENVIADO)
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
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                ],

                // 🎯 MENSAJE DE ÉXITO
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[800], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (_successMessage != null) const SizedBox(height: 20),

                // 🎯 MENSAJE DE ERROR
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[800], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (_errorMessage != null) const SizedBox(height: 20),

                if (_emailSent) ...[
                  // 🎯 INSTRUCCIONES DESPUÉS DE ENVIAR EMAIL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: betterMeCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.mark_email_read, color: betterMePrimaryColor),
                          title: Text('Revisa tu bandeja de entrada', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Busca el email de BetterMe'),
                        ),
                        ListTile(
                          leading: Icon(Icons.link, color: betterMePrimaryColor),
                          title: Text('Haz clic en el enlace', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Te llevará a una página para crear nueva contraseña'),
                        ),
                        ListTile(
                          leading: Icon(Icons.lock, color: betterMePrimaryColor),
                          title: Text('Crea una nueva contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Usa una contraseña segura y fácil de recordar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                if (!_emailSent) 
                  // 🎯 BOTÓN ENVIAR (SOLO SI NO SE HA ENVIADO)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
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
                              'Enviar Enlace de Recuperación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                if (_emailSent) 
                  // 🎯 BOTONES DESPUÉS DE ENVIAR
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _tryAgain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: betterMePrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Enviar a otro email'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            'Volver al Login',
                            style: TextStyle(
                              color: betterMePrimaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // 🎯 INFORMACIÓN ADICIONAL
                if (!_emailSent)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: betterMeCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Qué esperar?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: betterMePrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Recibirás un email con un enlace seguro\n'
                          '• El enlace expira en 1 hora por seguridad\n'
                          '• Podrás crear una nueva contraseña\n'
                          '• Luego inicia sesión con tus nuevas credenciales',
                          style: TextStyle(
                            color: betterMeTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}