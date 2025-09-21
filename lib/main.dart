import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Importaciones de adapters
import 'adapters/food_entry_adapter.dart';
import 'adapters/time_of_day_adapter.dart';
import 'adapters/user_model_adapter.dart';
import 'adapters/workout_session_adapter.dart';

// Importaciones de pantallas
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/initial_philosophy_screen.dart';
import 'screens/fitness_philosophy_screen.dart';
import 'screens/nutrition_philosophy_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ia_analysis_screen.dart';
import 'screens/add_food_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/donations_screen.dart';

// Importaciones de servicios
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/food_ai_service.dart';
import 'services/backend_service.dart';

// CONSTANTES DE COLOR
const Color betterMePrimaryColor = Color(0xFF7B1FA2);
const Color betterMeSecondaryColor = Color(0xFFE91E63);
const Color betterMeHintColor = Color.fromARGB(255, 146, 68, 219);
const Color betterMeFillColor = Color(0xFFE0E0E0);
const Color betterMeAccentColor = Color(0xFF9C27B0);
const Color betterMeBackgroundColor = Colors.white;
const Color betterMeTextColor = Colors.black87;
const Color betterMeCardColor = Color(0xFFF5F5F5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // ✅ CARGAR VARIABLES DE ENTORNO PRIMERO
    await dotenv.load(fileName: '.env');
    
    // ✅ INICIALIZAR HIVE PRIMERO (SIN FIREBASE POR AHORA)
    await Hive.initFlutter();
    
    // ✅ REGISTRAR ADAPTERS
    Hive.registerAdapter(TimeOfDayAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(FoodEntryAdapter());  
    Hive.registerAdapter(WorkoutSessionAdapter());
    
    // ✅ INICIALIZAR SERVICIOS BÁSICOS
    await HiveService.initialize();
    
    // ✅ INICIALIZAR NOTIFICACIONES (OPCIONAL, PUEDE FALLAR)
    try {
      await NotificationService().initialize();
    } catch (e) {
      print('⚠️ Notificaciones no inicializadas: $e');
    }
    
    FoodAIService.initializeCache();
    
    runApp(const BetterMeApp());
  } catch (e) {
    print('Error crítico en inicialización: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class BetterMeApp extends StatelessWidget {
  const BetterMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterMe - Asistente de Nutrición',
      theme: _buildAppTheme(),
      initialRoute: '/splash',
      routes: _buildAppRoutes(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primaryColor: betterMePrimaryColor,
      scaffoldBackgroundColor: betterMeBackgroundColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: betterMeTextColor),
        bodyMedium: TextStyle(color: betterMeTextColor),
        titleLarge: TextStyle(color: betterMeTextColor, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: betterMePrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: betterMePrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Map<String, Widget Function(BuildContext)> _buildAppRoutes() {
    return {
      '/splash': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/forgot_password': (context) => const ForgotPasswordScreen(),
      '/onboarding': (context) => const OnboardingScreen(),
      '/philosophy': (context) => const InitialPhilosophyScreen(),
      '/fitness_philosophy': (context) => const FitnessPhilosophyScreen(),
      '/nutrition_philosophy': (context) => const NutritionPhilosophyScreen(),
      '/ia_analysis': (context) => const IAAnalysisScreen(),
      '/recommendations': (context) => const RecommendationsScreen(),
      '/home': (context) => const HomeScreen(),
      '/add_food': (context) => const AddFoodScreen(),
      '/workout': (context) => const WorkoutScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/history': (context) => const HistoryScreen(),
      '/donations': (context) => const DonationsScreen(),
    };
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: betterMeBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Error Inicializando la App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: betterMeTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    // Limpiar todo y reiniciar
                    try {
                      await Hive.close();
                      await Hive.deleteBoxFromDisk('userBox');
                      await Hive.deleteBoxFromDisk('settingsBox');
                      await Hive.deleteBoxFromDisk('appDataBox');
                    } catch (e) {
                      print('Error limpiando: $e');
                    }
                    main();
                  },
                  child: const Text('Reiniciar desde Cero'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}