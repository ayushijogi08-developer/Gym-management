// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogModelAdapter extends TypeAdapter<WorkoutLogModel> {
  @override
  final int typeId = 13;

  @override
  WorkoutLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLogModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      workoutPlanId: fields[2] as String,
      exerciseName: fields[3] as String,
      date: fields[4] as DateTime,
      status: fields[5] as String,
      actualSetsCompleted: fields[6] as int?,
      weightUsedKg: fields[7] as double?,
      caloriesBurned: fields[8] as double?,
      workoutDurationMinutes: fields[9] as int?,
      notes: fields[10] as String?,
      loggedAt: fields[11] as DateTime?,
      trainerFeedback: fields[12] as String?,
      reps: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLogModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.workoutPlanId)
      ..writeByte(3)
      ..write(obj.exerciseName)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.actualSetsCompleted)
      ..writeByte(7)
      ..write(obj.weightUsedKg)
      ..writeByte(8)
      ..write(obj.caloriesBurned)
      ..writeByte(9)
      ..write(obj.workoutDurationMinutes)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.loggedAt)
      ..writeByte(12)
      ..write(obj.trainerFeedback)
      ..writeByte(13)
      ..write(obj.reps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
