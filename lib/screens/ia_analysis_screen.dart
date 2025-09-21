import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/ai_recommendation_service.dart';
import '../services/hive_service.dart';

class IAAnalysisScreen extends StatefulWidget {
  const IAAnalysisScreen({super.key});

  @override
  IAAnalysisScreenState createState() => IAAnalysisScreenState();
}

class IAAnalysisScreenState extends State<IAAnalysisScreen> 
    with SingleTickerProviderStateMixin {
  
  final List<String> _loadingMessages = [
    "Analizando tu perfil único...",
    "Calculando tu metabolismo basal...",
    "Evaluando tu estilo de vida...",
    "Optimizando tus macros...",
    "Personalizando recomendaciones...",
    "Creando tu plan nutricional...",
    "Preparando tu transformación...",
    "¡Casi listo! Ultimos ajustes..."
  ];

  String _currentMessage = "Analizando tu perfil único...";
  bool _showButton = false;
  bool _analysisComplete = false;
  late Timer _messageTimer;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  int _currentMessageIndex = 0;
  Map<String, dynamic>? _diagnosis;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack)
    );

    // Iniciar animación de mensajes
    _startMessageAnimation();
    
    // Iniciar análisis real
    _startRealAnalysis();
  }

  void _startMessageAnimation() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 2200), (timer) {
      if (_currentMessageIndex < _loadingMessages.length - 1) {
        setState(() {
          _currentMessageIndex++;
          _currentMessage = _loadingMessages[_currentMessageIndex];
        });
      } else {
        timer.cancel();
      }
    });
  }

  // Método de conversión segura para evitar errores de tipo
  double _safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Future<void> _startRealAnalysis() async {
    try {
      // ✅ CARGAR DESDE HIVE
      _currentUser = HiveService.getCurrentUser();

      if (_currentUser != null) {
        // Pequeña espera para la experiencia de usuario
        await Future.delayed(const Duration(seconds: 2));

        // LLAMADA REAL A LA API DE IA
        _diagnosis = await AIRecommendationService.generateInitialDiagnosis(_currentUser!);

        // ✅ CORRECCIÓN: Convertir todos los valores a double
        final updatedUser = _currentUser!.copyWith(
          dailyCalories: _safeDouble(_diagnosis!['caloricGoal'], 2500),
          proteinGoal: _safeDouble(_diagnosis!['recommendedMacros']?['protein'], 150),
          carbsGoal: _safeDouble(_diagnosis!['recommendedMacros']?['carbs'], 250),
          fatGoal: _safeDouble(_diagnosis!['recommendedMacros']?['fat'], 70),
          aiExplanation: _diagnosis!['explanation'] ?? '',
        );

        // Calcular usos diarios basado en comidas al día
        _calculateDailyUsage(updatedUser);

        // Guardar el usuario actualizado EN HIVE
        await HiveService.saveUser(updatedUser);
        
        // Detener timer de mensajes y mostrar resultado
        if (_messageTimer.isActive) {
          _messageTimer.cancel();
        }

        setState(() {
          _currentUser = updatedUser;
          _analysisComplete = true;
          _currentMessage = "¡Análisis completado!";
        });

        // Pequeña pausa antes de mostrar el botón
        await Future.delayed(const Duration(milliseconds: 800));
        
        setState(() {
          _showButton = true;
        });

        // Iniciar animación de entrada
        _animationController.forward();

      } else {
        _handleError("No se pudo encontrar tu perfil. Por favor, reinicia la aplicación.");
      }
    } catch (e) {
      _handleError("Ocurrió un error al generar las recomendaciones. Usaremos valores predeterminados.");
      
      // Valores predeterminados en caso de error
      if (_currentUser != null) {
        final recommendations = _currentUser!.calculateRecommendations();
        final updatedUser = _currentUser!.copyWith(
          dailyCalories: _safeDouble(recommendations['dailyCalories'], 2000),
          proteinGoal: _safeDouble(recommendations['proteinGoal'], 150),
          carbsGoal: _safeDouble(recommendations['carbsGoal'], 200),
          fatGoal: _safeDouble(recommendations['fatGoal'], 67),
          aiExplanation: recommendations['aiExplanation'],
        );
        
        _calculateDailyUsage(updatedUser);
        await HiveService.saveUser(updatedUser);
      }
    }
  }

  // CALCULAR USOS DIARIOS BASADO EN COMIDAS
  void _calculateDailyUsage(UserModel user) {
    final mealsPerDay = user.mealsPerDay;
    
    int dailyUsage;
    
    // Convertir respuesta de comidas a número
    if (mealsPerDay.contains('1-2')) {
      dailyUsage = 3; // 2 comidas + 1 snack
    } else if (mealsPerDay.contains('3')) {
      dailyUsage = 4; // 3 comidas + 1 snack
    } else if (mealsPerDay.contains('4')) {
      dailyUsage = 5; // 4 comidas + 1 snack
    } else if (mealsPerDay.contains('5')) {
      dailyUsage = 6; // 5 comidas + 1 snack
    } else {
      dailyUsage = 7; // 6+ comidas (fracionado)
    }
    
    HiveService.settingsBox.put('dailyUsage', dailyUsage);
    HiveService.settingsBox.put('remainingUsage', dailyUsage);
  }

  void _handleError(String message) {
    if (_messageTimer.isActive) {
      _messageTimer.cancel();
    }
    
    setState(() {
      _analysisComplete = true;
      _currentMessage = message;
      _showButton = true;
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToRecommendations() {
    Navigator.pushReplacementNamed(context, '/recommendations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono animado
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _analysisComplete ? 1.0 : 0.8 + 0.2 * sin(_animationController.value * 2 * pi),
                  child: Icon(
                    _analysisComplete ? Icons.auto_awesome : Icons.psychology,
                    size: 60,
                    color: const Color(0xFF7B1FA2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Mensaje principal
            Text(
              _currentMessage,
              style: TextStyle(
                fontSize: 18,
                color: _analysisComplete ? const Color(0xFF7B1FA2) : Colors.black87,
                fontWeight: _analysisComplete ? FontWeight.bold : FontWeight.normal,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Indicador de progreso o resultados
            if (!_analysisComplete)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
                strokeWidth: 2,
              ),
            
            if (_analysisComplete && _currentUser != null)
              FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Resumen de objetivos
                        Text(
                          "Tu plan personalizado",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7B1FA2),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Calorías principales
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B1FA2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "🔥 ${_currentUser!.dailyCalories.round()}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B1FA2),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Calorías diarias",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Macros en círculos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroCircle("Proteínas", _currentUser!.proteinGoal, "g", const Color(0xFFE91E63)),
                            _buildMacroCircle("Carbs", _currentUser!.carbsGoal, "g", const Color(0xFF9C27B0)),
                            _buildMacroCircle("Grasas", _currentUser!.fatGoal, "g", const Color(0xFF673AB7)),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Explicación de IA
                        if (_currentUser!.aiExplanation.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              _currentUser!.aiExplanation,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Botón de acción principal
            if (_showButton)
              FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B1FA2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _navigateToRecommendations,
                        child: const Text(
                          'Ver mis recomendaciones completas',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCircle(String label, double value, String unit, Color color) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.round().toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}