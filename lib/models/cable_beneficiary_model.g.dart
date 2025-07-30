// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cable_beneficiary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CableBeneficiaryModelAdapter extends TypeAdapter<CableBeneficiaryModel> {
  @override
  final int typeId = 0;

  @override
  CableBeneficiaryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CableBeneficiaryModel(
      smartCardNumber: fields[0] as String,
      beneficiaryName: fields[1] as String,
      status: fields[2] as String,
      providerName: fields[3] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CableBeneficiaryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.smartCardNumber)
      ..writeByte(1)
      ..write(obj.beneficiaryName)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.providerName)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CableBeneficiaryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
