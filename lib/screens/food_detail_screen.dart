
import 'package:flutter/material.dart';
import '../models/food_entry_model.dart';
import '../main.dart';
import 'dart:io';

class FoodDetailScreen extends StatelessWidget {
  final FoodEntry foodEntry;

  const FoodDetailScreen({super.key, required this.foodEntry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Comida', style: TextStyle(color: Colors.white)),
        backgroundColor: betterMePrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN (si existe)
            if (foodEntry.imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(foodEntry.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // INFORMACIÓN PRINCIPAL
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(foodEntry.foodName, 
                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('🍽️ ${foodEntry.mealType} • ⏰ ${foodEntry.formattedTime}'),
                    if (foodEntry.context.isNotEmpty)
                      Text('📝 ${foodEntry.context}'),
                    Text('📅 ${foodEntry.formattedDate}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // INFORMACIÓN NUTRICIONAL
            const Text('📊 Información Nutricional', 
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              children: [
                _buildNutritionCard('Calorías', '${foodEntry.calories.toStringAsFixed(0)} kcal', Colors.purple),
                _buildNutritionCard('Proteína', '${foodEntry.protein.toStringAsFixed(1)}g', Colors.blue),
                _buildNutritionCard('Carbs', '${foodEntry.carbs.toStringAsFixed(1)}g', Colors.green),
                _buildNutritionCard('Grasas', '${foodEntry.fat.toStringAsFixed(1)}g', Colors.orange),
              ],
            ),

            const SizedBox(height: 20),

            // BOTONES DE ACCIÓN
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: betterMePrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    // ✅ FUTURO: Editar comida
                  },
                  icon: const Icon(Icons.edit, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: color)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}