// lib/services/nutrition_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NutritionApiService {
  static const String nutritionixAppId = "TU_APP_ID";
  static const String nutritionixAppKey = "TU_APP_KEY";
  static const String openFoodFactsUrl = "https://world.openfoodfacts.org/api/v0/product/";

  // Método híbrido que intenta múltiples fuentes
  static Future<Map<String, dynamic>> getNutritionData(String foodName, {File? image}) async {
    // 1. Primero intentar con Nutritionix (más preciso)
    try {
      final nutritionixData = await _getNutritionixData(foodName);
      if (nutritionixData.isNotEmpty) return nutritionixData;
    } catch (e) {
      print("Nutritionix falló: $e");
    }

    // 2. Si falla, intentar con Open Food Facts (gratuita)
    try {
      final offData = await _getOpenFoodFactsData(foodName);
      if (offData.isNotEmpty) return offData;
    } catch (e) {
      print("Open Food Facts falló: $e");
    }

    // 3. Como último recurso, usar datos estimados
    return _getEstimatedNutrition(foodName);
  }

  static Future<Map<String, dynamic>> _getNutritionixData(String foodName) async {
    final response = await http.post(
      Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients'),
      headers: {
        'Content-Type': 'application/json',
        'x-app-id': nutritionixAppId,
        'x-app-key': nutritionixAppKey,
      },
      body: json.encode({'query': foodName}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final food = data['foods'][0];
      return {
        'foodName': food['food_name'],
        'calories': (food['nf_calories'] ?? 0.0).toDouble(),
        'protein': (food['nf_protein'] ?? 0.0).toDouble(),
        'carbs': (food['nf_total_carbohydrate'] ?? 0.0).toDouble(),
        'fat': (food['nf_total_fat'] ?? 0.0).toDouble(),
        'source': 'Nutritionix'
      };
    }
    return {};
  }

  static Future<Map<String, dynamic>> _getOpenFoodFactsData(String foodName) async {
    // Lógica para Open Food Facts (gratuita)
    final formattedName = foodName.toLowerCase().replaceAll(' ', '%20');
    final response = await http.get(Uri.parse('$openFoodFactsUrl$formattedName.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        final product = data['product'];
        final nutriments = product['nutriments'];
        
        // ✅ Función segura para conversión a double
        double safeToDouble(dynamic value) {
          if (value == null) return 0.0;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }

        return {
          'foodName': product['product_name'] ?? foodName,
          'calories': safeToDouble(nutriments['energy-kcal_100g']),
          'protein': safeToDouble(nutriments['proteins_100g']),
          'carbs': safeToDouble(nutriments['carbohydrates_100g']),
          'fat': safeToDouble(nutriments['fat_100g']),
          'source': 'OpenFoodFacts'
        };
      }
    }
    return {};
  }

  static Map<String, dynamic> _getEstimatedNutrition(String foodName) {
    // Base de datos local de alimentos comunes
    final Map<String, Map<String, double>> foodDatabase = {
      'empanada': {'calories': 250.0, 'protein': 6.0, 'carbs': 30.0, 'fat': 12.0},
      'manzana': {'calories': 52.0, 'protein': 0.3, 'carbs': 14.0, 'fat': 0.2},
      'pollo': {'calories': 165.0, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6},
      // Añadir más alimentos comunes...
    };

    final lowerName = foodName.toLowerCase();
    for (var key in foodDatabase.keys) {
      if (lowerName.contains(key)) {
        final data = foodDatabase[key]!;
        return {
          'foodName': foodName,
          'calories': data['calories']!,
          'protein': data['protein']!,
          'carbs': data['carbs']!,
          'fat': data['fat']!,
          'source': 'Estimation'
        };
      }
    }

    // Estimación genérica por si no encuentra coincidencia
    return {
      'foodName': foodName,
      'calories': 200.0,
      'protein': 10.0,
      'carbs': 20.0,
      'fat': 8.0,
      'source': 'GenericEstimation'
    };
  }
}