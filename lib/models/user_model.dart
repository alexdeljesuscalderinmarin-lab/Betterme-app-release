import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String firstName;
  
  @HiveField(2)
  final String lastName;
  
  @HiveField(3)
  final String username;
  
  @HiveField(4)
  final double age;
  
  @HiveField(5)
  final double weight;
  
  @HiveField(6)
  final double height;
  
  @HiveField(7)
  final String gender;
  
  @HiveField(8)
  final String lifestyle;
  
  @HiveField(9)
  final String goal;
  
  @HiveField(10)
  final String workoutFrequency;
  
  @HiveField(11)
  final String workoutExperience;
  
  @HiveField(12)
  final String foodBudget;
  
  @HiveField(13)
  final String country;
  
  @HiveField(14)
  final String wakeUpTime;
  
  @HiveField(15)
  final String sleepTime;
  
  @HiveField(16)
  final String bodyType;
  
  @HiveField(17)
  final String mealsPerDay;
  
  @HiveField(18)
  final String dietType;
  
  @HiveField(19)
  final String activityJob;
  
  @HiveField(20)
  final String stressLevel;
  
  @HiveField(21)
  final String sleepQuality;
  
  @HiveField(22)
  final String waterIntake;
  
  @HiveField(23)
  final String foodHabits;
  
  @HiveField(24)
  final String dietRestrictions;
  
  @HiveField(25)
  final String cookingTime;
  
  @HiveField(26)
  final String language;
  
  @HiveField(27)
  double dailyCalories;
  
  @HiveField(28)
  double proteinGoal;
  
  @HiveField(29)
  double carbsGoal;
  
  @HiveField(30)
  double fatGoal;
  
  @HiveField(31)
  String aiExplanation;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.lifestyle,
    required this.goal,
    required this.workoutFrequency,
    required this.workoutExperience,
    required this.foodBudget,
    required this.country,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.bodyType,
    required this.mealsPerDay,
    required this.dietType,
    required this.activityJob,
    required this.stressLevel,
    required this.sleepQuality,
    required this.waterIntake,
    required this.foodHabits,
    required this.dietRestrictions,
    required this.cookingTime,
    required this.language,
    this.dailyCalories = 0.0,
    this.proteinGoal = 0.0,
    this.carbsGoal = 0.0,
    this.fatGoal = 0.0,
    this.aiExplanation = '',
  });

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? username,
    double? age,
    double? weight,
    double? height,
    String? gender,
    String? lifestyle,
    String? goal,
    String? workoutFrequency,
    String? workoutExperience,
    String? foodBudget,
    String? country,
    String? wakeUpTime,
    String? sleepTime,
    String? bodyType,
    String? mealsPerDay,
    String? dietType,
    String? activityJob,
    String? stressLevel,
    String? sleepQuality,
    String? waterIntake,
    String? foodHabits,
    String? dietRestrictions,
    String? cookingTime,
    String? language,
    double? dailyCalories,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    String? aiExplanation,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      lifestyle: lifestyle ?? this.lifestyle,
      goal: goal ?? this.goal,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      workoutExperience: workoutExperience ?? this.workoutExperience,
      foodBudget: foodBudget ?? this.foodBudget,
      country: country ?? this.country,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      sleepTime: sleepTime ?? this.sleepTime,
      bodyType: bodyType ?? this.bodyType,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      dietType: dietType ?? this.dietType,
      activityJob: activityJob ?? this.activityJob,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      waterIntake: waterIntake ?? this.waterIntake,
      foodHabits: foodHabits ?? this.foodHabits,
      dietRestrictions: dietRestrictions ?? this.dietRestrictions,
      cookingTime: cookingTime ?? this.cookingTime,
      language: language ?? this.language,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      aiExplanation: aiExplanation ?? this.aiExplanation,
    );
  }

  Map<String, dynamic> calculateRecommendations() {
    double bmr;
    if (gender == 'Masculino') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    final Map<String, double> activityFactors = {
      'Sedentario': 1.2,
      'Ligera actividad': 1.375,
      'Moderadamente activo': 1.55,
      'Muy activo': 1.725,
      'Extremadamente activo': 1.9,
    };

    double activityFactor = activityFactors[lifestyle] ?? 1.55;
    double maintenanceCalories = bmr * activityFactor;

    final Map<String, double> goalFactors = {
      'Ganar masa muscular': 1.15,
      'Perder grasa': 0.85,
      'Mantener peso': 1.0,
    };

    double targetCalories = maintenanceCalories * (goalFactors[goal] ?? 1.0);

    return {
      'dailyCalories': targetCalories,
      'proteinGoal': (targetCalories * 0.3 / 4),
      'carbsGoal': (targetCalories * 0.4 / 4),
      'fatGoal': (targetCalories * 0.3 / 9),
      'aiExplanation': 'Recomendaciones calculadas localmente',
    };
  }
}