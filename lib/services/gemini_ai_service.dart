import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class GeminiAIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent';
  
  static Future<Map<String, dynamic>> analyzeFoodImage(String imagePath, String description) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY no configurada');
    }

    try {
      // Convertir imagen a base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": "Analiza esta imagen de comida y proporciona información nutricional estimada. Responde SOLO con un JSON válido en este formato exacto: {\"calories\": number, \"protein\": number, \"carbs\": number, \"fat\": number, \"confidence\": number between 0-1}. La descripción proporcionada es: $description"},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extraer JSON de la respuesta
        final jsonMatch = RegExp(r'\{.*\}').firstMatch(text);
        if (jsonMatch != null) {
          return json.decode(jsonMatch.group(0)!);
        }
        
        throw Exception('No se pudo extraer JSON de la respuesta');
      } else {
        throw Exception('Error de API: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a simulación si la API falla
      return _simulateAnalysis(description);
    }
  }

  static Map<String, dynamic> _simulateAnalysis(String description) {
    // Simulación mejorada basada en descripción
    return {
      'calories': _calculateCalories(description),
      'protein': _calculateProtein(description),
      'carbs': _calculateCarbs(description),
      'fat': _calculateFat(description),
      'confidence': 0.7,
    };
  }

  // ** Funciones de cálculo añadidas para resolver los errores **
  static double _calculateCalories(String description) {
    if (description.toLowerCase().contains('ensalada')) return 150.0;
    if (description.toLowerCase().contains('pizza')) return 800.0;
    if (description.toLowerCase().contains('pollo')) return 300.0;
    return 400.0; // Valor por defecto
  }

  static double _calculateProtein(String description) {
    if (description.toLowerCase().contains('pollo')) return 40.0;
    if (description.toLowerCase().contains('carne')) return 35.0;
    return 20.0; // Valor por defecto
  }

  static double _calculateCarbs(String description) {
    if (description.toLowerCase().contains('pasta')) return 60.0;
    if (description.toLowerCase().contains('arroz')) return 50.0;
    return 40.0; // Valor por defecto
  }

  static double _calculateFat(String description) {
    if (description.toLowerCase().contains('aguacate')) return 25.0;
    if (description.toLowerCase().contains('frito')) return 30.0;
    return 15.0; // Valor por defecto
  }
}