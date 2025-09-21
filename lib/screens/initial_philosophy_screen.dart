import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart' as app_main;

class InitialPhilosophyScreen extends StatefulWidget {
  const InitialPhilosophyScreen({super.key});

  @override
  State<InitialPhilosophyScreen> createState() => _InitialPhilosophyScreenState();
}

class _InitialPhilosophyScreenState extends State<InitialPhilosophyScreen> {
  final String _socratesQuote = "Que desgracia es para un hombre envejecer sin haber conocido la belleza y fuerza de la cual su cuerpo es capaz.";
  final String _socratesAuthor = "SÓCRATES";
  
  double _opacity = 0.0;
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _navigationTimer.cancel(); // Importante: cancelar el timer al destruir
    super.dispose();
  }

  void _startAnimation() {
    print("✅ InitialPhilosophyScreen: Iniciando animación");
    
    // Animación de fade in de la cita
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        print("✅ Animación fade in completada");
        setState(() => _opacity = 1.0);
      }
    });

    // Navegar automáticamente a Home después de 4 segundos - FORMA CORREGIDA
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        print("✅ Navegando a HomeScreen...");
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print("❌ Error: Widget no montado, no se puede navegar");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_main.betterMePrimaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF7B1FA2).withOpacity(0.9),
              const Color(0xFF6A1B9A).withOpacity(0.95),
              const Color(0xFF4A148C).withOpacity(1.0),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Frase de Sócrates
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 2000),
                  child: Text(
                    _socratesQuote,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Autor (Sócrates)
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 2500),
                  child: Text(
                    _socratesAuthor,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2.0,
                    ),
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