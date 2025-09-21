import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart' as app_main;

class FitnessPhilosophyScreen extends StatefulWidget {
  const FitnessPhilosophyScreen({super.key});

  @override
  State<FitnessPhilosophyScreen> createState() => _FitnessPhilosophyScreenState();
}

class _FitnessPhilosophyScreenState extends State<FitnessPhilosophyScreen> {
  final List<Map<String, String>> _fitnessQuotes = [
    {
      "quote": "El dolor que sientes hoy será la fuerza que sientas mañana.",
      "author": "ARNOLD SCHWARZENEGGER"
    },
    {
      "quote": "No cuentes los días, haz que los días cuenten.",
      "author": "MUHAMMAD ALI"
    },
    {
      "quote": "La fuerza no viene de la capacidad física, sino de la voluntad indomable.",
      "author": "MAHATMA GANDHI"
    },
    {
      "quote": "El hierro se desafía a sí mismo cada vez que entras al gimnasio.",
      "author": "RONNIE COLEMAN"
    },
    {
      "quote": "El cuerpo logra lo que la mente cree.",
      "author": "NIPO STRONG"
    },
    {
      "quote": "No te rindas. Sufre ahora y vive el resto de tu vida como un campeón.",
      "author": "MUHAMMAD ALI"
    },
    {
      "quote": "Lo imposible es solo una opinión.",
      "author": "PAULO COELHO"
    },
    {
      "quote": "La disciplina es el puente entre las metas y los logros.",
      "author": "JIM ROHN"
    },
    {
      "quote": "Cuando quieres sucumbir, es cuando más debes luchar.",
      "author": "DAVID GOGGINS"
    },
    {
      "quote": "El éxito se construye con sudor, dedicación y sacrificio.",
      "author": "LEBRON JAMES"
    },
    {
      "quote": "No importa lo lento que vayas, siempre y cuando no te detengas.",
      "author": "CONFUCIO"
    },
    {
      "quote": "El único límite es el que te pones a ti mismo.",
      "author": "USAIN BOLT"
    },
    {
      "quote": "El músculo crece fuera de tu zona de confort.",
      "author": "UNKNOWN SOLDIER"
    },
    {
      "quote": "Cada repetición te acerca a tu mejor versión.",
      "author": "RICHARD HAWKING"
    },
    {
      "quote": "La fuerza es producto de la lucha.",
      "author": "BROCK LESNAR"
    },
    {
      "quote": "El temple se forja en el fuego del esfuerzo.",
      "author": "MIKE TYSON"
    },
    {
      "quote": "No busques ser el mejor, busca ser mejor que ayer.",
      "author": "JOHN CENA"
    },
    {
      "quote": "El guerrero no se define por sus victorias, sino por sus batallas.",
      "author": "BRUCE LEE"
    },
    {
      "quote": "Cada gota de sudor es una lágrima de debilidad abandonando tu cuerpo.",
      "author": "GREG PLITT"
    },
    {
      "quote": "El hierro nunca miente. O lo levantas o no.",
      "author": "HENRY ROLLINS"
    },
    {
      "quote": "La grandeza requiere coraje, disciplina y corazón.",
      "author": "JOE ROGAN"
    },
    {
      "quote": "No hay ascensor al éxito, debes tomar las escaleras.",
      "author": "ZIG ZIGLAR"
    },
    {
      "quote": "El miedo es una ilusión. La fuerza es una decisión.",
      "author": "CONOR MCGREGOR"
    },
    {
      "quote": "Cada día es una oportunidad para ser más fuerte.",
      "author": "RICH FRONING"
    },
    {
      "quote": "El dolor es temporal, el orgullo es para siempre.",
      "author": "UNKNOWN ATHLETE"
    },
    {
      "quote": "La mente es el límite. Si la mente puede concebirlo, el cuerpo puede lograrlo.",
      "author": "ARNOLD SCHWARZENEGGER"
    },
    {
      "quote": "No te compares con otros. Compárate con quien eras ayer.",
      "author": "DAVID GOGGINS"
    },
    {
      "quote": "El éxito es la suma de pequeños esfuerzos repetidos día tras día.",
      "author": "ROBERT COLLIER"
    },
    {
      "quote": "La consistencia es lo que transforma lo ordinario en extraordinario.",
      "author": "JIM KWIK"
    },
    {
      "quote": "El fuego del esfuerzo purifica el alma del débil.",
      "author": "MARCUS AURELIUS"
    },
    {
      "quote": "No esperes a que llegue la motivación. Ve y búscala en el gimnasio.",
      "author": "JOCKO WILLINK"
    },
    {
      "quote": "Cada peso levantado es un paso hacia la libertad.",
      "author": "HENRY CAVILL"
    },
    {
      "quote": "La verdadera fuerza está en superarte a ti mismo.",
      "author": "CRISTIANO RONALDO"
    },
    {
      "quote": "El carácter se construye en los momentos de dificultad.",
      "author": "THE ROCK"
    },
    {
      "quote": "No hay atajos para cualquier lugar que valga la pena.",
      "author": "BEVERLY SILLS"
    },
    {
      "quote": "El sudor de hoy es el éxito de mañana.",
      "author": "UNKNOWN CHAMPION"
    },
    {
      "quote": "La resistencia no es física, es mental.",
      "author": "DEAN KARNAZES"
    },
    {
      "quote": "Cada batalla ganada en el gimnasio es una guerra ganada en la vida.",
      "author": "ELLIOT HULSE"
    },
    {
      "quote": "El crecimiento duele, la transformación duele, pero nada duele tanto como el arrepentimiento.",
      "author": "UNKNOWN WARRIOR"
    },
    {
      "quote": "No busques el momento perfecto, haz el momento perfecto.",
      "author": "MICHAEL JORDAN"
    },
    {
      "quote": "La grandeza requiere grandes sacrificios.",
      "author": "KOBE BRYANT"
    },
    {
      "quote": "El hierro te enseña humildad y te da confianza.",
      "author": "HENRY ROLLINS"
    },
    {
      "quote": "Cada repetición extra es una victoria sobre tu yo anterior.",
      "author": "RICHARD BRANSON"
    },
    {
      "quote": "El cuerpo alcanza lo que la mente cree.",
      "author": "NIPO STRONG"
    },
    {
      "quote": "No hay gloria sin sacrificio.",
      "author": "DWAYNE JOHNSON"
    },
    {
      "quote": "La disciplina es elegir entre lo que quieres ahora y lo que quieres más.",
      "author": "ABRAHAM LINCOLN"
    },
    {
      "quote": "El fuego que quema también purifica.",
      "author": "FRIEDRICH NIETZSCHE"
    },
    {
      "quote": "Cada día es una nueva oportunidad para ser mejor.",
      "author": "TONY ROBBINS"
    },
    {
      "quote": "La verdadera competición es contra tu yo de ayer.",
      "author": "JAPANESE PROVERB"
    },
    {
      "quote": "No hay substitute para el trabajo duro.",
      "author": "THOMAS EDISON"
    },
    {
      "quote": "El dolor es solo debilidad abandonando el cuerpo.",
      "author": "US MARINE CORPS"
    }
  ];

  late Map<String, String> _currentQuote;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _selectRandomQuote();
    _startAnimation();
  }

  void _selectRandomQuote() {
    final random = Random();
    _currentQuote = _fitnessQuotes[random.nextInt(_fitnessQuotes.length)];
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/workout');
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
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 1500),
                  child: Text(
                    _currentQuote['quote']!,
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
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 2000),
                  child: Text(
                    _currentQuote['author']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
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