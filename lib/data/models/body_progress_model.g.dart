// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written to mirror the build_runner output for BodyProgressModel.
// To regenerate, run:
//   dart run build_runner build --delete-conflicting-outputs
//
// Field map:
//   0  -> id (String)
//   1  -> memberId (String)
//   2  -> loggedByTrainerId (String?)
//   3  -> date (DateTime)
//   4  -> weightKg (double)
//   5  -> heightCm (double)
//   6  -> bodyFatPercent (double?)
//   7  -> muscleMassKg (double?)
//   8  -> chestCm (double?)
//   9  -> waistCm (double?)
//   10 -> hipCm (double?)
//   11 -> shoulderCm (double?)
//   12 -> armCm (double?)
//   13 -> thighCm (double?)
//   14 -> calfCm (double?)
//   15 -> neckCm (double?)
//   16 -> frontPhotoPath (String?)
//   17 -> sidePhotoPath (String?)
//   18 -> backPhotoPath (String?)
//   19 -> notes (String?)
//   20 -> goalId (String?)                  [new]
//   21 -> autoApplyToGoals (bool)           [new]
//   22 -> waterLitres (double?)             [new]
// numOfFields: 23

part of 'body_progress_model.dart';

class BodyProgressModelAdapter extends TypeAdapter<BodyProgressModel> {
  @override
  final int typeId = 14;

  @override
  BodyProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyProgressModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      loggedByTrainerId: fields[2] as String?,
      date: fields[3] as DateTime,
      weightKg: (fields[4] as num).toDouble(),
      heightCm: (fields[5] as num).toDouble(),
      bodyFatPercent: (fields[6] as num?)?.toDouble(),
      muscleMassKg: (fields[7] as num?)?.toDouble(),
      chestCm: (fields[8] as num?)?.toDouble(),
      waistCm: (fields[9] as num?)?.toDouble(),
      hipCm: (fields[10] as num?)?.toDouble(),
      shoulderCm: (fields[11] as num?)?.toDouble(),
      armCm: (fields[12] as num?)?.toDouble(),
      thighCm: (fields[13] as num?)?.toDouble(),
      calfCm: (fields[14] as num?)?.toDouble(),
      neckCm: (fields[15] as num?)?.toDouble(),
      frontPhotoPath: fields[16] as String?,
      sidePhotoPath: fields[17] as String?,
      backPhotoPath: fields[18] as String?,
      notes: fields[19] as String?,
      goalId: fields[20] as String?,
      autoApplyToGoals: (fields[21] as bool?) ?? false,
      waterLitres: (fields[22] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, BodyProgressModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.loggedByTrainerId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.weightKg)
      ..writeByte(5)
      ..write(obj.heightCm)
      ..writeByte(6)
      ..write(obj.bodyFatPercent)
      ..writeByte(7)
      ..write(obj.muscleMassKg)
      ..writeByte(8)
      ..write(obj.chestCm)
      ..writeByte(9)
      ..write(obj.waistCm)
      ..writeByte(10)
      ..write(obj.hipCm)
      ..writeByte(11)
      ..write(obj.shoulderCm)
      ..writeByte(12)
      ..write(obj.armCm)
      ..writeByte(13)
      ..write(obj.thighCm)
      ..writeByte(14)
      ..write(obj.calfCm)
      ..writeByte(15)
      ..write(obj.neckCm)
      ..writeByte(16)
      ..write(obj.frontPhotoPath)
      ..writeByte(17)
      ..write(obj.sidePhotoPath)
      ..writeByte(18)
      ..write(obj.backPhotoPath)
      ..writeByte(19)
      ..write(obj.notes)
      ..writeByte(20)
      ..write(obj.goalId)
      ..writeByte(21)
      ..write(obj.autoApplyToGoals)
      ..writeByte(22)
      ..write(obj.waterLitres);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}