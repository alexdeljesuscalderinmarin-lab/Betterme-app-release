import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      userId: reader.read(),
      firstName: reader.read(),
      lastName: reader.read(),
      username: reader.read(),
      age: reader.read(),
      weight: reader.read(),
      height: reader.read(),
      gender: reader.read(),
      lifestyle: reader.read(),
      goal: reader.read(),
      workoutFrequency: reader.read(),
      workoutExperience: reader.read(),
      foodBudget: reader.read(),
      country: reader.read(),
      wakeUpTime: reader.read(),
      sleepTime: reader.read(),
      bodyType: reader.read(),
      mealsPerDay: reader.read(),
      dietType: reader.read(),
      activityJob: reader.read(),
      stressLevel: reader.read(),
      sleepQuality: reader.read(),
      waterIntake: reader.read(),
      foodHabits: reader.read(),
      dietRestrictions: reader.read(),
      cookingTime: reader.read(),
      language: reader.read(),
    )
      ..dailyCalories = reader.read()
      ..proteinGoal = reader.read()
      ..carbsGoal = reader.read()
      ..fatGoal = reader.read()
      ..aiExplanation = reader.read();
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.userId);
    writer.write(obj.firstName);
    writer.write(obj.lastName);
    writer.write(obj.username);
    writer.write(obj.age);
    writer.write(obj.weight);
    writer.write(obj.height);
    writer.write(obj.gender);
    writer.write(obj.lifestyle);
    writer.write(obj.goal);
    writer.write(obj.workoutFrequency);
    writer.write(obj.workoutExperience);
    writer.write(obj.foodBudget);
    writer.write(obj.country);
    writer.write(obj.wakeUpTime);
    writer.write(obj.sleepTime);
    writer.write(obj.bodyType);
    writer.write(obj.mealsPerDay);
    writer.write(obj.dietType);
    writer.write(obj.activityJob);
    writer.write(obj.stressLevel);
    writer.write(obj.sleepQuality);
    writer.write(obj.waterIntake);
    writer.write(obj.foodHabits);
    writer.write(obj.dietRestrictions);
    writer.write(obj.cookingTime);
    writer.write(obj.language);
    writer.write(obj.dailyCalories);
    writer.write(obj.proteinGoal);
    writer.write(obj.carbsGoal);
    writer.write(obj.fatGoal);
    writer.write(obj.aiExplanation);
  }
}