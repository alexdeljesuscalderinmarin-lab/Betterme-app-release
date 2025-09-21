// lib/services/food_ai_service.dart - CON SISTEMA DE CACHE COMPLETO
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/hive_service.dart';

class FoodAIService {
  static final String? _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  static final String? _nutritionixAppId = dotenv.env['NUTRITIONIX_APP_ID'];
  static final String? _nutritionixApiKey = dotenv.env['NUTRITIONIX_API_KEY'];
  static final String? _openFoodFactsEnabled = dotenv.env['OPEN_FOOD_FACTS_ENABLED'];

  // 🆕 SISTEMA DE CACHE INTELIGENTE
  static final Map<String, Map<String, dynamic>> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50;
  static const Duration _cacheDuration = Duration(hours: 24);

  // 📊 SISTEMA DE USOS CON PERSISTENCIA EN HIVE
  static Map<String, dynamic> get _usageStats {
    return HiveService.settingsBox.get('foodAI_usage', defaultValue: {
      'used': 0,
      'limit': 5,
      'remaining': 5,
      'canUse': true,
      'lastReset': DateTime.now().toIso8601String(),
    });
  }

  static set _usageStats(Map<String, dynamic> stats) {
    HiveService.settingsBox.put('foodAI_usage', stats);
  }

  // 🆕 INICIALIZAR CACHE
  static void initializeCache() {
    _loadCacheFromHive();
    _cleanOldCacheEntries();
  }

