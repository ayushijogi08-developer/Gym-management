// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserModelAdapter extends TypeAdapter<AppUserModel> {
  @override
  final int typeId = 4;

  @override
  AppUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      passwordHash: fields[3] as String,
      role: fields[4] as String,
      linkedMemberId: fields[5] as String?,
      linkedTrainerId: fields[6] as String?,
      assignedBranchId: fields[7] as String?,
      isActive: fields[8] as bool,
      mustChangePassword: fields[9] as bool,
      phone: fields[10] as String?,
      customPermissions: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppUserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.linkedMemberId)
      ..writeByte(6)
      ..write(obj.linkedTrainerId)
      ..writeByte(7)
      ..write(obj.assignedBranchId)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.mustChangePassword)
      ..writeByte(10)
      ..write(obj.phone)
      ..writeByte(11)
      ..write(obj.customPermissions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
