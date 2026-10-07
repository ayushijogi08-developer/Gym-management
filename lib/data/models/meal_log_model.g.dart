// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealLogModelAdapter extends TypeAdapter<MealLogModel> {
  @override
  final int typeId = 9;

  @override
  MealLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealLogModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      dietPlanId: fields[2] as String,
      mealType: fields[3] as String,
      date: fields[4] as DateTime,
      status: fields[5] as String,
      personalNote: fields[6] as String?,
      loggedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MealLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.dietPlanId)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.personalNote)
      ..writeByte(7)
      ..write(obj.loggedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
