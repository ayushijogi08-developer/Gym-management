// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainerModelAdapter extends TypeAdapter<TrainerModel> {
  @override
  final int typeId = 3;

  @override
  TrainerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainerModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String,
      photoPath: fields[4] as String?,
      specialization: fields[5] as String,
      experienceYears: fields[6] as int,
      bio: fields[7] as String?,
      workingDays: (fields[8] as List).cast<String>(),
      shiftStart: fields[9] as String,
      shiftEnd: fields[10] as String,
      status: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrainerModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.photoPath)
      ..writeByte(5)
      ..write(obj.specialization)
      ..writeByte(6)
      ..write(obj.experienceYears)
      ..writeByte(7)
      ..write(obj.bio)
      ..writeByte(8)
      ..write(obj.workingDays)
      ..writeByte(9)
      ..write(obj.shiftStart)
      ..writeByte(10)
      ..write(obj.shiftEnd)
      ..writeByte(11)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
