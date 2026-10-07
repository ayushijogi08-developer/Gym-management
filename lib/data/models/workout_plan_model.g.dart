// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutPlanModelAdapter extends TypeAdapter<WorkoutPlanModel> {
  @override
  final int typeId = 12;

  @override
  WorkoutPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutPlanModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      createdByTrainerId: fields[2] as String,
      category: fields[3] as String,
      exercises: (fields[4] as List).cast<ExerciseModel>(),
      startDate: fields[5] as DateTime?,
      endDate: fields[6] as DateTime?,
      isActive: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutPlanModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.createdByTrainerId)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.exercises)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
