// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StepIncrement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepIncrementAdapter extends TypeAdapter<StepIncrement> {
  @override
  final int typeId = 8;

  @override
  StepIncrement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepIncrement(
      value: fields[0] as double,
      type: fields[1] as IncrementType,
    );
  }

  @override
  void write(BinaryWriter writer, StepIncrement obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepIncrementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncrementTypeAdapter extends TypeAdapter<IncrementType> {
  @override
  final int typeId = 7;

  @override
  IncrementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncrementType.percentage;
      case 1:
        return IncrementType.value;
      default:
        return IncrementType.percentage;
    }
  }

  @override
  void write(BinaryWriter writer, IncrementType obj) {
    switch (obj) {
      case IncrementType.percentage:
        writer.writeByte(0);
        break;
      case IncrementType.value:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncrementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
