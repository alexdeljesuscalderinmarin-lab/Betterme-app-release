import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';
import '../main.dart' as app_main;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = HiveService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Mi Perfil'),
        backgroundColor: app_main.betterMePrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: userData == null
          ? _buildNoUserView()
          : _buildUserProfile(userData, context),
    );
  }

  Widget _buildNoUserView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No se encontraron datos de usuario',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Completa el onboarding para ver tu perfil',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(UserModel userData, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar y nombre
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: app_main.betterMePrimaryColor,
                  child: Text(
                    '${userData.firstName[0]}${userData.lastName.isNotEmpty ? userData.lastName[0] : ""}',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${userData.firstName} ${userData.lastName}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${userData.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // METAS DIARIAS
          _buildDailyGoals(userData),
          
          const SizedBox(height: 20),
          const Divider(),
          
          // Información básica
          _buildInfoRow('🎯 Objetivo', userData.goal),
          _buildInfoRow('📏 Estatura', '${userData.height} cm'),
          _buildInfoRow('⚖️ Peso', '${userData.weight} kg'),
          _buildInfoRow('🎂 Edad', '${userData.age} años'),
          
          const SizedBox(height: 20),
          const Divider(),
          
          // Información adicional
          _buildInfoRow('🌎 País', userData.country),
          _buildInfoRow('💼 Estilo de vida', userData.lifestyle),
          _buildInfoRow('🏋️ Frecuencia de ejercicio', userData.workoutFrequency),
          _buildInfoRow('🍽️ Comidas por día', userData.mealsPerDay),
          
          const SizedBox(height: 30),
          
          // Botón de cerrar sesión
          Center(
            child: ElevatedButton(
              onPressed: () {
                HiveService.clearAll();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/splash', 
                  (route) => false
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDailyGoals(UserModel user) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Tus Metas Diarias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: app_main.betterMePrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildGoalRow('🔥 Calorías', '${user.dailyCalories.round()} kcal', Colors.orange),
            _buildGoalRow('🍗 Proteína', '${user.proteinGoal.round()}g', Colors.blue),
            _buildGoalRow('🍚 Carbohidratos', '${user.carbsGoal.round()}g', Colors.green),
            _buildGoalRow('🥑 Grasas', '${user.fatGoal.round()}g', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'No especificado'),
          ),
        ],
      ),
    );
  }
}