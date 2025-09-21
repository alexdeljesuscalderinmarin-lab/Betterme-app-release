// splash_screen.dart - VERSIÓN CORREGIDA Y OPTIMIZADA
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/hive_service.dart';
import '../main.dart'; // Para betterMePrimaryColor

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final String _appPhrase = "Alimentate, Ejercitate... Se tu mejor versión";
  bool _isInitialized = false;
  String _loadingStatus = "Inicializando...";

  @override
  void initState() {
    super.initState();
    // Pequeño delay para que se vea el splash nativo
    Future.delayed(const Duration(milliseconds: 500), _initializeApp);
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _loadingStatus = "Cargando configuración...");
      
      await HiveService.initialize();
      
      setState(() {
        _isInitialized = true;
        _loadingStatus = "Cargando experiencia...";
      });

      // Espera mínima para mostrar la animación
      await Future.delayed(const Duration(seconds: 2));

      // Verificar onboarding
      final settingsBox = Hive.box('settingsBox');
      final onboardingCompleted = settingsBox.get('onboardingCompleted', defaultValue: false);
      
      if (!mounted) return;

      // Navegación
      Navigator.pushReplacementNamed(
        context, 
        onboardingCompleted ? '/home' : '/onboarding'
      );

    } catch (e) {
      print('Error en inicialización: $e');
      if (!mounted) return;
      
      setState(() => _loadingStatus = "Optimizando experiencia...");
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: betterMePrimaryColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7B1FA2),
              Color(0xFF6A1B9A),
              Color(0xFF4A148C),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con animación mejorada
              AnimatedOpacity(
                opacity: _isInitialized ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                child: const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              
              // Nombre de la app
              AnimatedOpacity(
                opacity: _isInitialized ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: const Text(
                  'BetterMe',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Frase de la app
              AnimatedOpacity(
                opacity: _isInitialized ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    _appPhrase,
                    style: const TextStyle(
                      fontSize: 16, // Reducido para mejor visualización
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Indicador de progreso
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Texto de estado
              AnimatedOpacity(
                opacity: _isInitialized ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  _loadingStatus,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}