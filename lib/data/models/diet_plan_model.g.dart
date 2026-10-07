// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DietPlanModelAdapter extends TypeAdapter<DietPlanModel> {
  @override
  final int typeId = 8;

  @override
  DietPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DietPlanModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      createdByTrainerId: fields[2] as String,
      category: fields[3] as String,
      meals: (fields[4] as List).cast<MealModel>(),
      dailyCalorieTarget: fields[5] as double,
      dailyProteinTarget: fields[6] as double,
      dailyWaterTargetMl: fields[7] as int,
      startDate: fields[8] as DateTime?,
      endDate: fields[9] as DateTime?,
      isActive: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DietPlanModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.createdByTrainerId)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.meals)
      ..writeByte(5)
      ..write(obj.dailyCalorieTarget)
      ..writeByte(6)
      ..write(obj.dailyProteinTarget)
      ..writeByte(7)
      ..write(obj.dailyWaterTargetMl)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
