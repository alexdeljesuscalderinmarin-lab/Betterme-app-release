// ADD_FOOD_SCREEN - PANTALLA PARA AÑADIR COMIDAS CON ANÁLISIS DE IA MEJORADO
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_entry_model.dart';
import '../services/food_ai_service.dart';
import '../services/hive_service.dart';
import '../main.dart' as app_main;

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _mealType = 'Desayuno';
  String _foodDescription = '';
  bool _isLoading = false;
  Map<String, dynamic> _nutritionData = {};
  String _aiSource = '';
  double _confidence = 0.0;
  
  final List<String> _mealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snack'];
  final TextEditingController _foodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkDailyLimit();
  }

  void _checkDailyLimit() {
    final stats = FoodAIService.getUsageStats();
    if (stats['remaining'] <= 0) {
      _showLimitReachedDialog();
    }
  }

  Future<void> _pickImage() async {
    final stats = FoodAIService.getUsageStats();
    
    if (stats['remaining'] <= 0) {
      _showLimitReachedDialog();
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _nutritionData = {};
        _aiSource = '';
        _confidence = 0.0;
      });
    }
  }

  // ✅ NUEVO: MOSTRAR OPCIONES CUANDO SE ACABAN LOS ANÁLISIS
  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Límite Alcanzado 📊'),
        content: const Text(
          'Has usado todos tus análisis gratuitos de hoy.\n\n'
          '💡 Los análisis se reinician cada día a la medianoche.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeFood() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📸 Por favor, toma una foto primero')),
      );
      return;
    }

    final stats = FoodAIService.getUsageStats();
    if (stats['remaining'] <= 0) {
      _showLimitReachedDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final analysisResult = await FoodAIService.analyzeFood(_image!, _foodDescription);
      
      if (analysisResult != null) {
        setState(() {
          _foodDescription = analysisResult['foodName'] ?? 'Comida no identificada';
          _foodController.text = _foodDescription;
          _nutritionData = {
            'calories': analysisResult['calories']?.toDouble() ?? 0.0,
            'protein': analysisResult['protein']?.toDouble() ?? 0.0,
            'carbs': analysisResult['carbs']?.toDouble() ?? 0.0,
            'fat': analysisResult['fat']?.toDouble() ?? 0.0,
            'serving_size': analysisResult['serving_size_grams']?.toDouble() ?? 100.0,
          };
          _aiSource = analysisResult['source'] ?? 'unknown';
          _confidence = analysisResult['confidence']?.toDouble() ?? 0.0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Análisis completado (${_getSourceName(_aiSource)})'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al analizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getSourceName(String source) {
    switch (source) {
      case 'nutritionix': return 'Nutritionix';
      case 'open_food_facts': return 'Open Food Facts';
      case 'gemini_estimation': return 'Gemini AI';
      case 'database_estimation': return 'Base de datos';
      case 'generic_estimation': return 'Estimación';
      default: return 'IA';
    }
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'nutritionix': return Colors.blue;
      case 'open_food_facts': return Colors.green;
      case 'gemini_estimation': return Colors.purple;
      case 'database_estimation': return Colors.orange;
      case 'generic_estimation': return Colors.grey;
      default: return app_main.betterMePrimaryColor;
    }
  }

  void _saveFoodEntry() {
    if (_foodDescription.isEmpty || _nutritionData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Analiza la comida primero')),
      );
      return;
    }
    
    final newEntry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: _foodDescription,
      mealType: _mealType,
      context: '',
      date: DateTime.now(),
      time: TimeOfDay.now(),
      calories: _nutritionData['calories'] ?? 0.0,
      protein: _nutritionData['protein'] ?? 0.0,
      carbs: _nutritionData['carbs'] ?? 0.0,
      fat: _nutritionData['fat'] ?? 0.0,
      imagePath: _image?.path,
    );
    
    final currentEntries = HiveService.appDataBox.get('foodEntries', defaultValue: <FoodEntry>[]).cast<FoodEntry>();
    currentEntries.add(newEntry);

    HiveService.appDataBox.put('foodEntries', currentEntries);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Comida guardada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildNutritionProgressBar(String label, double value, double goal, Color color) {
    final percentage = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${value.round()}g', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 2),
        Text(
          '${(percentage * 100).round()}% de objetivo',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSourceBadge() {
    if (_aiSource.isEmpty) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getSourceColor(_aiSource).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getSourceColor(_aiSource).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: _getSourceColor(_aiSource)),
          const SizedBox(width: 6),
          Text(
            _getSourceName(_aiSource),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getSourceColor(_aiSource),
            ),
          ),
          if (_confidence > 0) ...[
            const SizedBox(width: 6),
            Text(
              '${(_confidence * 100).round()}% confianza',
              style: TextStyle(
                fontSize: 10,
                color: _getSourceColor(_aiSource).withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = FoodAIService.getUsageStats();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Comida', style: TextStyle(color: Colors.white)),
        backgroundColor: app_main.betterMePrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Análisis de Comida 📊'),
                  content: Text(
                    'Análisis usados hoy: ${stats['used']}/${stats['limit']}\n'
                    'Restantes: ${stats['remaining']}\n\n'
                    '💡 El sistema utiliza múltiples fuentes:\n'
                    '• Nutritionix (precisión alta)\n'
                    '• Open Food Facts (gratuita)\n'
                    '• Gemini AI (análisis visual)\n'
                    '• Base de datos local\n\n'
                    '🕒 Los análisis se reinician cada día a la medianoche',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ CONTADOR DE USOS MEJORADO
            Card(
              color: stats['remaining'] > 0 ? Colors.blue[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      stats['remaining'] > 0 ? Icons.auto_awesome : Icons.warning,
                      color: stats['remaining'] > 0 ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stats['remaining'] > 0 
                          ? '${stats['remaining']} análisis restantes hoy' 
                          : 'Límite diario alcanzado',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: stats['remaining'] > 0 ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ZONA DE IMAGEN
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _image == null ? Colors.grey[300]! : Colors.green,
                    width: _image == null ? 1 : 2,
                  ),
                ),
                child: _image == null ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text('Toca para tomar foto', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 5),
                    Text('📸', style: TextStyle(fontSize: 20)),
                  ],
                ) : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SELECTOR DE TIPO DE COMIDA
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: InputDecoration(
                labelText: '🍽️ Tipo de comida',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.restaurant),
              ),
              items: _mealTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _mealType = newValue);
                }
              },
            ),
            const SizedBox(height: 16),

            // CAMPO DE DESCRIPCIÓN
            TextFormField(
              controller: _foodController,
              decoration: InputDecoration(
                labelText: '📝 Nombre de la comida',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description),
                hintText: 'Ej: Empanada de carne, Ensalada mediterránea...',
              ),
              onChanged: (value) => _foodDescription = value,
            ),
            const SizedBox(height: 20),

            // BOTÓN DE ANÁLISIS MEJORADO
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: stats['remaining'] > 0 
                  ? app_main.betterMePrimaryColor 
                  : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(stats['remaining'] > 0 ? Icons.auto_awesome : Icons.lock),
                        const SizedBox(width: 10),
                        Text(stats['remaining'] > 0 ? 'Analizar con IA' : 'Límite alcanzado'),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // INFORMACIÓN NUTRICIONAL
            if (_nutritionData.isNotEmpty) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '📊 Información Nutricional',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          _buildSourceBadge(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildNutritionProgressBar(
                        'Proteína', 
                        _nutritionData['protein'] ?? 0.0, 
                        30.0, 
                        Colors.blue
                      ),
                      _buildNutritionProgressBar(
                        'Carbohidratos', 
                        _nutritionData['carbs'] ?? 0.0, 
                        50.0, 
                        Colors.green
                      ),
                      _buildNutritionProgressBar(
                        'Grasas', 
                        _nutritionData['fat'] ?? 0.0, 
                        20.0, 
                        Colors.orange
                      ),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: app_main.betterMePrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              '${_nutritionData['calories']?.round() ?? 0} CALORÍAS',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_nutritionData['serving_size'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Porción: ${_nutritionData['serving_size']?.round()}g',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // BOTÓN GUARDAR
            ElevatedButton(
              onPressed: _nutritionData.isNotEmpty ? _saveFoodEntry : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _nutritionData.isNotEmpty ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 10),
                  Text('Guardar Comida'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}