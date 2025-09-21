// lib/services/backend_service.dart - VERSIÓN COMPATIBLE CON TU USERMODEL
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';

class BackendService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ SINCRONIZAR USUARIO ACTUAL CON TODOS TUS CAMPOS
  static Future<void> syncCurrentUser() async {
    try {
      final currentUser = HiveService.getCurrentUser();
      final firebaseUser = _auth.currentUser;
      
      if (currentUser == null || firebaseUser == null) {
        print('⚠️ No hay usuario para sincronizar');
        return;
      }

      // Convertir tu UserModel completo a Map para Firestore
      final userData = _userModelToMap(currentUser);
      
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        ...userData,
        'uid': firebaseUser.uid,
        'firebaseEmail': firebaseUser.email, // Email de Firebase Auth
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Usuario sincronizado con Firestore (${userData.length} campos)');
    } catch (e) {
      print('❌ Error sincronizando usuario: $e');
    }
  }

  // ✅ CONVERTIR TU USERMODEL COMPLETO A MAP
  static Map<String, dynamic> _userModelToMap(UserModel user) {
    return {
      // Datos personales
      'userId': user.userId,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'username': user.username,
      'age': user.age,
      'weight': user.weight,
      'height': user.height,
      'gender': user.gender,
      
      // Estilo de vida
      'lifestyle': user.lifestyle,
      'goal': user.goal,
      'workoutFrequency': user.workoutFrequency,
      'workoutExperience': user.workoutExperience,
      'foodBudget': user.foodBudget,
      'country': user.country,
      
      // Horarios y hábitos
      'wakeUpTime': user.wakeUpTime,
      'sleepTime': user.sleepTime,
      'bodyType': user.bodyType,
      'mealsPerDay': user.mealsPerDay,
      'dietType': user.dietType,
      'activityJob': user.activityJob,
      
      // Salud y bienestar
      'stressLevel': user.stressLevel,
      'sleepQuality': user.sleepQuality,
      'waterIntake': user.waterIntake,
      'foodHabits': user.foodHabits,
      'dietRestrictions': user.dietRestrictions,
      'cookingTime': user.cookingTime,
      'language': user.language,
      
      // Metas nutricionales
      'dailyCalories': user.dailyCalories,
      'proteinGoal': user.proteinGoal,
      'carbsGoal': user.carbsGoal,
      'fatGoal': user.fatGoal,
      'aiExplanation': user.aiExplanation,
      
      // Metadatos
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ✅ CARGAR USUARIO DESDE FIRESTORE
  static Future<void> loadUserFromFirestore() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final userModel = _mapToUserModel(data);
        
        // Guardar en Hive
        await HiveService.saveUser(userModel);
        print('✅ Usuario cargado desde Firestore y guardado en Hive');
      }
    } catch (e) {
      print('❌ Error cargando usuario desde Firestore: $e');
    }
  }

  // ✅ CONVERTIR MAP A TU USERMODEL
  static UserModel _mapToUserModel(Map<String, dynamic> data) {
    return UserModel(
      // Datos personales
      userId: data['userId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      age: (data['age'] ?? 25.0).toDouble(),
      weight: (data['weight'] ?? 70.0).toDouble(),
      height: (data['height'] ?? 170.0).toDouble(),
      gender: data['gender'] ?? 'Masculino',
      
      // Estilo de vida
      lifestyle: data['lifestyle'] ?? 'Moderadamente activo',
      goal: data['goal'] ?? 'Mantener peso',
      workoutFrequency: data['workoutFrequency'] ?? '3-4 veces por semana',
      workoutExperience: data['workoutExperience'] ?? 'Intermedio',
      foodBudget: data['foodBudget'] ?? 'Medio',
      country: data['country'] ?? 'Venezuela',
      
      // Horarios y hábitos
      wakeUpTime: data['wakeUpTime'] ?? '07:00',
      sleepTime: data['sleepTime'] ?? '23:00',
      bodyType: data['bodyType'] ?? 'Mesomorfo',
      mealsPerDay: data['mealsPerDay'] ?? '3 comidas',
      dietType: data['dietType'] ?? 'Equilibrado',
      activityJob: data['activityJob'] ?? 'Oficina sentado',
      
      // Salud y bienestar
      stressLevel: data['stressLevel'] ?? 'Moderado',
      sleepQuality: data['sleepQuality'] ?? 'Buena',
      waterIntake: data['waterIntake'] ?? '2 litros',
      foodHabits: data['foodHabits'] ?? 'Regular',
      dietRestrictions: data['dietRestrictions'] ?? 'Ninguna',
      cookingTime: data['cookingTime'] ?? '30-60 min',
      language: data['language'] ?? 'Español',
      
      // Metas nutricionales (se calcularán después si son 0)
      dailyCalories: (data['dailyCalories'] ?? 0.0).toDouble(),
      proteinGoal: (data['proteinGoal'] ?? 0.0).toDouble(),
      carbsGoal: (data['carbsGoal'] ?? 0.0).toDouble(),
      fatGoal: (data['fatGoal'] ?? 0.0).toDouble(),
      aiExplanation: data['aiExplanation'] ?? '',
    );
  }

  // ✅ SINCRONIZAR FOOD ENTRIES (COMPATIBLE CON TU APP)
  static Future<void> syncFoodEntries() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      // Obtener entries de tu HiveService
      final foodEntries = HiveService.appDataBox.get('foodHistory', defaultValue: []);
      
      if (foodEntries is List && foodEntries.isNotEmpty) {
        final batch = _firestore.batch();
        final entriesRef = _firestore.collection('users').doc(firebaseUser.uid).collection('food_entries');

        for (var i = 0; i < foodEntries.length; i++) {
          final entry = foodEntries[i];
          if (entry is Map<String, dynamic>) {
            final entryId = entry['id'] ?? 'entry_${DateTime.now().millisecondsSinceEpoch}_$i';
            final entryRef = entriesRef.doc(entryId);
            batch.set(entryRef, {
              ...entry,
              'syncedAt': FieldValue.serverTimestamp(),
              'userId': firebaseUser.uid,
            });
          }
        }

        await batch.commit();
        print('✅ ${foodEntries.length} food entries sincronizados');
      }
    } catch (e) {
      print('❌ Error sincronizando food entries: $e');
    }
  }

  // ✅ SINCRONIZAR WORKOUTS (COMPATIBLE CON TU APP)
  static Future<void> syncWorkouts() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      // Obtener workouts de tu HiveService
      final workouts = HiveService.appDataBox.get('workoutHistory', defaultValue: []);
      
      if (workouts is List && workouts.isNotEmpty) {
        final batch = _firestore.batch();
        final workoutsRef = _firestore.collection('users').doc(firebaseUser.uid).collection('workouts');

        for (var i = 0; i < workouts.length; i++) {
          final workout = workouts[i];
          if (workout is Map<String, dynamic>) {
            final workoutId = workout['id'] ?? 'workout_${DateTime.now().millisecondsSinceEpoch}_$i';
            final workoutRef = workoutsRef.doc(workoutId);
            batch.set(workoutRef, {
              ...workout,
              'syncedAt': FieldValue.serverTimestamp(),
              'userId': firebaseUser.uid,
            });
          }
        }

        await batch.commit();
        print('✅ ${workouts.length} workouts sincronizados');
      }
    } catch (e) {
      print('❌ Error sincronizando workouts: $e');
    }
  }

  // ✅ SINCRONIZACIÓN COMPLETA
  static Future<void> fullSync() async {
    try {
      print('🔄 Iniciando sincronización completa...');
      
      // 1. Primero cargar datos desde cloud (si existen)
      await loadUserFromFirestore();
      
      // 2. Sincronizar datos locales a cloud
      await syncCurrentUser();
      await syncFoodEntries();
      await syncWorkouts();
      
      print('✅ Sincronización completa exitosa');
    } catch (e) {
      print('❌ Error en sincronización completa: $e');
    }
  }

  // ✅ VERIFICAR CONEXIÓN
  static Future<bool> hasConnection() async {
    try {
      await _firestore.collection('connection_test').doc('test').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ OBTENER DATOS REMOTOS
  static Future<Map<String, dynamic>?> getRemoteUserData() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      return userDoc.data();
    } catch (e) {
      print('❌ Error obteniendo datos remotos: $e');
      return null;
    }
  }

  // ✅ ACTUALIZAR METAS NUTRICIONALES
  static Future<void> updateNutritionGoals(double calories, double protein, double carbs, double fat) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'dailyCalories': calories,
        'proteinGoal': protein,
        'carbsGoal': carbs,
        'fatGoal': fat,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      print('✅ Metas nutricionales actualizadas en Firestore');
    } catch (e) {
      print('❌ Error actualizando metas nutricionales: $e');
    }
  }
}