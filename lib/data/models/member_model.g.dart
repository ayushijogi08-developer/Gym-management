// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberModelAdapter extends TypeAdapter<MemberModel> {
  @override
  final int typeId = 0;

  @override
  MemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      gender: fields[2] as String,
      phone: fields[3] as String,
      email: fields[4] as String,
      photoPath: fields[5] as String?,
      membershipStatus: fields[6] as String,
      planName: fields[7] as String,
      joiningDate: fields[8] as DateTime,
      expiryDate: fields[9] as DateTime,
      trainerAssigned: fields[10] as String?,
      dob: fields[11] as DateTime?,
      emergencyContact: fields[12] as String?,
      bloodGroup: fields[13] as String?,
      heightCm: fields[14] as double?,
      weightKg: fields[15] as double?,
      medicalConditions: fields[16] as String?,
      notes: fields[17] as String?,
      qrData: fields[18] as String?,
      assignedTrainerId: fields[19] as String?,
      currentSubscriptionId: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MemberModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.photoPath)
      ..writeByte(6)
      ..write(obj.membershipStatus)
      ..writeByte(7)
      ..write(obj.planName)
      ..writeByte(8)
      ..write(obj.joiningDate)
      ..writeByte(9)
      ..write(obj.expiryDate)
      ..writeByte(10)
      ..write(obj.trainerAssigned)
      ..writeByte(11)
      ..write(obj.dob)
      ..writeByte(12)
      ..write(obj.emergencyContact)
      ..writeByte(13)
      ..write(obj.bloodGroup)
      ..writeByte(14)
      ..write(obj.heightCm)
      ..writeByte(15)
      ..write(obj.weightKg)
      ..writeByte(16)
      ..write(obj.medicalConditions)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.qrData)
      ..writeByte(19)
      ..write(obj.assignedTrainerId)
      ..writeByte(20)
      ..write(obj.currentSubscriptionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
