// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written to mirror the build_runner output for GoalModel.
// To regenerate, run:
//   dart run build_runner build --delete-conflicting-outputs
//
// Field map:
//   0  -> id (String)
//   1  -> memberId (String)
//   2  -> goalType (String)
//   3  -> goalTitle (String)
//   4  -> targetValue (double)
//   5  -> currentValue (double)
//   6  -> unit (String)
//   7  -> startDate (DateTime)
//   8  -> targetDate (DateTime?)
//   9  -> priority (String)
//   10 -> status (String)
//   11 -> trainerNotes (String?)
//   12 -> memberNotes (String?)
//   13 -> trackingMode (String)        [new]
//   14 -> startingValue (double)       [new]
//   15 -> remainingValue (double)      [new]
//   16 -> progressPercentage (double)   [new]
//   17 -> completedAt (DateTime?)      [new]
//   18 -> milestones (List<GoalMilestoneModel>) [new]
//   19 -> notes (String?)               [new]
//   20 -> metricKind (String)           [new]
// numOfFields: 21

part of 'goal_model.dart';

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 15;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      goalType: fields[2] as String,
      goalTitle: fields[3] as String,
      targetValue: (fields[4] as num).toDouble(),
      currentValue: (fields[5] as num).toDouble(),
      unit: fields[6] as String,
      startDate: fields[7] as DateTime,
      targetDate: fields[8] as DateTime?,
      priority: fields[9] as String,
      status: fields[10] as String,
      trainerNotes: fields[11] as String?,
      memberNotes: fields[12] as String?,
      trackingMode: (fields[13] as String?) ?? 'manual',
      startingValue: (fields[14] as num?)?.toDouble() ?? 0.0,
      remainingValue: (fields[15] as num?)?.toDouble() ?? 0.0,
      progressPercentage: (fields[16] as num?)?.toDouble() ?? 0.0,
      completedAt: fields[17] as DateTime?,
      milestones: (fields[18] as List?)?.cast<GoalMilestoneModel>() ??
          <GoalMilestoneModel>[],
      notes: fields[19] as String?,
      metricKind: (fields[20] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.goalType)
      ..writeByte(3)
      ..write(obj.goalTitle)
      ..writeByte(4)
      ..write(obj.targetValue)
      ..writeByte(5)
      ..write(obj.currentValue)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.targetDate)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.trainerNotes)
      ..writeByte(12)
      ..write(obj.memberNotes)
      ..writeByte(13)
      ..write(obj.trackingMode)
      ..writeByte(14)
      ..write(obj.startingValue)
      ..writeByte(15)
      ..write(obj.remainingValue)
      ..writeByte(16)
      ..write(obj.progressPercentage)
      ..writeByte(17)
      ..write(obj.completedAt)
      ..writeByte(18)
      ..write(obj.milestones)
      ..writeByte(19)
      ..write(obj.notes)
      ..writeByte(20)
      ..write(obj.metricKind);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}