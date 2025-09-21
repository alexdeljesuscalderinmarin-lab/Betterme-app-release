import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart' as app_main;

class NutritionPhilosophyScreen extends StatefulWidget {
  const NutritionPhilosophyScreen({super.key});

  @override
  State<NutritionPhilosophyScreen> createState() => _NutritionPhilosophyScreenState();
}

class _NutritionPhilosophyScreenState extends State<NutritionPhilosophyScreen> {
  final List<Map<String, String>> _nutritionQuotes = [
    {
      "quote": "Que tu alimento sea tu medicina y tu medicina sea tu alimento.",
      "author": "HIPÓCRATES"
    },
    {
      "quote": "Somos lo que comemos, pero somos más lo que digerimos.",
      "author": "MAHATMA GANDHI"
    },
    {
      "quote": "La salud no es solo la ausencia de enfermedad, es un estado de completo bienestar.",
      "author": "ORGANIZACIÓN MUNDIAL DE LA SALUD"
    },
    {
      "quote": "El hombre es dueño de su silencio y esclavo de sus palabras.",
      "author": "ARISTÓTELES"
    },
    {
      "quote": "La vida es simple, pero insistimos en hacerla complicada.",
      "author": "CONFUCIO"
    },
    {
      "quote": "La belleza comienza en el interior.",
      "author": "ROALD DAHL"
    },
    {
      "quote": "Cada bocado es una oportunidad para nutrir tu cuerpo.",
      "author": "JILLIAN MICHAELS"
    },
    {
      "quote": "La paciencia es amarga, pero su fruto es dulce.",
      "author": "JEAN-JACQUES ROUSSEAU"
    },
    {
      "quote": "El agua es el vehículo de la naturaleza.",
      "author": "LEONARDO DA VINCI"
    },
    {
      "quote": "La moderación es la clave para una vida duradera.",
      "author": "HIPÓCRATES"
    },
    {
      "quote": "La gratitud transforma lo que tenemos en suficiente.",
      "author": "AESOP"
    },
    {
      "quote": "El sabio no busca llenar su vida de cosas, sino de significado.",
      "author": "SÉNECA"
    },
    {
      "quote": "La naturaleza nunca se apresura, sin embargo, todo se logra.",
      "author": "LAO TZU"
    },
    {
      "quote": "La verdadera riqueza es la salud, no el oro y la plata.",
      "author": "MAHATMA GANDHI"
    },
    {
      "quote": "Come para vivir, no vivas para comer.",
      "author": "SÓCRATES"
    },
    {
      "quote": "La simplicidad es la máxima sofisticación.",
      "author": "LEONARDO DA VINCI"
    },
    {
      "quote": "El mejor momento para plantar un árbol fue hace 20 años. El segundo mejor momento es ahora.",
      "author": "PROVERBIO CHINO"
    },
    {
      "quote": "La vida es un eco. Lo que envías, regresa.",
      "author": "PROVERBIO BUDISTA"
    },
    {
      "quote": "La felicidad no es algo hecho. Viene de tus propias acciones.",
      "author": "DALAI LAMA"
    },
    {
      "quote": "El conocimiento habla, pero la sabiduría escucha.",
      "author": "JIMI HENDRIX"
    },
    {
      "quote": "La salud es la mayor posesión.",
      "author": "LAO TZU"
    },
    {
      "quote": "El cambio es la única constante en la vida.",
      "author": "HERÁCLITO"
    },
    {
      "quote": "La mente es todo. Lo que piensas, te conviertes.",
      "author": "BUDA"
    },
    {
      "quote": "El tiempo disfrutado no es tiempo perdido.",
      "author": "BERTRAND RUSSELL"
    },
    {
      "quote": "La naturaleza no tiene prisa, pero todo se logra.",
      "author": "LAO TZU"
    },
    {
      "quote": "El silencio es la mayor revelación.",
      "author": "LAO TZU"
    },
    {
      "quote": "La vida es realmente simple, pero insistimos en hacerla complicada.",
      "author": "CONFUCIO"
    },
    {
      "quote": "El sabio puede cambiar de mente. El necio, nunca.",
      "author": "IMMANUEL KANT"
    },
    {
      "quote": "La calidad de tu vida depende de la calidad de tus pensamientos.",
      "author": "MARCO AURELIO"
    },
    {
      "quote": "El conocimiento es poder, pero la sabiduría es libertad.",
      "author": "WILLIAM JAMES"
    },
    {
      "quote": "La paciencia es un árbol de raíz amarga pero de frutos muy dulces.",
      "author": "PROVERBIO PERSA"
    },
    {
      "quote": "El agua blanda termina por perforar la piedra dura.",
      "author": "OVIDIO"
    },
    {
      "quote": "La verdadera medida de un hombre es cómo trata a alguien que no le puede hacer ningún bien.",
      "author": "SAMUEL JOHNSON"
    },
    {
      "quote": "El éxito es la suma de pequeños esfuerzos repetidos día tras día.",
      "author": "ROBERT COLLIER"
    },
    {
      "quote": "La vida es 10% lo que me ocurre y 90% cómo reacciono a ello.",
      "author": "CHARLES SWINDOLL"
    },
    {
      "quote": "El mejor proyecto en el que trabajar eres tú mismo.",
      "author": "JIM ROHN"
    },
    {
      "quote": "La gratitud no es solo la mayor de las virtudes, sino la madre de todas las demás.",
      "author": "CICERÓN"
    },
    {
      "quote": "El hombre que mueve montañas comienza cargando pequeñas piedras.",
      "author": "CONFUCIO"
    },
    {
      "quote": "La simplicidad es la clave de la brillantez.",
      "author": "BRUCE LEE"
    },
    {
      "quote": "El tiempo es el mejor maestro, pero desafortunadamente mata a todos sus estudiantes.",
      "author": "HECTOR BERLIOZ"
    },
    {
      "quote": "La vida es lo que pasa mientras estás ocupado haciendo otros planes.",
      "author": "JOHN LENNON"
    },
    {
      "quote": "El secreto de la felicidad no es hacer lo que uno quiere, sino querer lo que uno hace.",
      "author": "LEO TOLSTOY"
    },
    {
      "quote": "La mayor gloria no es no caer nunca, sino levantarse siempre.",
      "author": "CONFUCIO"
    },
    {
      "quote": "El que tiene un porqué para vivir puede soportar casi cualquier cómo.",
      "author": "FRIEDRICH NIETZSCHE"
    },
    {
      "quote": "La belleza de la vida no está en la duración, sino en la profundidad.",
      "author": "RALPH WALDO EMERSON"
    },
    {
      "quote": "El único verdadero viaje de descubrimiento consiste no en buscar nuevos paisajes, sino en mirar con nuevos ojos.",
      "author": "MARCEL PROUST"
    },
    {
      "quote": "La vida es corta, pero ancha.",
      "author": "EMILY DICKINSON"
    },
    {
      "quote": "El mejor momento del día es ahora.",
      "author": "PROVERBIO ZEN"
    },
    {
      "quote": "La naturaleza no hace nada incompleto ni nada en vano.",
      "author": "ARISTÓTELES"
    },
    {
      "quote": "El sabio no dice todo lo que piensa, pero siempre piensa todo lo que dice.",
      "author": "ARISTÓTELES"
    },
    {
      "quote": "La salud es la riqueza real y no piezas de oro y plata.",
      "author": "MAHATMA GANDHI"
    },
    {
      "quote": "El bienestar y la salud son un deber, de lo contrario no podríamos mantener nuestra mente fuerte y clara.",
      "author": "BUDA"
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
    _currentQuote = _nutritionQuotes[random.nextInt(_nutritionQuotes.length)];
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/add_food');
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