import 'package:hive/hive.dart';

part 'meal_model.g.dart';

@HiveType(typeId: 7)
class MealModel extends HiveObject {
  @HiveField(0)
  String mealType;

  @HiveField(1)
  String mealName;

  @HiveField(2)
  List<String> foodItems;

  @HiveField(3)
  String quantity;

  @HiveField(4)
  double calories;

  @HiveField(5)
  double protein;

  @HiveField(6)
  double carbs;

  @HiveField(7)
  double fats;

  @HiveField(8)
  double fiber;

  @HiveField(9)
  double sugar;

  @HiveField(10)
  int? waterIntakeMl;

  @HiveField(11)
  String? instructions;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  String? imagePath;

  MealModel({
    required this.mealType,
    required this.mealName,
    required this.foodItems,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sugar = 0,
    this.waterIntakeMl,
    this.instructions,
    this.notes,
    this.imagePath,
  });
  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'mealName': mealName,
      'foodItems': foodItems,
      'quantity': quantity,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'waterIntakeMl': waterIntakeMl,
      'instructions': instructions,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      mealType: (json['mealType'] ?? json['type'] ?? 'Meal').toString(),
      mealName: (json['mealName'] ?? json['name'] ?? 'Unnamed Meal').toString(),
      
      foodItems: (json['foodItems'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() 
          ?? <String>[],

      quantity: (json['quantity'] ?? '1 serving').toString(),

      calories: (json['calories'] as num?)?.toDouble() ?? 400.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 20.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 50.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 15.0,

      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,

      waterIntakeMl: json['waterIntakeMl'] as int?,
      instructions: json['instructions']?.toString(),
      notes: json['notes']?.toString(),
      imagePath: json['imagePath']?.toString(),
    );
  }
}