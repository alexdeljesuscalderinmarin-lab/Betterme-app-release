import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  bool _isFirstLaunch = true;
  bool _hasCompletedOnboarding = false;
  bool _hasSeenPhilosophy = false;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSeenPhilosophy => _hasSeenPhilosophy;

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    _isFirstLaunch = false;
    notifyListeners();
  }

  void completePhilosophy() {
    _hasSeenPhilosophy = true;
    notifyListeners();
  }

  void reset() {
    _isFirstLaunch = true;
    _hasCompletedOnboarding = false;
    _hasSeenPhilosophy = false;
    notifyListeners();
  }

  // Cargar estado desde almacenamiento persistente
  void loadFromStorage(Map<String, dynamic> data) {
    _isFirstLaunch = data['isFirstLaunch'] ?? true;
    _hasCompletedOnboarding = data['hasCompletedOnboarding'] ?? false;
    _hasSeenPhilosophy = data['hasSeenPhilosophy'] ?? false;
    notifyListeners();
  }

  // Guardar estado para persistencia
  Map<String, dynamic> toMap() {
    return {
      'isFirstLaunch': _isFirstLaunch,
      'hasCompletedOnboarding': _hasCompletedOnboarding,
      'hasSeenPhilosophy': _hasSeenPhilosophy,
    };
  }
}