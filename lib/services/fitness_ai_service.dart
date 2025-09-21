import '../models/workout_session_model.dart';
import '../services/hive_service.dart';

class FitnessAIService {
  
  // 🎯 1. ANÁLISIS DE PROGRESO MENSUAL (¡CAMBIADO!)
  static Map<String, dynamic> analyzeMonthlyProgress() {
    try {
      final sessions = _getLastMonthSessions(); // ✅ Cambiado a mensual
      if (sessions.isEmpty) {
        return {
          'success': false,
          'message': 'No hay suficientes datos para analizar',
          'recommendations': ['Completa al menos 5 entrenamientos este mes']
        };
      }

      final progress = _calculateProgressMetrics(sessions);
      final plateau = _checkForPlateaus(sessions);
      final recommendations = _generateRecommendations(progress, plateau);

      return {
        'success': true,
        'progress_score': progress['overall_score'],
        'has_plateau': plateau['has_plateau'],
        'plateau_exercises': plateau['plateaued_exercises'],
        'recommendations': recommendations,
        'monthly_summary': { // ✅ Cambiado a monthly
          'workouts_completed': sessions.length,
          'total_exercises': _countTotalExercises(sessions),
          'avg_intensity': progress['avg_intensity'],
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error en análisis: $e',
        'recommendations': ['Continúa entrenando y revisa tu progreso el próximo mes']
      };
    }
  }

  // 🎯 2. DETECCIÓN DE ESTANCAMIENTO (PLATEAU) - AJUSTADO A MENSUAL
  static Map<String, dynamic> _checkForPlateaus(List<WorkoutSession> sessions) {
    final plateaus = <String>[];
    final exerciseProgress = <String, List<double>>{};

    // Agrupar progreso por ejercicio
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        exerciseProgress.putIfAbsent(
          exercise.exerciseName, 
          () => []
        ).add(exercise.weight);
      }
    }

    // Verificar estancamiento (4 semanas sin mejora) - ✅ Ajustado
    exerciseProgress.forEach((exercise, weights) {
      if (weights.length >= 4) { // ✅ 4 semanas en lugar de 3
        final lastFour = weights.sublist(weights.length - 4);
        final isPlateau = _checkPlateauCondition(lastFour);
        if (isPlateau) {
          plateaus.add(exercise);
        }
      }
    });

    return {
      'has_plateau': plateaus.isNotEmpty,
      'plateaued_exercises': plateaus,
      'total_plateaus': plateaus.length
    };
  }

  // 🎯 3. GENERAR RECOMENDACIONES INTELIGENTES (AJUSTADAS)
  static List<String> _generateRecommendations(
      Map<String, dynamic> progress, Map<String, dynamic> plateau) {
    
    final recommendations = <String>[];

    // Recomendaciones basadas en plateau
    if (plateau['has_plateau']) {
      for (final exercise in plateau['plateaued_exercises']) {
        recommendations.add(
          '💡 Para $exercise: después de 1 mes sin progreso, intenta cambiar completamente el ejercicio o aumentar 5kg'
        );
      }
    }

    // Recomendaciones basadas en intensidad
    final intensity = progress['avg_intensity'] ?? 0.0;
    if (intensity < 0.6) {
      recommendations.add('⚡ Intensidad baja mensual: considera cambiar tu rutina o aumentar frecuencia');
    } else if (intensity > 0.85) {
      recommendations.add('🛑 Intensidad muy alta: podrías estar sobreentrenando, considera descansar 1 semana');
    }

    // Recomendación general basada en consistencia mensual
    final consistency = progress['consistency_score'] ?? 0.0;
    if (consistency < 0.5) {
      recommendations.add('📅 Poca consistencia mensual: ideal entrenar 12+ veces al mes');
    } else if (consistency > 0.8) {
      recommendations.add('🔥 Excelente consistencia mensual: ¡sigue así!');
    }

    return recommendations..add('💪 Revisa tu progreso cada mes para ajustar tu plan');
  }

  // 🎯 4. OBTENER SESIONES DEL MES (¡NUEVO MÉTODO!)
  static List<WorkoutSession> _getLastMonthSessions() {
    try {
      final now = DateTime.now();
      final oneMonthAgo = now.subtract(const Duration(days: 30)); // ✅ 30 días
      
      final allSessions = HiveService.appDataBox.get(
        'workout_sessions', 
        defaultValue: <Map<String, dynamic>>[]
      ).cast<Map<String, dynamic>>();

      return allSessions
          .map((sessionMap) => WorkoutSession.fromMap(sessionMap))
          .where((session) => session.date.isAfter(oneMonthAgo))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 🎯 5. CÁLCULO DE MÉTRICAS DE PROGRESO (IGUAL)
  static Map<String, dynamic> _calculateProgressMetrics(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return {};

    double totalIntensity = 0.0;
    int totalExercises = 0;
    final exerciseProgress = <String, List<double>>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        totalIntensity += (exercise.weight / exercise.reps) * exercise.sets;
        totalExercises++;
        
        exerciseProgress.putIfAbsent(
          exercise.exerciseName, 
          () => []
        ).add(exercise.weight);
      }
    }

    final avgIntensity = totalExercises > 0 ? totalIntensity / totalExercises : 0.0;
    final consistencyScore = sessions.length / 12.0; // ✅ 12 sesiones mensuales ideales

    return {
      'avg_intensity': avgIntensity,
      'consistency_score': consistencyScore.clamp(0.0, 1.0),
      'overall_score': (avgIntensity * consistencyScore * 100).clamp(0.0, 100.0),
      'exercise_progress': exerciseProgress,
    };
  }

  // 🎯 6. VERIFICAR CONDICIÓN DE PLATEAU (AJUSTADO)
  static bool _checkPlateauCondition(List<double> weights) {
    if (weights.length < 4) return false; // ✅ 4 semanas
    
    final lastFour = weights.sublist(weights.length - 4);
    final avg = lastFour.reduce((a, b) => a + b) / lastFour.length;
    final variation = lastFour.map((w) => (w - avg).abs()).reduce((a, b) => a + b) / lastFour.length;
    
    // Plateau si variación < 3% del promedio (más estricto para mensual)
    return variation < (avg * 0.03);
  }

  // 🎯 7. CONTAR EJERCICIOS TOTALES (IGUAL)
  static int _countTotalExercises(List<WorkoutSession> sessions) {
    return sessions.fold(0, (total, session) => total + session.exercises.length);
  }

  // 🎯 8. PREDICCIÓN DE METAS MENSUALES (AJUSTADO)
  static Map<String, dynamic> predictMonthlyGoals(String exerciseName, double currentWeight) {
    const monthlyProgression = 0.15; // ✅ 15% de progreso mensual
    
    return {
      'next_month': currentWeight * (1 + monthlyProgression),
      'in_two_months': currentWeight * (1 + monthlyProgression * 2),
      'in_three_months': currentWeight * (1 + monthlyProgression * 3),
      'confidence': 0.8,
      'recommendation': 'Aumenta 5kg cada mes si logras todas las repeticiones consistentemente'
    };
  }

  // 🎯 9. MÉTODO SEMANAL ELIMINADO (¡IMPORTANTE!)
  // ❌ analyzeWeeklyProgress() - COMPLETAMENTE ELIMINADO
}