// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimelineEventModelAdapter extends TypeAdapter<TimelineEventModel> {
  @override
  final int typeId = 18;

  @override
  TimelineEventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimelineEventModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      eventType: fields[2] as String,
      title: fields[3] as String,
      subtitle: fields[4] as String?,
      iconAsset: fields[5] as String,
      date: fields[6] as DateTime,
      relatedRecordId: fields[7] as String?,
      thumbnailPath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TimelineEventModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.eventType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.subtitle)
      ..writeByte(5)
      ..write(obj.iconAsset)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.relatedRecordId)
      ..writeByte(8)
      ..write(obj.thumbnailPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineEventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
