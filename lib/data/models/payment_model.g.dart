// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 6;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      subscriptionId: fields[2] as String?,
      amount: fields[3] as double,
      method: fields[4] as String,
      paymentDate: fields[5] as DateTime,
      status: fields[6] as String,
      invoiceNumber: fields[7] as String,
      gstAmount: fields[8] as double,
      discountApplied: fields[9] as double,
      notes: fields[10] as String?,
      refundReason: fields[11] as String?,
      collectedByUserId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.subscriptionId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.method)
      ..writeByte(5)
      ..write(obj.paymentDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.invoiceNumber)
      ..writeByte(8)
      ..write(obj.gstAmount)
      ..writeByte(9)
      ..write(obj.discountApplied)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.refundReason)
      ..writeByte(12)
      ..write(obj.collectedByUserId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
