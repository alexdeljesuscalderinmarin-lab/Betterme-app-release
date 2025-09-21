import 'package:flutter/material.dart';
import '../services/ai_recommendation_service.dart';
import '../services/hive_service.dart'; // ✅ Cambiado a HiveService
import '../main.dart' as app_main; // ✅ Alias para evitar conflicto

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  RecommendationsScreenState createState() => RecommendationsScreenState();
}

class RecommendationsScreenState extends State<RecommendationsScreen> {
  late Map<String, dynamic> _recommendations;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      // ✅ USAMOS HIVE EN LUGAR DE AppMemory
      final user = HiveService.getCurrentUser();
      
      if (user != null) {
        final recommendations = 
            await AIRecommendationService.getPersonalizedRecommendations(user);
        
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se encontró información del usuario. Completa el onboarding primero.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar recomendaciones: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_main.betterMeBackgroundColor,
      appBar: AppBar(
        title: const Text('Tus Metas Personalizadas', 
            style: TextStyle(color: app_main.betterMeTextColor)),
        backgroundColor: app_main.betterMeBackgroundColor,
        iconTheme: const IconThemeData(color: app_main.betterMePrimaryColor),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: app_main.betterMePrimaryColor))
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error, 
                      style: const TextStyle(color: app_main.betterMeTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _buildRecommendationsContent(),
    );
  }

  Widget _buildRecommendationsContent() {
    // ✅ OBTENEMOS USUARIO DE HIVE
    final user = HiveService.getCurrentUser();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TARJETA PRINCIPAL CON EXPLICACIÓN DE CALORÍAS
          if (user != null && user.dailyCalories > 0)
            Card(
              color: app_main.betterMeCardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 Tu Meta Calórica Diaria',
                      style: TextStyle(
                        color: app_main.betterMePrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '${user.dailyCalories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // ✅ EXPLICACIÓN DETALLADA
                    const Text(
                      '¿Por qué esta cantidad?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _recommendations['explanation'] ?? """
Basado en tu perfil:
- ${user.age} años, ${user.gender.toLowerCase()}
- ${user.weight} kg de peso, ${user.height} cm de estatura
- Objetivo: ${user.goal}
- Nivel de actividad: ${user.lifestyle}

Esta meta está diseñada para ayudarte a ${user.goal.toLowerCase()} de manera saludable y sostenible, manteniendo tu energía y protegiendo tu masa muscular.
""",
                      style: const TextStyle(
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ✅ DISTRIBUCIÓN DE MACRONUTRIENTES
          if (user != null && user.dailyCalories > 0)
            Card(
              color: app_main.betterMeCardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Distribución Diaria de Macronutrientes',
                      style: TextStyle(
                        color: app_main.betterMePrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMacroRow('🍗 Proteína', '${user.proteinGoal.round()}g', Colors.blue),
                    _buildMacroRow('🍚 Carbohidratos', '${user.carbsGoal.round()}g', Colors.green),
                    _buildMacroRow('🥑 Grasas', '${user.fatGoal.round()}g', Colors.orange),
                    const SizedBox(height: 10),
                    const Text(
                      'Esta distribución optimiza tu energía, saciedad y resultados.',
                      style: TextStyle(
                        fontSize: 12, 
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ✅ RECOMENDACIONES NUTRICIONALES
          Card(
            color: app_main.betterMeCardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🍎 Recomendaciones Nutricionales',
                    style: TextStyle(
                      color: app_main.betterMePrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _recommendations['nutrition'] ?? """
• Prioriza proteínas magras en cada comida
• Incluye carbohidratos complejos para energía sostenida
• No temas las grasas saludables (aguacate, nueces, aceite de oliva)
• Mantente hidratado con 2-3L de agua diarios
• Come vegetales en abundancia
""",
                    style: const TextStyle(
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ PLAN DE EJERCICIO
          Card(
            color: app_main.betterMeCardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💪 Plan de Ejercicio',
                    style: TextStyle(
                      color: app_main.betterMePrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _recommendations['exercise'] ?? """
• Entrenamiento de fuerza 3-4 veces por semana
• Cardio moderado 2-3 veces por semana
• Descanso activo los días de recuperación
• Enfócate en la forma antes que el peso
• Progresa gradualmente cada semana
""",
                    style: const TextStyle(
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ METAS SEMANALES
          Card(
            color: app_main.betterMeCardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📅 Metas Semanales Clave',
                    style: TextStyle(
                      color: app_main.betterMePrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _recommendations['goals'] ?? """
1. ✅ Cumplir tus calorías diarias (±10%)
2. ✅ Alcanzar ${user?.proteinGoal.round() ?? 150}g de proteína diaria
3. ✅ Entrenar 3-4 veces esta semana
4. ✅ Beber 2-3L de agua diarios
5. ✅ Dormir 7-8 horas cada noche

¡Enfócate en estos fundamentos primero! La consistencia es clave.
""",
                    style: const TextStyle(
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          
          // ✅ BOTÓN PARA IR AL HOME (MEJORADO)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/philosophy');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: app_main.betterMePrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '¡Entendido! Ir al Inicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}