import 'dart:io';
import 'package:flutter/material.dart';
import '../models/food_entry_model.dart';
import '../services/hive_service.dart';
import '../main.dart' as app_main;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FoodEntry> _foodEntries = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadFoodEntries();
  }

  void _loadFoodEntries() {
    try {
      final entries = HiveService.appDataBox.get('foodEntries', defaultValue: <FoodEntry>[]);
      setState(() {
        _foodEntries = entries.cast<FoodEntry>();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading food entries: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFoodEntry(String id) async {
    setState(() {
      _foodEntries.removeWhere((entry) => entry.id == id);
    });
    
    await HiveService.appDataBox.put('foodEntries', _foodEntries);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comida eliminada')),
    );
  }

  List<FoodEntry> get _filteredEntries {
    switch (_filter) {
      case 'breakfast':
        return _foodEntries.where((entry) => entry.mealType == 'Desayuno').toList();
      case 'lunch':
        return _foodEntries.where((entry) => entry.mealType == 'Almuerzo').toList();
      case 'dinner':
        return _foodEntries.where((entry) => entry.mealType == 'Cena').toList();
      case 'snack':
        return _foodEntries.where((entry) => entry.mealType == 'Snack').toList();
      default:
        return _foodEntries;
    }
  }
  
  Map<String, List<FoodEntry>> get _groupedEntries {
    final Map<String, List<FoodEntry>> grouped = {};
    for (var entry in _filteredEntries) {
      final date = '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Comidas', style: TextStyle(color: Colors.white)),
        backgroundColor: app_main.betterMePrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foodEntries.isEmpty
              ? const Center(
                  child: Text(
                    'No hay registros de comidas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView(
                  children: _groupedEntries.keys.map((date) {
                    final dailyEntries = _groupedEntries[date]!;
                    final dailyCalories = dailyEntries.fold<double>(
                      0, (sum, entry) => sum + entry.calories,
                    );

                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Día: $date - Total: ${dailyCalories.round()} kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: dailyEntries.map((entry) {
                        return ListTile(
                          leading: entry.imagePath != null ? CircleAvatar(
                            backgroundImage: FileImage(File(entry.imagePath!)),
                          ) : const CircleAvatar(child: Icon(Icons.fastfood)),
                          title: Text(
                            entry.foodName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${entry.mealType} - ${entry.calories.round()} kcal',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFoodEntry(entry.id),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                title: Text('Filtrar por tipo de comida', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              _buildFilterOption('all', 'Mostrar todo', Icons.filter_list_off),
              _buildFilterOption('breakfast', 'Desayunos', Icons.free_breakfast, Colors.amber),
              _buildFilterOption('lunch', 'Almuerzos', Icons.lunch_dining, Colors.green),
              _buildFilterOption('dinner', 'Cenas', Icons.dinner_dining, Colors.blue),
              _buildFilterOption('snack', 'Snacks', Icons.local_cafe, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildFilterOption(String value, String title, IconData icon, [Color? color]) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Radio(
        value: value,
        groupValue: _filter,
        onChanged: (value) => setState(() => _filter = value!),
      ),
      onTap: () => setState(() {
        _filter = value;
        Navigator.pop(context);
      }),
    );
  }
}