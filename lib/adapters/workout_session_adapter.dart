// lib/adapters/workout_session_adapter.dart
import 'package:hive/hive.dart';
import '../models/workout_session_model.dart';

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 4;

  @override
  WorkoutSession read(BinaryReader reader) {
    final map = reader.readMap();
    // ✅ Convertir Map<dynamic, dynamic> a Map<String, dynamic>
    final stringMap = Map<String, dynamic>.from(map);
    return WorkoutSession.fromMap(stringMap);
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer.writeMap(obj.toMap());
  }
}