// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealReminderModelAdapter extends TypeAdapter<MealReminderModel> {
  @override
  final int typeId = 10;

  @override
  MealReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealReminderModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      dietPlanId: fields[2] as String,
      mealType: fields[3] as String,
      scheduledTime: fields[4] as String,
      isEnabled: fields[5] as bool,
      mutedByMember: fields[6] as bool,
      customMessage: fields[7] as String?,
      repeatDaily: fields[8] as bool,
      dndStart: fields[9] as String?,
      dndEnd: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealReminderModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.dietPlanId)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.isEnabled)
      ..writeByte(6)
      ..write(obj.mutedByMember)
      ..writeByte(7)
      ..write(obj.customMessage)
      ..writeByte(8)
      ..write(obj.repeatDaily)
      ..writeByte(9)
      ..write(obj.dndStart)
      ..writeByte(10)
      ..write(obj.dndEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
