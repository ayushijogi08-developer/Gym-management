// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealModelAdapter extends TypeAdapter<MealModel> {
  @override
  final int typeId = 7;

  @override
  MealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealModel(
      mealType: fields[0] as String,
      mealName: fields[1] as String,
      foodItems: (fields[2] as List).cast<String>(),
      quantity: fields[3] as String,
      calories: fields[4] as double,
      protein: fields[5] as double,
      carbs: fields[6] as double,
      fats: fields[7] as double,
      fiber: fields[8] as double,
      sugar: fields[9] as double,
      waterIntakeMl: fields[10] as int?,
      instructions: fields[11] as String?,
      notes: fields[12] as String?,
      imagePath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.mealType)
      ..writeByte(1)
      ..write(obj.mealName)
      ..writeByte(2)
      ..write(obj.foodItems)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.protein)
      ..writeByte(6)
      ..write(obj.carbs)
      ..writeByte(7)
      ..write(obj.fats)
      ..writeByte(8)
      ..write(obj.fiber)
      ..writeByte(9)
      ..write(obj.sugar)
      ..writeByte(10)
      ..write(obj.waterIntakeMl)
      ..writeByte(11)
      ..write(obj.instructions)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
