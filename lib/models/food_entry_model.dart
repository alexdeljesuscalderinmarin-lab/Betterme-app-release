import 'package:flutter/material.dart';

class FoodEntry {
  final String id;
  final String foodName;
  final String mealType;
  final String context;
  final DateTime date;
  final TimeOfDay time;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imagePath;
  final double grams;

  FoodEntry({
    required this.id,
    required this.foodName,
    required this.mealType,
    required this.context,
    required this.date,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imagePath,
    this.grams = 100.0,
  });

  // ✅ GETTER PARA COMPATIBILIDAD (timestamp → date)
  DateTime get timestamp => date;

  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}