class WorkoutSession {
  final String id;
  final DateTime date;
  final String workoutType;
  final List<ExerciseSet> exercises;
  final bool completed;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.workoutType,
    required this.exercises,
    this.completed = true,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutType': workoutType,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'completed': completed,
      'notes': notes,
    };
  }

  static WorkoutSession fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: DateTime.parse(map['date']),
      workoutType: map['workoutType'],
      exercises: List<ExerciseSet>.from(map['exercises'].map((x) => ExerciseSet.fromMap(x))),
      completed: map['completed'] ?? true,
      notes: map['notes'],
    );
  }
}

class ExerciseSet {
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final String? notes;

  ExerciseSet({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
    };
  }

  static ExerciseSet fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      exerciseName: map['exerciseName'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight']?.toDouble() ?? 0.0,
      notes: map['notes'],
    );
  }
}