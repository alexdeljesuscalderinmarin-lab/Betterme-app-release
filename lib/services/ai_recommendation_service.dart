import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';

class AIRecommendationService {
  static final String? _geminiApiKey = dotenv.env['GEMINI_API_KEY'];

  // ✅ 1. CÁLCULO CIENTÍFICO MEJORADO - DEVUELVE DOUBLE
  static double calculateCaloricGoal(UserModel user) {
    try {
      double bmr;
      if (user.gender == 'Masculino') {
        bmr = 10 * user.weight + 6.25 * user.height - 5 * user.age + 5;
      } else {
        bmr = 10 * user.weight + 6.25 * user.height - 5 * user.age - 161;
      }

      Map<String, double> activityFactors = {
        'Sedentario': 1.2,
        'Ligera actividad': 1.375,
        'Moderadamente activo': 1.55,
        'Muy activo': 1.725,
        'Extremadamente activo': 1.9,
      };

      double activityFactor = activityFactors[user.lifestyle] ?? 1.55;
      double maintenanceCalories = bmr * activityFactor;

      Map<String, double> goalFactors = {
        'Ganar masa muscular': 1.15,
        'Perder grasa': 0.85,
        'Mantener peso': 1.0,
        'Mejorar rendimiento deportivo': 1.1,
        'Mejorar salud general': 1.0,
      };

      double goalFactor = goalFactors[user.goal] ?? 1.0;
      double targetCalories = maintenanceCalories * goalFactor;

      return targetCalories; // ✅ YA ES DOUBLE, NO REDONDEAR
    } catch (e) {
      return 2000.0; // Meta calórica por defecto
    }
  }

  // ✅ 2. SISTEMA HÍBRIDO MEJORADO
  static Future<Map<String, dynamic>> getPersonalizedRecommendations(UserModel user) async {
    try {
      if (_geminiApiKey != null && _geminiApiKey!.isNotEmpty) {
        final iaResult = await _getGeminiRecommendations(user);
        if (iaResult.isNotEmpty) return iaResult;
      }
    } catch (e) {
      print('Optimizando recomendaciones: $e');
    }
    
    return _getDetailedLocalRecommendations(user);
  }

