// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 16;

  @override
  AchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      achievementKey: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String,
      iconAsset: fields[5] as String,
      earnedDate: fields[6] as DateTime,
      relatedGoalId: fields[7] as String?,
      isSeen: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.achievementKey)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.iconAsset)
      ..writeByte(6)
      ..write(obj.earnedDate)
      ..writeByte(7)
      ..write(obj.relatedGoalId)
      ..writeByte(8)
      ..write(obj.isSeen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
