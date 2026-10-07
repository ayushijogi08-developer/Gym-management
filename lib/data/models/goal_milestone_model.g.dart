// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written to mirror the build_runner output for GoalMilestoneModel.
// This file is part of 'goal_milestone_model.dart'.
//
// To regenerate, run:
//   dart run build_runner build --delete-conflicting-outputs
//
// Field map:
//   0 -> id (String)
//   1 -> goalId (String)
//   2 -> threshold (double)
//   3 -> label (String)
//   4 -> achievedAt (DateTime?)
//   5 -> celebrated (bool)
// numOfFields: 6

part of 'goal_milestone_model.dart';

class GoalMilestoneModelAdapter extends TypeAdapter<GoalMilestoneModel> {
  @override
  final int typeId = 23;

  @override
  GoalMilestoneModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMilestoneModel(
      id: fields[0] as String,
      goalId: fields[1] as String,
      threshold: (fields[2] as num).toDouble(),
      label: fields[3] as String,
      achievedAt: fields[4] as DateTime?,
      celebrated: (fields[5] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, GoalMilestoneModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.threshold)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.achievedAt)
      ..writeByte(5)
      ..write(obj.celebrated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestoneModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
