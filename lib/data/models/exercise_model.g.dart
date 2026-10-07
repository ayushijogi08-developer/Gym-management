// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 11;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseModel(
      exerciseName: fields[0] as String,
      targetMuscle: fields[1] as String,
      machineRequired: fields[2] as String?,
      sets: fields[3] as int,
      reps: fields[4] as int,
      restTimeSeconds: fields[5] as int,
      durationMinutes: fields[6] as int?,
      difficulty: fields[7] as String,
      imagePath: fields[8] as String?,
      videoPath: fields[9] as String?,
      instructions: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.targetMuscle)
      ..writeByte(2)
      ..write(obj.machineRequired)
      ..writeByte(3)
      ..write(obj.sets)
      ..writeByte(4)
      ..write(obj.reps)
      ..writeByte(5)
      ..write(obj.restTimeSeconds)
      ..writeByte(6)
      ..write(obj.durationMinutes)
      ..writeByte(7)
      ..write(obj.difficulty)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.videoPath)
      ..writeByte(10)
      ..write(obj.instructions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
