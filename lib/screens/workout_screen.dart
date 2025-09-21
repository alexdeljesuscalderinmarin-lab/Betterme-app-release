import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import '../services/fitness_ai_service.dart';
import '../models/workout_session_model.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<Map<String, dynamic>> _predefinedWorkouts = WorkoutService.getPredefinedWorkouts();
  Map<String, dynamic>? _selectedWorkout;
  final List<ExerciseSet> _todayExercises = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTodaysWorkout();
  }

  void _loadTodaysWorkout() {
    // Para v1.0: workout fijo por día de la semana
    final dayOfWeek = DateTime.now().weekday;
    final workoutTypes = ['Pecho y Espalda', 'Piernas y Hombros', 'Brazos y Abdomen'];
    
    setState(() {
      _selectedWorkout = _predefinedWorkouts[dayOfWeek % workoutTypes.length];
      _todayExercises.clear();
      
      if (_selectedWorkout != null) {
        for (var exercise in _selectedWorkout!['exercises']) {
          _todayExercises.add(ExerciseSet(
            exerciseName: exercise['name'],
            sets: exercise['sets'],
            reps: exercise['reps'],
            weight: exercise['weight'],
          ));
        }
      }
    });
  }

  void _updateExercise(int index, ExerciseSet updatedExercise) {
    setState(() {
      _todayExercises[index] = updatedExercise;
    });
  }

  // ✅ MÉTODO MEJORADO CON ANÁLISIS DE IA MENSUAL
  Future<void> _saveWorkout() async {
    setState(() => _isSaving = true);

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      workoutType: _selectedWorkout?['name'] ?? 'Entrenamiento',
      exercises: _todayExercises,
      completed: true,
      notes: 'Completado el ${DateTime.now().toString()}',
    );

    try {
      await WorkoutService.logWorkoutSession(session);
      
      // ✅ ANÁLISIS DE IA MENSUAL (¡CAMBIADO!)
      final analysis = FitnessAIService.analyzeMonthlyProgress();
      _showProgressUpdate(analysis);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ✅ MOSTRAR ACTUALIZACIÓN DE PROGRESO CON IA MENSUAL
  void _showProgressUpdate(Map<String, dynamic> analysis) {
    if (analysis['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 Progreso Mensual: ${analysis['progress_score']?.round()}%'),
              if (analysis['has_plateau'] == true)
                Text('⚠️ Estancamiento en ${analysis['plateau_exercises']?.length} ejercicios'),
            ],
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Ver Detalles',
            onPressed: () => _showDetailedAnalysis(analysis),
          ),
        ),
      );
    }
  }

  // ✅ PANTALLA DE ANÁLISIS DETALLADO MENSUAL
  void _showDetailedAnalysis(Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📈 Análisis de Progreso Mensual'), // ✅ Cambiado
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puntuación General: ${analysis['progress_score']?.round()}%'),
              const SizedBox(height: 12),
              
              if (analysis['monthly_summary'] != null) ...[ // ✅ Cambiado
                Text('Entrenamientos este mes: ${analysis['monthly_summary']?['workouts_completed']}'),
                Text('Ejercicios totales: ${analysis['monthly_summary']?['total_exercises']}'),
                Text('Intensidad promedio: ${(analysis['monthly_summary']?['avg_intensity'] ?? 0).toStringAsFixed(2)}'),
                const SizedBox(height: 16),
              ],
              
              if (analysis['has_plateau'] == true) ...[
                const Text('⚠️ Ejercicios estancados (1+ mes):', // ✅ Cambiado
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ...(analysis['plateau_exercises'] as List<dynamic>).map((exercise) => 
                  Text('• $exercise')
                ).toList(),
                const SizedBox(height: 12),
              ],
              
              const Text('💡 Recomendaciones Mensuales:', // ✅ Cambiado
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ...(analysis['recommendations'] as List<dynamic>).map((rec) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $rec'),
                )
              ).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index, ExerciseSet exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.fitness_center, color: Colors.blue),
        title: Text(exercise.exerciseName),
        subtitle: Text('${exercise.sets} sets × ${exercise.reps} reps × ${exercise.weight}kg'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditExerciseDialog(index, exercise),
        ),
      ),
    );
  }

  void _showEditExerciseDialog(int index, ExerciseSet exercise) {
    final setsController = TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps.toString());
    final weightController = TextEditingController(text: exercise.weight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${exercise.exerciseName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final updatedExercise = ExerciseSet(
                exerciseName: exercise.exerciseName,
                sets: int.parse(setsController.text),
                reps: int.parse(repsController.text),
                weight: double.parse(weightController.text),
              );
              _updateExercise(index, updatedExercise);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💪 Mi Entrenamiento Diario'),
        actions: [
          // ✅ BOTÓN DE ANÁLISIS MENSUAL (¡CAMBIADO!)
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              final analysis = FitnessAIService.analyzeMonthlyProgress(); // ✅ Cambiado
              _showDetailedAnalysis(analysis);
            },
          ),
        ],
      ),
      body: _selectedWorkout == null
          ? _buildEmptyState()
          : _buildWorkoutTracker(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No hay entrenamiento programado para hoy'),
    );
  }

  Widget _buildWorkoutTracker() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedWorkout?['name'] ?? 'Entrenamiento',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ejercicios de hoy:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: _todayExercises.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(index, _todayExercises[index]);
              },
            ),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveWorkout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green[200],
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('💾 GUARDAR ENTRENAMIENTO', 
                      style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}