import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_entry_model.dart';
import '../main.dart'; // Para betterMeCardColor y otros colores
import '../screens/food_detail_screen.dart'; // Importamos la nueva pantalla de detalles

class RecentEntries extends StatelessWidget {
  const RecentEntries({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos ValueListenableBuilder para escuchar los cambios en la box de Hive
    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodEntry>('foodEntries').listenable(),
      builder: (context, Box<FoodEntry> foodBox, _) {
        final entries = foodBox.values.toList().reversed.toList();
        
        if (entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay entradas de comida registradas hoy.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Itera sobre las entradas reales de la base de datos
                ...entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(foodEntry: entry),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: betterMeCardColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: entry.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(entry.imagePath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                          title: Text(entry.foodName),
                          subtitle: Text('${entry.calories.toStringAsFixed(0)} kcal'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
