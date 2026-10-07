// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueModelAdapter extends TypeAdapter<SyncQueueModel> {
  @override
  final int typeId = 22;

  @override
  SyncQueueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueModel(
      id: fields[0] as String,
      endpoint: fields[1] as String,
      method: fields[2] as String,
      payload: fields[3] as String,
      createdAt: fields[4] as DateTime,
      synced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.endpoint)
      ..writeByte(2)
      ..write(obj.method)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