  // 🆕 CARGAR CACHE DESDE HIVE
  static void _loadCacheFromHive() {
    try {
      final cachedData = HiveService.settingsBox.get('foodAI_cache', defaultValue: {});
      if (cachedData is Map) {
        _memoryCache.clear();
        cachedData.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final cachedTime = DateTime.parse(value['_cachedTimestamp'] ?? DateTime.now().toIso8601String());
            if (DateTime.now().difference(cachedTime) < _cacheDuration) {
              _memoryCache[key] = value;
            }
          }
        });
      }
    } catch (e) {
      print('⚠️ Error cargando cache: $e');
    }
  }

  // 🆕 GUARDAR CACHE EN HIVE
  static void _saveCacheToHive() {
    try {
      HiveService.settingsBox.put('foodAI_cache', _memoryCache);
    } catch (e) {
      print('⚠️ Error guardando cache: $e');
    }
  }

  // 🆕 LIMPIAR CACHE EXPIRADO
  static void _cleanOldCacheEntries() {
    final now = DateTime.now();
    _memoryCache.removeWhere((key, value) {
      final cachedTime = DateTime.parse(value['_cachedTimestamp'] ?? now.toIso8601String());
      return now.difference(cachedTime) > _cacheDuration;
    });
    _saveCacheToHive();
  }

  // 🆕 GENERAR CLAVE ÚNICA PARA CACHE
  static String _generateCacheKey(File imageFile, String description) {
    final imageHash = imageFile.lengthSync().toString();
    final descHash = description.toLowerCase().trim();
    return '${descHash}_$imageHash';
  }

  // 🆕 VERIFICAR CACHE
  static Map<String, dynamic>? _checkCache(File imageFile, String description) {
    final cacheKey = _generateCacheKey(imageFile, description);
    final cachedData = _memoryCache[cacheKey];
    
    if (cachedData != null) {
      final cachedTime = DateTime.parse(cachedData['_cachedTimestamp'] ?? DateTime.now().toIso8601String());
      if (DateTime.now().difference(cachedTime) < _cacheDuration) {
        final result = Map<String, dynamic>.from(cachedData);
        result.remove('_cachedTimestamp');
        return result;
      } else {
        _memoryCache.remove(cacheKey);
      }
    }
    return null;
  }

  // 🆕 GUARDAR EN CACHE
  static void _saveToCache(File imageFile, String description, Map<String, dynamic> data) {
    final cacheKey = _generateCacheKey(imageFile, description);
    
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    
    final dataWithTimestamp = Map<String, dynamic>.from(data);
    dataWithTimestamp['_cachedTimestamp'] = DateTime.now().toIso8601String();
    
    _memoryCache[cacheKey] = dataWithTimestamp;
    _saveCacheToHive();
  }

  // 🔄 VERIFICAR Y RESETEAR USOS DIARIOS
  static void _checkAndResetUsage() {
    final currentStats = _usageStats;
    final now = DateTime.now();
    final lastReset = DateTime.parse(currentStats['lastReset']);
    
    if (now.difference(lastReset).inHours >= 24) {
      _usageStats = {
        'used': 0,
        'limit': currentStats['limit'],
        'remaining': currentStats['limit'],
        'canUse': true,
        'lastReset': now.toIso8601String(),
      };
    }
  }

  // ✅ VERIFICAR SI PUEDE USAR ANÁLISIS
  static bool canUseAIAnalysis() {
    _checkAndResetUsage();
    return _usageStats['canUse'] && _usageStats['remaining'] > 0;
  }

  // 📈 OBTENER ESTADÍSTICAS DE USO
  static Map<String, dynamic> getUsageStats() {
    _checkAndResetUsage();
    return {..._usageStats};
  }

  // ➕ INCREMENTAR USO
  static void incrementUsage() {
    _checkAndResetUsage();
    final stats = _usageStats;
    stats['used']++;
    stats['remaining']--;
    stats['canUse'] = stats['remaining'] > 0;
    _usageStats = stats;
  }

  // 🎯 AÑADIR ANÁLISIS EXTRA
  static void addExtraScans(int extraScans) {
    _checkAndResetUsage();
    final stats = _usageStats;
    stats['remaining'] += extraScans;
    stats['canUse'] = true;
    _usageStats = stats;
  }

  // 🖼️ LLAMAR A GEMINI VISION API
  static Future<String> _callGeminiVisionAPI(File imageFile, String prompt) async {
    if (_geminiApiKey == null) {
      throw Exception('❌ GEMINI_API_KEY no configurada');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.2,
        "topK": 40,
        'topP': 0.95,
        "maxOutputTokens": 1024,
      }
    };

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        throw Exception('❌ Error Gemini API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❌ Error conexión Gemini: $e');
    }
  }

  // 📊 OBTENER DATOS NUTRICIONALES CON SISTEMA HÍBRIDO
  static Future<Map<String, dynamic>> _getHybridNutritionData(String foodName, {File? image}) async {
    try {
      if (_nutritionixAppId != null && _nutritionixApiKey != null) {
        final nutritionixData = await _getNutritionWithNutritionix(foodName);
        if (nutritionixData.isNotEmpty && (nutritionixData['calories'] as double) > 0) {
          return nutritionixData;
        }
      }
    } catch (e) {
      print('⚠️ Nutritionix falló: $e');
    }

    try {
      if (_openFoodFactsEnabled == 'true') {
        final offData = await _getOpenFoodFactsData(foodName);
        if (offData.isNotEmpty && (offData['calories'] as double) > 0) {
          return offData;
        }
      }
    } catch (e) {
      print('⚠️ Open Food Facts falló: $e');
    }

    if (image != null) {
      try {
        final geminiAnalysis = await _getDetailedAnalysisWithGemini(image, foodName);
        if (geminiAnalysis.isNotEmpty) {
          return geminiAnalysis;
        }
      } catch (e) {
        print('⚠️ Análisis detallado con Gemini falló: $e');
      }
    }

    return _getEnhancedEstimation(foodName);
  }

  // 📊 NUTRITIONIX
  static Future<Map<String, dynamic>> _getNutritionWithNutritionix(String foodDescription) async {
    final response = await http.post(
      Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients'),
      headers: {
        'Content-Type': 'application/json',
        'x-app-id': _nutritionixAppId!,
        'x-app-key': _nutritionixApiKey!,
      },
      body: json.encode({
        "query": foodDescription,
        "timezone": "US/Eastern"
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['foods'] != null && data['foods'].isNotEmpty) {
        final firstFood = data['foods'][0];
        return {
          'foodName': firstFood['food_name'] ?? foodDescription,
          'calories': (firstFood['nf_calories'] ?? 0.0).toDouble(),
          'protein': (firstFood['nf_protein'] ?? 0.0).toDouble(),
          'carbs': (firstFood['nf_total_carbohydrate'] ?? 0.0).toDouble(),
          'fat': (firstFood['nf_total_fat'] ?? 0.0).toDouble(),
          'serving_size_grams': (firstFood['serving_weight_grams'] ?? 100.0).toDouble(),
          'source': 'nutritionix',
          'confidence': 0.9,
        };
      }
    }
    return {};
  }

  // 🌍 OPEN FOOD FACTS
  static Future<Map<String, dynamic>> _getOpenFoodFactsData(String foodName) async {
    try {
      final formattedName = foodName.toLowerCase().replaceAll(' ', '%20');
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v2/search?fields=product_name,nutriments,quantity&json=1&search_terms=$formattedName')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          final product = data['products'][0];
          final nutriments = product['nutriments'] ?? {};
          
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
            'serving_size_grams': safeToDouble(product['quantity']?.toString().replaceAll('g', '')),
            'source': 'open_food_facts',
            'confidence': 0.7,
          };
        }
      }
    } catch (e) {
      print('Error Open Food Facts: $e');
    }
    return {};
  }

  // 🧠 ANÁLISIS DETALLADO CON GEMINI
  static Future<Map<String, dynamic>> _getDetailedAnalysisWithGemini(File imageFile, String foodDescription) async {
    try {
      final prompt = """
Analiza esta imagen de comida y estima:
1. Nombre del alimento en español
2. Calorías aproximadas por 100g
3. Proteínas en gramos por 100g  
4. Carbohidratos en gramos por 100g
5. Grasas en gramos por 100g

Devuelve SOLO un JSON con esta estructura:
{
  "foodName": "nombre",
  "calories": número,
  "protein": número,
  "carbs": número,
  "fat": número,
  "serving_size_grams": 100,
  "source": "gemini_estimation"
}

Descripción del usuario: "$foodDescription"
""";

      final response = await _callGeminiVisionAPI(imageFile, prompt);
      
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(0)!);
        return {
          ...jsonData,
          'confidence': 0.6,
          'ai_generated': true,
        };
      }
    } catch (e) {
      print('Error análisis detallado Gemini: $e');
    }
    return {};
  }

  // 🎯 MÉTODO PRINCIPAL CON CACHE
  static Future<Map<String, dynamic>> analyzeFoodWithCache(File imageFile, String userDescription) async {
    final cachedResult = _checkCache(imageFile, userDescription);
    if (cachedResult != null) {
      return cachedResult;
    }

    if (!canUseAIAnalysis()) {
      final stats = getUsageStats();
      throw Exception(
        '📊 Límite diario alcanzado\n'
        'Has usado ${stats['used']} de ${stats['limit']} análisis hoy.\n\n'
        '💡 Vuelve mañana o actualiza a Premium para análisis ilimitados.'
      );
    }

    try {
      final String prompt = "Identifica esta comida y devuélveme SOLO el nombre en español:";
      final geminiResponse = await _callGeminiVisionAPI(imageFile, prompt);
      
      String foodName = userDescription.isNotEmpty ? userDescription : geminiResponse;

      final nutritionData = await _getHybridNutritionData(foodName, image: imageFile);
      
      incrementUsage();

      final result = {
        ...nutritionData,
        'description': foodName,
        'ai_generated': true,
        'timestamp': DateTime.now().toIso8601String(),
        'from_cache': false,
      };

      _saveToCache(imageFile, userDescription, result);

      return result;

    } catch (e) {
      incrementUsage();
      
      final fallbackResult = _getEnhancedEstimation(userDescription.isNotEmpty ? userDescription : 'Comida');
      _saveToCache(imageFile, userDescription, {
        ...fallbackResult,
        'from_cache': false,
        'is_fallback': true,
      });
      
      return fallbackResult;
    }
  }

  // 📝 ESTIMACIÓN MEJORADA COMO FALLBACK
  static Map<String, dynamic> _getEnhancedEstimation(String description) {
    final descLower = description.toLowerCase();
    
    final Map<String, Map<String, double>> foodDatabase = {
      'empanada': {'calories': 280.0, 'protein': 8.0, 'carbs': 35.0, 'fat': 12.0},
      'pizza': {'calories': 800.0, 'protein': 25.0, 'carbs': 80.0, 'fat': 35.0},
      'ensalada': {'calories': 150.0, 'protein': 5.0, 'carbs': 20.0, 'fat': 5.0},
      'pollo': {'calories': 300.0, 'protein': 40.0, 'carbs': 0.0, 'fat': 15.0},
      'pescado': {'calories': 280.0, 'protein': 35.0, 'carbs': 0.0, 'fat': 12.0},
      'arroz': {'calories': 400.0, 'protein': 10.0, 'carbs': 80.0, 'fat': 5.0},
      'pasta': {'calories': 380.0, 'protein': 12.0, 'carbs': 75.0, 'fat': 4.0},
      'hamburguesa': {'calories': 750.0, 'protein': 30.0, 'carbs': 45.0, 'fat': 40.0},
      'sándwich': {'calories': 350.0, 'protein': 15.0, 'carbs': 40.0, 'fat': 12.0},
      'sopa': {'calories': 120.0, 'protein': 8.0, 'carbs': 15.0, 'fat': 3.0},
    };

    for (var key in foodDatabase.keys) {
      if (descLower.contains(key)) {
        final data = foodDatabase[key]!;
        return {
          'foodName': description,
          'calories': data['calories']!,
          'protein': data['protein']!,
          'carbs': data['carbs']!,
          'fat': data['fat']!,
          'serving_size_grams': 100.0,
          'source': 'database_estimation',
          'confidence': 0.8,
          'note': 'Estimación basada en base de datos local',
          'ai_generated': false,
        };
      }
    }

    return {
      'foodName': description,
      'calories': 250.0,
      'protein': 15.0,
      'carbs': 30.0,
      'fat': 8.0,
      'serving_size_grams': 100.0,
      'source': 'generic_estimation',
      'confidence': 0.5,
      'note': 'Estimación genérica - Verifica manualmente para mayor precisión',
      'ai_generated': false,
    };
  }

  // 🎯 MÉTODO ANALYZEFOOD (COMPATIBILIDAD)
  static Future<Map<String, dynamic>> analyzeFood(File imageFile, String userDescription) async {
    return await analyzeFoodWithCache(imageFile, userDescription);
  }

  // 🎯 MÉTODO ANALYZEFOODIMAGE (COMPATIBILIDAD)
  static Future<Map<String, dynamic>?> analyzeFoodImage(File imageFile) async {
    try {
      return await analyzeFoodWithCache(imageFile, '');
    } catch (e) {
      final result = _getEnhancedEstimation('Comida analizada');
      _saveToCache(imageFile, '', {
        ...result,
        'from_cache': false,
        'is_fallback': true,
      });
      return result;
    }
  }

  // 🆕 LIMPIAR CACHE COMPLETO
  static void clearCache() {
    _memoryCache.clear();
    HiveService.settingsBox.delete('foodAI_cache');
  }

  // 🆕 ESTADÍSTICAS DEL CACHE
  static Map<String, dynamic> getCacheStats() {
    return {
      'total_items': _memoryCache.length,
      'memory_size': _memoryCache.toString().length,
      'max_size': _maxMemoryCacheSize,
      'cache_duration_hours': _cacheDuration.inHours,
    };
  }

  // 🔄 RESTABLECER USOS
  static void resetUsage() {
    _usageStats = {
      'used': 0,
      'limit': 5,
      'remaining': 5,
      'canUse': true,
      'lastReset': DateTime.now().toIso8601String(),
    };
  }

  // 🎯 AÑADIR USOS EXTRA
  static void addExtraUses(int extraUses) {
    addExtraScans(extraUses);
  }

  // 📊 ESTABLECER LÍMITE DIARIO
  static void setDailyLimit(int newLimit) {
    _checkAndResetUsage();
    final stats = _usageStats;
    stats['limit'] = newLimit;
    stats['remaining'] = newLimit - stats['used'];
    stats['canUse'] = stats['remaining'] > 0;
    _usageStats = stats;
  }

  // 🎯 MÉTODO PARA PREMIUM - LÍMITES ILIMITADOS
  static void enableUnlimitedScans() {
    _usageStats = {
      'used': 0,
      'limit': 9999,
      'remaining': 9999,
      'canUse': true,
      'lastReset': DateTime.now().toIso8601String(),
      'unlimited': true,
    };
  }
}