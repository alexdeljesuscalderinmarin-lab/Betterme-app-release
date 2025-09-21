import 'package:hive/hive.dart';
import '../models/user_model.dart';

class HiveService {
  static late Box<UserModel> userBox;
  static late Box settingsBox;
  static late Box appDataBox;

  static Future<void> initialize() async {
    try {
      // Cerrar boxes si ya estaban abiertas (previene el error)
      await _closeAllBoxes();
      
      // Abrir solo las boxes esenciales
      userBox = await Hive.openBox<UserModel>('userBox');
      settingsBox = await Hive.openBox('settingsBox');
      appDataBox = await Hive.openBox('appDataBox');
      
      print("✅ Todas las boxes de Hive inicializadas correctamente");
    } catch (e) {
      print("❌ Error inicializando Hive: $e");
      // Reintentar después de limpiar
      await _clearAndReinitialize();
    }
  }

  static Future<void> _closeAllBoxes() async {
    try {
      if (Hive.isBoxOpen('userBox')) await Hive.box('userBox').close();
      if (Hive.isBoxOpen('settingsBox')) await Hive.box('settingsBox').close();
      if (Hive.isBoxOpen('appDataBox')) await Hive.box('appDataBox').close();
    } catch (e) {
      print("Error cerrando boxes: $e");
    }
  }

  static Future<void> _clearAndReinitialize() async {
    try {
      await _closeAllBoxes();
      await Hive.deleteBoxFromDisk('userBox');
      await Hive.deleteBoxFromDisk('settingsBox');
      await Hive.deleteBoxFromDisk('appDataBox');
      
      // Reabrir boxes
      userBox = await Hive.openBox<UserModel>('userBox');
      settingsBox = await Hive.openBox('settingsBox');
      appDataBox = await Hive.openBox('appDataBox');
      
      print("✅ Hive reinicializado correctamente después de limpieza");
    } catch (e) {
      print("❌ Error crítico en reinicialización de Hive: $e");
      throw Exception("No se pudo inicializar Hive: $e");
    }
  }

  // ✅ MÉTODO CLEARALL AÑADIDO
  static Future<void> clearAll() async {
    try {
      await _closeAllBoxes();
      await userBox.clear();
      await settingsBox.clear();
      await appDataBox.clear();
      print("✅ Todas las boxes de Hive limpiadas correctamente");
    } catch (e) {
      print("❌ Error limpiando boxes: $e");
      throw Exception("No se pudieron limpiar los datos: $e");
    }
  }

  // Método para obtener el usuario actual
  static UserModel? getCurrentUser() {
    try {
      return userBox.get('currentUser');
    } catch (e) {
      print("❌ Error obteniendo usuario actual: $e");
      return null;
    }
  }

  // Método para guardar usuario
  static Future<void> saveUser(UserModel user) async {
    try {
      await userBox.put('currentUser', user);
      print("✅ Usuario guardado correctamente");
    } catch (e) {
      print("❌ Error guardando usuario: $e");
      throw Exception("No se pudo guardar el usuario: $e");
    }
  }

  // Métodos de ayuda para acceder a las boxes
  static Box<UserModel> get userBoxInstance => userBox;
  static Box get settingsBoxInstance => settingsBox;
  static Box get appDataBoxInstance => appDataBox;
}