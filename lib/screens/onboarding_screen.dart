import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/ai_recommendation_service.dart';
import '../services/hive_service.dart';
import '../services/backend_service.dart'; // 🆕 IMPORTAR BACKEND SERVICE

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _previewRecommendations;

  // Controladores
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Selectores
  String _selectedGender = '';
  String _selectedBodyType = '';
  String _selectedLifestyle = '';
  String _selectedGoal = '';
  String _selectedWorkoutFreq = '';
  String _selectedWorkoutExp = '';
  String _selectedFoodBudget = '';
  String _selectedCountry = '';
  String _selectedDietType = '';
  String _selectedActivityJob = '';
  String _selectedStressLevel = '';
  String _selectedSleepQuality = '';
  String _selectedWaterIntake = '';
  String _selectedMealsPerDay = '';
  
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);

  // Listas de opciones
  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _bodyTypes = ['Ectomorfo', 'Mesomorfo', 'Endomorfo'];
  final List<String> _lifestyles = [
    'Sedentario', 
    'Ligera actividad', 
    'Moderadamente activo', 
    'Muy activo', 
    'Extremadamente activo'
  ];
  final List<String> _goals = [
    'Perder grasa',
    'Ganar masa muscular', 
    'Mantener peso',
    'Mejorar rendimiento deportivo',
    'Mejorar salud general'
  ];
  final List<String> _workoutFrequencies = [
    '1-2 veces por semana',
    '3 veces por semana', 
    '4-5 veces por semana',
    '6+ veces por semana'
  ];
  final List<String> _workoutExperiences = [
    'Principiante (0-6 meses)',
    'Intermedio (6 meses-2 años)', 
    'Avanzado (2+ años)',
    'Experto (5+ años)'
  ];
  
  final List<String> _foodBudgets = ['Baja', 'Media', 'Alta'];
  
  final List<String> _dietTypes = [
    'Omnívoro', 'Vegetariano', 'Vegano', 'Pescetariano', 
    'Keto', 'Paleo', 'Low-carb', 'Flexitariano', 'Sin restricciones'
  ];
  final List<String> _activityJobs = [
    'Trabajo sentado (oficina)', 
    'Trabajo de pie', 
    'Trabajo físico ligero', 
    'Trabajo físico intenso', 
    'Deportista profesional'
  ];
  final List<String> _stressLevels = [
    'Muy bajo', 'Bajo', 'Moderado', 'Alto', 'Muy alto'
  ];
  final List<String> _sleepQualities = [
    'Muy pobre (menos de 5h)', 
    'Pobre (5-6h)', 
    'Regular (6-7h)', 
    'Buena (7-8h)', 
    'Excelente (8h+)'
  ];
  final List<String> _waterIntakes = [
    'Muy poco (menos de 1L)', 
    'Poco (1-1.5L)', 
    'Moderado (1.5-2L)', 
    'Bueno (2-3L)', 
    'Excelente (3L+)'
  ];
  final List<String> _mealsPerDay = ['3 comidas', '4 comidas', '5 comidas', '6+ comidas'];
  
  final List<String> _countries = [
    'Argentina', 'Bolivia', 'Brasil', 'Chile', 'Colombia', 'Costa Rica', 'Cuba', 
    'Ecuador', 'El Salvador', 'España', 'Estados Unidos', 'Guatemala', 'Honduras', 
    'México', 'Nicaragua', 'Panamá', 'Paraguay', 'Perú', 'Puerto Rico', 
    'República Dominicana', 'Uruguay', 'Venezuela', 'Canadá', 'Reino Unido',
    'Francia', 'Italia', 'Alemania', 'Australia', 'China', 'Japón', 'India'
  ];

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // ✅ CONSTANTES DE COLOR
  static const Color betterMePrimaryColor = Color(0xFF7B1FA2);
  static const Color betterMeBackgroundColor = Colors.white;
  static const Color betterMeHintColor = Color.fromARGB(255, 146, 68, 219);
  static const Color betterMeFillColor = Color(0xFFE0E0E0);
  static const Color betterMeTextColor = Colors.black87;
  static const Color betterMeCardColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool _validateCurrentPage() {
    if (!_formKeys[_currentPageIndex].currentState!.validate()) {
      return false;
    }
    
    switch (_currentPageIndex) {
      case 0:
        if (_firstNameController.text.isEmpty || 
            _lastNameController.text.isEmpty || 
            _usernameController.text.isEmpty) {
          _showError('Por favor completa todos los campos requeridos');
          return false;
        }
        break;
      case 1:
        if (_selectedGender.isEmpty || _selectedBodyType.isEmpty ||
            _ageController.text.isEmpty || _weightController.text.isEmpty ||
            _heightController.text.isEmpty) {
          _showError('Por favor completa todos los campos requeridos');
          return false;
        }
        break;
      case 2:
        if (_selectedLifestyle.isEmpty || _selectedActivityJob.isEmpty || 
            _selectedStressLevel.isEmpty || _selectedSleepQuality.isEmpty ||
            _selectedWaterIntake.isEmpty) {
          _showError('Por favor completa todos los campos requeridos');
          return false;
        }
        break;
      case 3:
        if (_selectedGoal.isEmpty || _selectedWorkoutFreq.isEmpty || 
            _selectedWorkoutExp.isEmpty || _selectedDietType.isEmpty ||
            _selectedFoodBudget.isEmpty || _selectedMealsPerDay.isEmpty ||
            _selectedCountry.isEmpty) {
          _showError('Por favor completa todos los campos requeridos');
          return false;
        }
        break;
    }
    
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _nextPage() {
    if (!_validateCurrentPage()) return;
    
    if (_currentPageIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      
      if (_currentPageIndex == 2) {
        _calculatePreview();
      }
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _calculatePreview() async {
    if (_ageController.text.isEmpty || 
        _weightController.text.isEmpty || 
        _heightController.text.isEmpty) {
      return;
    }

    try {
      final tempUser = UserModel(
        userId: 'temp',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        age: double.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _selectedGender,
        lifestyle: _selectedLifestyle,
        goal: _selectedGoal,
        workoutFrequency: _selectedWorkoutFreq,
        workoutExperience: _selectedWorkoutExp,
        foodBudget: _selectedFoodBudget,
        country: _selectedCountry,
        wakeUpTime: _wakeUpTime.format(context),
        sleepTime: _sleepTime.format(context),
        bodyType: _selectedBodyType,
        mealsPerDay: _selectedMealsPerDay,
        dietType: _selectedDietType,
        activityJob: _selectedActivityJob,
        stressLevel: _selectedStressLevel,
        sleepQuality: _selectedSleepQuality,
        waterIntake: _selectedWaterIntake,
        foodHabits: '',
        dietRestrictions: '',
        cookingTime: '',
        language: 'Español',
      );

      final recommendations = await AIRecommendationService.generateInitialDiagnosis(tempUser);
      
      setState(() {
        _previewRecommendations = recommendations;
      });
    } catch (e) {
      debugPrint('Error calculando preview: $e');
    }
  }

  Future<void> _saveUserData() async {
    if (!_validateCurrentPage()) {
      _showError('Por favor completa todos los campos requeridos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final age = double.tryParse(_ageController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final height = double.tryParse(_heightController.text) ?? 0.0;

      if (age <= 0 || weight <= 0 || height <= 0) {
        throw Exception('Datos físicos inválidos');
      }

      final newUser = UserModel(
        userId: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        age: age,
        weight: weight,
        height: height,
        gender: _selectedGender,
        lifestyle: _selectedLifestyle,
        goal: _selectedGoal,
        workoutFrequency: _selectedWorkoutFreq,
        workoutExperience: _selectedWorkoutExp,
        foodBudget: _selectedFoodBudget,
        country: _selectedCountry,
        wakeUpTime: _wakeUpTime.format(context),
        sleepTime: _sleepTime.format(context),
        bodyType: _selectedBodyType,
        mealsPerDay: _selectedMealsPerDay,
        dietType: _selectedDietType,
        activityJob: _selectedActivityJob,
        stressLevel: _selectedStressLevel,
        sleepQuality: _selectedSleepQuality,
        waterIntake: _selectedWaterIntake,
        foodHabits: '',
        dietRestrictions: '',
        cookingTime: '',
        language: 'Español',
      );

      final diagnosis = await AIRecommendationService.generateInitialDiagnosis(newUser);
      
      final userWithGoals = newUser.copyWith(
        dailyCalories: diagnosis['caloricGoal'] ?? 2000,
        proteinGoal: diagnosis['recommendedMacros']['protein'] ?? 150,
        carbsGoal: diagnosis['recommendedMacros']['carbs'] ?? 200,
        fatGoal: diagnosis['recommendedMacros']['fat'] ?? 67,
      );

      await HiveService.saveUser(userWithGoals);
      await HiveService.settingsBox.put('onboardingCompleted', true);

      // 🆕 SINCRONIZAR CON FIRESTORE DESPUÉS DE GUARDAR
      final hasConnection = await BackendService.hasConnection();
      if (hasConnection) {
        await BackendService.syncCurrentUser();
        debugPrint('✅ Usuario sincronizado con Firestore después del onboarding');
      }

      if (!mounted) return;
      
      Navigator.pushReplacementNamed(context, '/ia_analysis');

    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al guardar: ${e.toString()}');
    }
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: (_currentPageIndex + 1) / 4,
      backgroundColor: Colors.grey[300],
      color: betterMePrimaryColor,
      minHeight: 4,
    );
  }

  Widget _buildActionButton(String text, Function() onPressed) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: betterMePrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              )
            : Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: betterMeBackgroundColor,
      appBar: AppBar(
        backgroundColor: betterMeBackgroundColor,
        elevation: 0,
        leading: _currentPageIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: betterMePrimaryColor),
                onPressed: _previousPage,
              )
            : null,
        title: Text(
          'Paso ${_currentPageIndex + 1} de 4',
          style: TextStyle(color: betterMePrimaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoPage(),
                _buildPhysicalDataPage(),
                _buildLifestylePage(),
                _buildGoalsPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPageIndex > 0)
                  _buildActionButton('Anterior', _previousPage)
                else
                  const SizedBox(width: 120),
                
                if (_currentPageIndex < 3)
                  _buildActionButton('Siguiente', _nextPage)
                else
                  _buildActionButton('Comenzar', _saveUserData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === PÁGINAS DEL ONBOARDING (4 PÁGINAS) ===

  Widget _buildPersonalInfoPage() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola! 👋\nEmpecemos con lo básico',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Esta información nos ayudará a crear un plan perfecto para ti',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            _buildTextFieldWithValidation(
              controller: _firstNameController,
              label: 'Nombre *',
              validator: (value) => value!.isEmpty ? 'Por favor ingresa tu nombre' : null,
            ),
            const SizedBox(height: 20),
            
            _buildTextFieldWithValidation(
              controller: _lastNameController,
              label: 'Apellido *',
              validator: (value) => value!.isEmpty ? 'Por favor ingresa tu apellido' : null,
            ),
            const SizedBox(height: 20),
            
            _buildTextFieldWithValidation(
              controller: _usernameController,
              label: 'Nombre de usuario *',
              validator: (value) => value!.isEmpty ? 'Por favor crea un nombre de usuario' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalDataPage() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos físicos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Conoce tu cuerpo para mejores resultados',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            _buildTextFieldWithValidation(
              controller: _ageController,
              label: 'Edad *',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Ingresa tu edad';
                final age = int.tryParse(value);
                if (age == null || age < 13 || age > 100) return 'Edad válida entre 13-100';
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildTextFieldWithValidation(
              controller: _weightController,
              label: 'Peso actual (kg) *',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Ingresa tu peso';
                final weight = double.tryParse(value);
                if (weight == null || weight < 30 || weight > 300) return 'Peso entre 30-300 kg';
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildTextFieldWithValidation(
              controller: _heightController,
              label: 'Altura (cm) *',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Ingresa tu altura';
                final height = double.tryParse(value);
                if (height == null || height < 100 || height > 250) return 'Altura entre 100-250 cm';
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Género *',
              _selectedGender,
              _genders,
              (value) => setState(() => _selectedGender = value!),
              validator: (value) => value == null ? 'Selecciona tu género' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Tipo de cuerpo *',
              _selectedBodyType,
              _bodyTypes,
              (value) => setState(() => _selectedBodyType = value!),
              validator: (value) => value == null ? 'Selecciona tu tipo de cuerpo' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestylePage() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estilo de vida',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cómo vives afecta cómo te alimentas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            _buildDropdownWithValidation(
              'Nivel de actividad general *',
              _selectedLifestyle,
              _lifestyles,
              (value) => setState(() => _selectedLifestyle = value!),
              validator: (value) => value == null ? 'Selecciona tu nivel de actividad' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Tipo de trabajo/actividad *',
              _selectedActivityJob,
              _activityJobs,
              (value) => setState(() => _selectedActivityJob = value!),
              validator: (value) => value == null ? 'Selecciona tu tipo de trabajo' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Nivel de estrés *',
              _selectedStressLevel,
              _stressLevels,
              (value) => setState(() => _selectedStressLevel = value!),
              validator: (value) => value == null ? 'Selecciona tu nivel de estrés' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Calidad de sueño *',
              _selectedSleepQuality,
              _sleepQualities,
              (value) => setState(() => _selectedSleepQuality = value!),
              validator: (value) => value == null ? 'Selecciona calidad de sueño' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Consumo de agua diario *',
              _selectedWaterIntake,
              _waterIntakes,
              (value) => setState(() => _selectedWaterIntake = value!),
              validator: (value) => value == null ? 'Selecciona consumo de agua' : null,
            ),
          ],
        )
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Form(
      key: _formKeys[3],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metas y preferencias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '¿Qué quieres lograr y cómo?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            _buildDropdownWithValidation(
              'Tu objetivo principal *',
              _selectedGoal,
              _goals,
              (value) => setState(() => _selectedGoal = value!),
              validator: (value) => value == null ? 'Selecciona tu objetivo' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Frecuencia de ejercicio *',
              _selectedWorkoutFreq,
              _workoutFrequencies,
              (value) => setState(() => _selectedWorkoutFreq = value!),
              validator: (value) => value == null ? 'Selecciona frecuencia' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Experiencia en ejercicio *',
              _selectedWorkoutExp,
              _workoutExperiences,
              (value) => setState(() => _selectedWorkoutExp = value!),
              validator: (value) => value == null ? 'Selecciona experiencia' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Tipo de dieta *',
              _selectedDietType,
              _dietTypes,
              (value) => setState(() => _selectedDietType = value!),
              validator: (value) => value == null ? 'Selecciona tipo de dieta' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Presupuesto para comida *',
              _selectedFoodBudget,
              _foodBudgets,
              (value) => setState(() => _selectedFoodBudget = value!),
              validator: (value) => value == null ? 'Selecciona presupuesto' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'Comidas por día *',
              _selectedMealsPerDay,
              _mealsPerDay,
              (value) => setState(() => _selectedMealsPerDay = value!),
              validator: (value) => value == null ? 'Selecciona comidas por día' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownWithValidation(
              'País de residencia *',
              _selectedCountry,
              _countries,
              (value) => setState(() => _selectedCountry = value!),
              validator: (value) => value == null ? 'Selecciona tu país' : null,
            ),
            
            // PREVIEW DE RECOMENDACIONES
            if (_previewRecommendations != null) ...[
              const SizedBox(height: 30),
              const Text(
                '📊 Vista previa de tu plan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                color: betterMeCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔥 ${_previewRecommendations!['caloricGoal'].round()} kcal/día',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🍗 Proteína: ${_previewRecommendations!['recommendedMacros']['protein']}g/día',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '🍚 Carbohidratos: ${_previewRecommendations!['recommendedMacros']['carbs']}g/día',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '🥑 Grasas: ${_previewRecommendations!['recommendedMacros']['fat']}g/día',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ); 
  }

  // === WIDGETS AUXILIARES ===

  Widget _buildTextFieldWithValidation({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: betterMeHintColor),
        filled: true,
        fillColor: betterMeFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(color: betterMeTextColor),
    );
  }

  Widget _buildDropdownWithValidation(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    {required String? Function(String?)? validator}
  ) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: betterMeHintColor),
        filled: true,
        fillColor: betterMeFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: betterMeTextColor),
    );
  }
}