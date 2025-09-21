import '../models/workout_session_model.dart';
import 'hive_service.dart';

class WorkoutService {
  
  static Future<void> initialize() async {
    final sessionsBox = HiveService.appDataBox;
    if (!sessionsBox.containsKey('workout_sessions')) {
      await sessionsBox.put('workout_sessions', <Map<String, dynamic>>[]);
    }
  }
  
  static Future<void> logWorkoutSession(WorkoutSession session) async {
    final sessionsBox = HiveService.appDataBox;
    final sessions = sessionsBox.get('workout_sessions', defaultValue: <Map<String, dynamic>>[]);
    
    sessions.add(session.toMap());
    await sessionsBox.put('workout_sessions', sessions);
  }

  static List<WorkoutSession> getWorkoutHistory() {
    final sessionsBox = HiveService.appDataBox;
    final sessions = sessionsBox.get('workout_sessions', defaultValue: <Map<String, dynamic>>[]);
    
    return sessions.map((sessionMap) => WorkoutSession.fromMap(sessionMap)).toList();
  }

  // 🎯 CAMBIADO: GET THIS MONTH SESSIONS
  static List<WorkoutSession> getThisMonthSessions() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    
    return getWorkoutHistory().where((session) => 
        session.date.isAfter(firstDay.subtract(const Duration(days: 1))) && 
        session.date.isBefore(lastDay.add(const Duration(days: 1)))
    ).toList();
  }

  // 🎯 CAMBIADO: GET MONTHLY STATS
  static Map<String, dynamic> getMonthlyStats() {
    final monthSessions = getThisMonthSessions();
    final completed = monthSessions.where((s) => s.completed).length;
    final goal = 12; // ✅ Meta mensual: 12 entrenamientos
    
    return {
      'completed': completed,
      'goal': goal,
      'percentage': (completed / goal * 100).round(),
      'sessions': monthSessions,
      'remaining': goal - completed,
    };
  }

  // 🎯 NUEVO: GET LAST MONTH COMPARISON
  static Map<String, dynamic> getLastMonthComparison() {
    final now = DateTime.now();
    final lastMonth = now.month - 1 == 0 ? 12 : now.month - 1;
    final lastMonthYear = now.month - 1 == 0 ? now.year - 1 : now.year;
    
    final lastMonthSessions = getWorkoutHistory().where((session) => 
        session.date.month == lastMonth && session.date.year == lastMonthYear
    ).toList();
    
    final currentMonthSessions = getThisMonthSessions();
    
    return {
      'last_month_count': lastMonthSessions.length,
      'current_month_count': currentMonthSessions.length,
      'improvement': currentMonthSessions.length - lastMonthSessions.length,
      'improvement_percentage': lastMonthSessions.length > 0 ? 
          ((currentMonthSessions.length - lastMonthSessions.length) / lastMonthSessions.length * 100).round() : 0,
    };
  }

  // 🎯 EJERCICIOS PREDEFINIDOS (IGUAL)
  static List<Map<String, dynamic>> getPredefinedWorkouts() {
    return [
      {
        'name': 'Pecho y Espalda',
        'exercises': [
          {'name': 'Press Banca', 'sets': 3, 'reps': 10, 'weight': 0},
          {'name': 'Dominadas', 'sets': 3, 'reps': 8, 'weight': 0},
          {'name': 'Remo con Barra', 'sets': 3, 'reps': 12, 'weight': 0},
        ]
      },
      {
        'name': 'Piernas y Hombros', 
        'exercises': [
          {'name': 'Sentadillas', 'sets': 4, 'reps': 10, 'weight': 0},
          {'name': 'Prensa', 'sets': 3, 'reps': 12, 'weight': 0},
          {'name': 'Press Militar', 'sets': 3, 'reps': 10, 'weight': 0},
        ]
      },
      {
        'name': 'Brazos y Abdomen',
        'exercises': [
          {'name': 'Curl de Bíceps', 'sets': 3, 'reps': 12, 'weight': 0},
          {'name': 'Extensión de Tríceps', 'sets': 3, 'reps': 12, 'weight': 0},
          {'name': 'Plancha', 'sets': 3, 'reps': 60, 'weight': 0},
        ]
      }
    ];
  }
}