// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanModelAdapter extends TypeAdapter<PlanModel> {
  @override
  final int typeId = 1;

  @override
  PlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanModel(
      id: fields[0] as String,
      planName: fields[1] as String,
      durationType: fields[2] as String,
      durationInDays: fields[3] as int,
      price: fields[4] as double,
      discountPercent: fields[5] as double?,
      gstPercent: fields[6] as double?,
      description: fields[7] as String?,
      facilitiesIncluded: (fields[8] as List).cast<String>(),
      isPTIncluded: fields[9] as bool,
      isFreezeAllowed: fields[10] as bool,
      renewalReminderDays: fields[11] as int,
      status: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlanModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planName)
      ..writeByte(2)
      ..write(obj.durationType)
      ..writeByte(3)
      ..write(obj.durationInDays)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.discountPercent)
      ..writeByte(6)
      ..write(obj.gstPercent)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.facilitiesIncluded)
      ..writeByte(9)
      ..write(obj.isPTIncluded)
      ..writeByte(10)
      ..write(obj.isFreezeAllowed)
      ..writeByte(11)
      ..write(obj.renewalReminderDays)
      ..writeByte(12)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
