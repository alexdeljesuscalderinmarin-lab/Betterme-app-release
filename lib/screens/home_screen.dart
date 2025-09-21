// HOME_SCREEN - Pantalla principal que muestra el progreso diario, acceso rápido a funciones y notificaciones.
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/food_entry_model.dart';
import '../services/hive_service.dart';
import '../services/workout_service.dart';
import '../services/notification_service.dart';
import '../services/backend_service.dart';
import '../main.dart' as app_main;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  UserModel? _user;
  double _caloriesConsumed = 0.0;
  double _proteinConsumed = 0.0;
  double _carbsConsumed = 0.0;
  double _fatConsumed = 0.0;
  bool _isLoading = true;
  int _completedWorkoutsThisMonth = 0;
  bool _notificationsEnabled = false;

  final NotificationService _notificationService = NotificationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }).catchError((error) {
        if (mounted) setState(() => _isLoading = false);
      });
    });
    
    _checkNotificationPermissions();
    _startPeriodicSync();
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSync();
    }
  }

  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 30), (timer) async {
      await _triggerSync();
    });
  }

  Future<void> _triggerSync() async {
    try {
      final hasConnection = await BackendService.hasConnection();
      final currentUser = HiveService.getCurrentUser();
      
      if (hasConnection && currentUser != null) {
        await BackendService.fullSync();
        
        if (mounted) {
          await _loadFoodEntries();
          await _loadWorkoutData();
        }
      }
    } catch (e) {
      // Silently handle sync errors
    }
  }

  Future<void> _checkNotificationPermissions() async {
    final hasPermission = await _notificationService.hasPermission();
    if (mounted) {
      setState(() {
        _notificationsEnabled = hasPermission;
      });
    }
    
    if (!hasPermission) {
      _requestNotificationPermission();
    }
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await _notificationService.requestPermission();
    if (mounted) {
      setState(() {
        _notificationsEnabled = granted;
      });
    }
    
    if (granted) {
      _scheduleDefaultNotifications();
    }
  }

  void _scheduleDefaultNotifications() {
    _notificationService.scheduleDailyNotification(
      id: 1,
      title: '🍳 ¡Hora del desayuno!',
      body: 'No olvides registrar tu desayuno para mantener tus metas nutricionales',
      hour: 8,
      minute: 0,
    );

    _notificationService.scheduleDailyNotification(
      id: 2,
      title: '🍲 ¡Hora del almuerzo!',
      body: 'Es momento de alimentarte bien. ¿Qué vas a comer hoy?',
      hour: 13,
      minute: 0,
    );

    _notificationService.scheduleDailyNotification(
      id: 3,
      title: '🍽️ ¡Hora de la cena!',
      body: 'Completa tu día con una cena balanceada',
      hour: 19,
      minute: 0,
    );

    _notificationService.scheduleDailyNotification(
      id: 4,
      title: '💪 ¡Momento de ejercitarte!',
      body: 'Mantén tu rutina de ejercicios para alcanzar tus metas fitness',
      hour: 18,
      minute: 0,
    );
  }

  Future<void> _initializeUserData() async {
    try {
      _user = HiveService.getCurrentUser();
      
      if (_user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
        return;
      }
      
      await _loadFoodEntries();
      await _loadWorkoutData();
      
      final hasConnection = await BackendService.hasConnection();
      if (hasConnection) {
        await BackendService.fullSync();
      }
      
    } catch (e) {
      // Silently handle initialization errors
    }
  }

  Future<void> _loadWorkoutData() async {
    try {
      final monthlyStats = WorkoutService.getMonthlyStats();
      setState(() {
        _completedWorkoutsThisMonth = monthlyStats['completed'] ?? 0;
      });
    } catch (e) {
      // Silently handle workout data errors
    }
  }

  Future<void> _loadFoodEntries() async {
    try {
      final entries = HiveService.appDataBox.get('foodEntries', defaultValue: <FoodEntry>[]).whereType<FoodEntry>().toList();
      
      final today = DateTime.now();
      final todayEntries = entries.where((entry) =>
        entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day
      ).toList();

      final totalCalories = todayEntries.fold(0.0, (sum, entry) => sum + entry.calories);
      final totalProtein = todayEntries.fold(0.0, (sum, entry) => sum + entry.protein);
      final totalCarbs = todayEntries.fold(0.0, (sum, entry) => sum + entry.carbs);
      final totalFat = todayEntries.fold(0.0, (sum, entry) => sum + entry.fat);
      
      setState(() {
        _caloriesConsumed = totalCalories;
        _proteinConsumed = totalProtein;
        _carbsConsumed = totalCarbs;
        _fatConsumed = totalFat;
      });
      
    } catch (e) {
      // Silently handle food entries errors
    }
  }

  void _addFoodEntry() {
    Navigator.pushNamed(context, '/nutrition_philosophy').then((_) {
      _loadFoodEntries();
      _triggerSync();
    });
  }

  void _goToWorkoutScreen() {
    Navigator.pushNamed(context, '/workout').then((_) {
      _loadWorkoutData();
      _triggerSync();
    });
  }

  void _logout() async {
    await HiveService.userBox.clear();
    await HiveService.settingsBox.clear(); 
    await HiveService.appDataBox.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔔 Notificaciones'),
        content: const Text(
          '¿Quieres recibir recordatorios para tus comidas y ejercicios? '
          'Te ayudaremos a mantener tu rutina diaria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ahora no'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestNotificationPermission();
            },
            child: const Text('¡Sí, activar!'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: app_main.betterMePrimaryColor),
            child: const Text('BetterMe', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Entrenamiento'),
            onTap: () {
              Navigator.pop(context);
              _goToWorkoutScreen();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Apoyar la app'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/donations');
            },
          ),
          ListTile(
            leading: Icon(_notificationsEnabled ? Icons.notifications_active : Icons.notifications_off),
            title: const Text('Notificaciones'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                if (value) {
                  _requestNotificationPermission();
                } else {
                  _notificationService.cancelAllNotifications();
                  setState(() {
                    _notificationsEnabled = false;
                  });
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final monthName = _getMonthName(now.month);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_main.betterMePrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: app_main.betterMePrimaryColor,
            child: Text(
              _user?.firstName[0].toUpperCase() ?? 'U',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${_user?.firstName ?? 'Usuario'}! 👋',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Hoy es $dayName, ${now.day} de $monthName',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: _notificationsEnabled ? app_main.betterMePrimaryColor : Colors.grey,
            ),
            onPressed: _showNotificationDialog,
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }

  Widget _buildProgressCard() {
    final progress = _caloriesConsumed / (_user?.dailyCalories ?? 2000);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    color: app_main.betterMePrimaryColor,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${_caloriesConsumed.round()}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'de ${_user?.dailyCalories.round() ?? 2000}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'calorías',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildMacroInfoRow('Proteína', _proteinConsumed.round(), _user?.proteinGoal.round() ?? 150, Colors.blue),
            _buildMacroInfoRow('Carbs', _carbsConsumed.round(), _user?.carbsGoal.round() ?? 250, Colors.green),
            _buildMacroInfoRow('Grasas', _fatConsumed.round(), _user?.fatGoal.round() ?? 70, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfoRow(String label, int consumed, int target, Color color) {
    final percentage = target > 0 ? (consumed / target * 100).clamp(0, 100).toInt() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text('$consumed/$target g', style: const TextStyle(fontSize: 12))),
          Expanded(
            flex: 1,
            child: Text(
              '$percentage%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection() {
    final monthlyStats = WorkoutService.getMonthlyStats();
    final goal = monthlyStats['goal'] ?? 12;
    final completed = monthlyStats['completed'] ?? 0;
    final percentage = monthlyStats['percentage'] ?? 0;
    final remaining = monthlyStats['remaining'] ?? goal;
    
    final lastMonthComparison = WorkoutService.getLastMonthComparison();
    final improvement = lastMonthComparison['improvement'] ?? 0;
    final improvementText = improvement > 0 ? 
        '+$improvement vs mes anterior 📈' : 
        improvement < 0 ? 
        '$improvement vs mes anterior 📉' : 
        'Igual que el mes anterior';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💪 Entrenamiento Mensual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.fitness_center, size: 40, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  '$completed/$goal entrenamientos',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  improvementText,
                  style: TextStyle(
                    fontSize: 12,
                    color: improvement > 0 ? Colors.green : 
                           improvement < 0 ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completed / goal,
                  backgroundColor: Colors.grey[200],
                  color: app_main.betterMePrimaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage% completado - $remaining restantes',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _goToWorkoutScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app_main.betterMePrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Registrar Entrenamiento de Hoy'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: app_main.betterMePrimaryColor)),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No se encontraron datos de usuario'),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding'),
                child: const Text('Completar Onboarding'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Inicio', style: TextStyle(color: Colors.white)),
        backgroundColor: app_main.betterMePrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.isDrawerOpen 
              ? _scaffoldKey.currentState!.closeDrawer() 
              : _scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildWorkoutSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: FloatingActionButton(
              onPressed: _addFoodEntry,
              backgroundColor: app_main.betterMePrimaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  } 
}