// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override
  final int typeId = 5;

  @override
  SubscriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      planId: fields[2] as String,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      status: fields[5] as String,
      pausedOn: fields[6] as DateTime?,
      resumedOn: fields[7] as DateTime?,
      previousSubscriptionId: fields[8] as String?,
      gracePeriodDays: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.planId)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.pausedOn)
      ..writeByte(7)
      ..write(obj.resumedOn)
      ..writeByte(8)
      ..write(obj.previousSubscriptionId)
      ..writeByte(9)
      ..write(obj.gracePeriodDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
