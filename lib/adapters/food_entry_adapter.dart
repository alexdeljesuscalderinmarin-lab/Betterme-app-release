import 'package:hive/hive.dart';
import '../models/food_entry_model.dart';
import 'package:flutter/material.dart';

class FoodEntryAdapter extends TypeAdapter<FoodEntry> {
  @override
  final int typeId = 1;

  @override
  FoodEntry read(BinaryReader reader) {
    return FoodEntry(
      id: reader.readString(),
      foodName: reader.readString(),
      mealType: reader.readString(),
      context: reader.readString(),
      date: DateTime.parse(reader.readString()),
      time: TimeOfDay(
        hour: reader.readInt(),
        minute: reader.readInt(),
      ),
      calories: reader.readDouble(),
      protein: reader.readDouble(),
      carbs: reader.readDouble(),
      fat: reader.readDouble(),
      imagePath: reader.readString(),
      grams: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodEntry obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.foodName);
    writer.writeString(obj.mealType);
    writer.writeString(obj.context);
    writer.writeString(obj.date.toIso8601String());
    writer.writeInt(obj.time.hour);
    writer.writeInt(obj.time.minute);
    writer.writeDouble(obj.calories);
    writer.writeDouble(obj.protein);
    writer.writeDouble(obj.carbs);
    writer.writeDouble(obj.fat);
    writer.writeString(obj.imagePath ?? '');
    writer.writeDouble(obj.grams);
  }
}