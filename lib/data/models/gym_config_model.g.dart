// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymConfigModelAdapter extends TypeAdapter<GymConfigModel> {
  @override
  final int typeId = 20;

  @override
  GymConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymConfigModel(
      gymName: fields[0] as String,
      logoPath: fields[1] as String?,
      address: fields[2] as String,
      contactPhone: fields[3] as String,
      contactEmail: fields[4] as String,
      workingDays: (fields[5] as List).cast<String>(),
      openingTime: fields[6] as String,
      closingTime: fields[7] as String,
      taxPercent: fields[8] as double,
      currencySymbol: fields[9] as String,
      currencyCode: fields[10] as String,
      themeMode: fields[11] as String,
      branches: (fields[12] as List).cast<BranchModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, GymConfigModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.gymName)
      ..writeByte(1)
      ..write(obj.logoPath)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.contactPhone)
      ..writeByte(4)
      ..write(obj.contactEmail)
      ..writeByte(5)
      ..write(obj.workingDays)
      ..writeByte(6)
      ..write(obj.openingTime)
      ..writeByte(7)
      ..write(obj.closingTime)
      ..writeByte(8)
      ..write(obj.taxPercent)
      ..writeByte(9)
      ..write(obj.currencySymbol)
      ..writeByte(10)
      ..write(obj.currencyCode)
      ..writeByte(11)
      ..write(obj.themeMode)
      ..writeByte(12)
      ..write(obj.branches);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BranchModelAdapter extends TypeAdapter<BranchModel> {
  @override
  final int typeId = 21;

  @override
  BranchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BranchModel(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      isMainBranch: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BranchModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.isMainBranch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