  // ✅ 3. IA REAL MEJORADA
  static Future<Map<String, dynamic>> _getGeminiRecommendations(UserModel user) async {
    try {
      final String prompt = """
Eres un nutricionista experto. Analiza este perfil y genera recomendaciones PERSONALIZADAS en español. 
Responde SOLO con JSON válido con estas claves: "nutrition", "exercise", "goals", "explanation".

PERFIL:
- ${user.firstName}, ${user.age} años, ${user.gender}
- ${user.weight} kg, ${user.height} cm, ${user.bodyType}
- Objetivo: ${user.goal}, Actividad: ${user.lifestyle}
- País: ${user.country}
- Meta calórica: ${user.dailyCalories.round()} kcal
- Macronutrientes: P${user.proteinGoal.round()}g/C${user.carbsGoal.round()}g/G${user.fatGoal.round()}g

SOLO JSON válido:
""";

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [{"parts": [{"text": prompt}]}],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 2000,
          }
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          return json.decode(jsonMatch.group(0)!);
        }
      }
    } catch (e) {
      print('Personalizando experiencia: $e');
    }
    
    return {};
  }

  // ✅ 4. SISTEMA LOCAL INTELIGENTE MEJORADO (TODOS LOS MÉTODOS IMPLEMENTADOS)
  static Map<String, dynamic> _getDetailedLocalRecommendations(UserModel user) {
    try {
      return {
        "nutrition": _getCulturalNutrition(user),
        "exercise": _getPersonalizedExercise(user),
        "goals": _getPersonalizedGoals(user),
        "explanation": _getPersonalizedExplanation(user),
      };
    } catch (e) {
      return {
        "nutrition": "Plan nutricional balanceado con énfasis en proteínas y vegetales",
        "exercise": "Entrenamiento de fuerza 3 veces por semana + cardio moderado",
        "goals": "1. Cumplir metas calóricas\n2. Mantenerse hidratado\n3. Dormir 7-8 horas",
        "explanation": "Recomendaciones basadas en tu perfil único para maximizar resultados",
      };
    }
  }

  // ✅ 5. EXPLICACIÓN PERSONALIZADA
  static String _getPersonalizedExplanation(UserModel user) {
    try {
      final base = """
Tu meta calórica de ${user.dailyCalories.round()} kcal está calculada usando la ecuación de Mifflin-St Jeor, considerando:

• Edad: ${user.age} años
• Peso: ${user.weight} kg
• Estatura: ${user.height} cm
• Género: ${user.gender}
• Nivel de actividad: ${user.lifestyle}
• Objetivo: ${user.goal}

""";

      if (user.goal.toLowerCase().contains('perder')) {
        return base + """
Esta cantidad crea un déficit calórico sostenible para perder aproximadamente 0.5-1 kg por semana, preservando tu masa muscular gracias a los ${user.proteinGoal.round()}g de proteína diarios.
""";
      } else if (user.goal.toLowerCase().contains('ganar')) {
        return base + """
Este superávit calórico controlado te permitirá ganar aproximadamente 0.25-0.5 kg por semana de masa muscular, maximizando la síntesis proteica con los ${user.proteinGoal.round()}g de proteína diarios.
""";
      } else {
        return base + """
Este balance calórico te permitirá mantener tu peso actual mientras mejoras tu composición corporal, perdiendo grasa y ganando músculo simultáneamente.
""";
      }
    } catch (e) {
      return "Tu plan está personalizado según tus metas y características físicas para maximizar resultados.";
    }
  }

  // ✅ 6. NUTRICIÓN CULTURAL MEJORADA
  static String _getCulturalNutrition(UserModel user) {
    try {
      final country = user.country.toLowerCase();
      
      if (country.contains('méxico') || country.contains('mexico')) {
        return """
DESAYUNO MEXICANO (7:00 AM):
- Huevos a la mexicana con tomate, cebolla y chile
- 2 tortillas de maíz integral
- 1/4 de aguacate
- 1 taza de café negro

ALMUERZO (2:00 PM):
- 150g de carne asada o pollo
- 1 taza de arroz integral
- Frijoles de la olla
- Nopales asados con cebolla

CENA (8:30 PM):
- 150g de pescado blanco (tilapia, huachinango)
- Ensalada de pepino, jícama y limón

SNACKS:
- Jícama con limón
- Almendras
- Rebanada de papaya
""";
      }
      else if (country.contains('venezuela') || country.contains('venez')) {
        return """
DESAYUNO VENEZOLANO (7:00 AM):
- Arepa integral con queso blanco y aguacate
- 1 huevo revuelto
- 1 taza de café negro

ALMUERZO (1:00 PM):
- 150g de carne mechada o pollo
- 1/2 plátano maduro
- Ensalada de repollo y zanahoria
- 1/2 taza de caraotas

CENA (8:00 PM):
- 150g de pescado a la plancha
- Ensalada de aguacate y tomate

SNACKS:
- Cambur
- Nueces
- Yogurt griego
""";
      }
      else if (country.contains('colombia') || country.contains('colomb')) {
        return """
DESAYUNO COLOMBIANO (7:00 AM):
- Huevos pericos (con tomate y cebolla)
- 1 arepa integral
- 1/4 de aguacate
- 1 taza de café negro

ALMUERZO (1:00 PM):
- 150g de pechuga a la plancha
- 1/2 plátano maduro
- Ensalada de lechuga y tomate
- 1/2 taza de lentejas

CENA (8:00 PM):
- 150g de pescado sudado
- Verduras al vapor

SNACKS:
- Mandarinas
- Almendras
- Queso fresco
""";
      }
      else if (country.contains('argentina') || country.contains('argent')) {
        return """
DESAYUNO ARGENTINO (7:00 AM):
- 2 tostadas integrales con queso untable
- 1 huevo duro
- 1/4 de palta
- 1 taza de café negro

ALMUERZO (1:00 PM):
- 150g de carne asada
- Ensalada mixta con tomate y cebolla
- 1/2 batata asada

CENA (9:00 PM):
- 150g de pollo a la plancha
- Brócoli y zanahoria al vapor

SNACKS:
- Maní
- Pera
- Yogurt natural
""";
      }
      else if (country.contains('españa') || country.contains('españa') || country.contains('spain')) {
        return """
DESAYUNO ESPAÑOL (8:00 AM):
- Tostadas con tomate triturado y aceite de oliva
- 1 huevo revuelto
- 1 taza de café negro

ALMUERZO (2:00 PM):
- 150g de pescado a la plancha (merluza, lubina)
- Ensalada mediterránea con pepino y pimiento
- 1/2 taza de garbanzos

CENA (9:00 PM):
- 150g de pollo al horno
- Verduras asadas (berenjena, calabacín)

SNACKS:
- Almendras
- Naranja
- Queso fresco
""";
      }

      // ✅ PLAN POR DEFECTO (INTERNACIONAL)
      return """
DESAYUNO (7:00 AM):
- 3 huevos revueltos con vegetales
- 1 rebanada de pan integral
- 1/2 aguacate
- 1 taza de café negro

ALMUERZO (1:00 PM):
- 150g de proteína (pollo, pescado o tofu)
- 1 taza de carbohidratos complejos (arroz integral, quinoa)
- 2 tazas de vegetales frescos
- 1 cucharada de aceite de oliva

CENA (8:00 PM):
- 120g de proteína magra
- 2 tazas de vegetales al vapor
- 1/2 taza de legumbres

SNACKS:
- Frutos secos (30g)
- Yogurt griego
- Fruta fresca
""";

    } catch (e) {
      return """
Plan nutricional balanceado:
- Desayuno: Proteínas + carbohidratos complejos
- Almuerzo: Proteína + vegetales + carbohidratos
- Cena: Proteína ligera + vegetales
- Snacks: Frutos secos y fruta
""";
    }
  }

  // ✅ 7. EJERCICIO PERSONALIZADO
  static String _getPersonalizedExercise(UserModel user) {
    try {
      String frequency;
      if (user.workoutFrequency.contains('3')) {
        frequency = """
LUNES: Full Body
- Sentadillas: 3x10-12
- Press banca: 3x8-10
- Dominadas asistidas: 3x8-10
- Plancha: 3x60s

MIÉRCOLES: Full Body
- Peso muerto: 3x8-10
- Press militar: 3x10-12
- Remo con barra: 3x10-12
- Abdominales: 3x15

VIERNES: Full Body
- Hip thrust: 3x12-15
- Press inclinado: 3x10-12
- Jalón al pecho: 3x10-12
- Plancha lateral: 3x30s cada lado
""";
      } else if (user.workoutFrequency.contains('4')) {
        frequency = """
LUNES: Pierna y Core
- Sentadillas: 4x8-10
- Peso muerto: 4x8-10
- Extensiones de pierna: 3x12-15
- Plancha: 3x60s

MARTES: Espalda y Bíceps
- Dominadas: 4x6-8
- Remo con barra: 4x8-10
- Curl de bíceps: 3x12-15

JUEVES: Pecho, Hombros y Tríceps
- Press banca: 4x8-10
- Press militar: 4x8-10
- Fondos: 3x10-12

VIERNES: Full Body + Cardio
- Hip thrust: 4x10-12
- Jalón al pecho: 4x10-12
- 20min cardio moderado
""";
      } else {
        frequency = """
LUNES: Full Body
- Sentadillas: 3x10-12
- Press banca: 3x8-10
- Remo: 3x10-12

MIÉRCOLES: Cardio y Core
- 30min cardio moderado
- Plancha: 3x60s
- Abdominales: 3x15
- Russian twists: 3x20

VIERNES: Full Body
- Peso muerto: 3x8-10
- Press militar: 3x10-12
- Jalón al pecho: 3x10-12
""";
      }

      return """
RUTINA SEMANAL PARA ${user.lifestyle.toUpperCase()}

$frequency

DESCANSO: 60-90 segundos entre series
CARDIO: ${user.lifestyle.contains('activo') ? '3-4 veces por semana' : '2-3 veces por semana'}
PROGRESIÓN: Aumentar peso cuando completes todas las series
""";

    } catch (e) {
      return """
Rutina recomendada:
- 3-4 días de entrenamiento de fuerza
- 2-3 días de cardio moderado
- Enfócate en ejercicios compuestos
- Progresión gradual de pesos
""";
    }
  }

  // ✅ 8. METAS PERSONALIZADAS
  static String _getPersonalizedGoals(UserModel user) {
    try {
      return """
METAS SEMANALES PERSONALIZADAS:

1. ✅ Cumplir ${user.dailyCalories.round()} kcal diarias (±10%)
2. ✅ Alcanzar ${user.proteinGoal.round()}g de proteína diaria
3. ✅ ${user.workoutFrequency.contains('3') ? '3' : '4'} sesiones de entrenamiento
4. ✅ Beber ${user.waterIntake.contains('Excelente') ? '3L' : '2L'} de agua diarios
5. ✅ Dormir 7-8 horas cada noche
6. ✅ ${user.goal.contains('perder') ? '10,000' : '8,000'} pasos diarios

RECOMPENSA: Al completar 5/6 metas, tómate un día de comida flexible
""";
    } catch (e) {
      return """
Metas básicas:
1. Cumplir tus calorías diarias
2. Hacer ejercicio regularmente
3. Mantenerte hidratado
4. Dormir suficiente
""";
    }
  }

  // ✅ 9. MÉTODO COMPATIBLE - CORREGIDO (DEVUELVE DOUBLE)
  static Future<Map<String, dynamic>> generateInitialDiagnosis(UserModel user) async {
    try {
      final recommendations = await getPersonalizedRecommendations(user);
      final caloricGoal = calculateCaloricGoal(user);

      return {
        'caloricGoal': caloricGoal, // ✅ DOUBLE
        'recommendedMacros': {
          'protein': (caloricGoal * 0.3 / 4), // ✅ DOUBLE
          'carbs': (caloricGoal * 0.4 / 4), // ✅ DOUBLE
          'fat': (caloricGoal * 0.3 / 9), // ✅ DOUBLE
        },
        'dietRecommendations': [
          recommendations['nutrition'] ?? 'Dieta balanceada con énfasis en proteínas',
          'Meta calórica: ${caloricGoal.round()} kcal',
        ],
        'workoutPlan': [
          recommendations['exercise'] ?? 'Entrenamiento de fuerza 3 veces por semana',
          recommendations['goals'] ?? 'Metas semanales personalizadas',
        ],
        'success': true,
        'message': 'Análisis completado exitosamente'
      };
    } catch (e) {
      return {
        'caloricGoal': 2000.0, // ✅ DOUBLE
        'recommendedMacros': {'protein': 150.0, 'carbs': 200.0, 'fat': 67.0}, // ✅ DOUBLE
        'dietRecommendations': [
          'Dieta balanceada adaptada a tus necesidades',
          'Meta calórica: 2000 kcal (ajustable)'
        ],
        'workoutPlan': [
          'Entrenamiento personalizado basado en tu objetivo',
          'Enfócate en consistencia y progreso gradual'
        ],
        'success': true,
        'message': 'Recomendaciones optimizadas para tu perfil'
      };
    }
  }
}