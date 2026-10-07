import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 11)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  String targetMuscle;

  @HiveField(2)
  String? machineRequired;

  @HiveField(3)
  int sets;

  @HiveField(4)
  int reps;

  @HiveField(5)
  int restTimeSeconds;

  @HiveField(6)
  int? durationMinutes; // For time-based exercises

  @HiveField(7)
  String difficulty; // Beginner / Intermediate / Advanced

  @HiveField(8)
  String? imagePath;

  @HiveField(9)
  String? videoPath;

  @HiveField(10)
  String? instructions;

  ExerciseModel({
    required this.exerciseName,
    required this.targetMuscle,
    this.machineRequired,
    required this.sets,
    required this.reps,
    required this.restTimeSeconds,
    this.durationMinutes,
    required this.difficulty,
    this.imagePath,
    this.videoPath,
    this.instructions,
  });
  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'targetMuscle': targetMuscle,
      'machineRequired': machineRequired,
      'sets': sets,
      'reps': reps,
      'restTimeSeconds': restTimeSeconds,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'instructions': instructions,
    };
  }

  // --- ADDED: For Restore (Import) ---
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      exerciseName: json['exerciseName'],
      targetMuscle: json['targetMuscle'],
      machineRequired: json['machineRequired'],
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restTimeSeconds: json['restTimeSeconds'] as int,
      durationMinutes: json['durationMinutes'] as int?,
      difficulty: json['difficulty'],
      imagePath: json['imagePath'],
      videoPath: json['videoPath'],
      instructions: json['instructions'],
    );
  }
}