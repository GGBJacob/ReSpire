// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BreathingPhaseIncrement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingPhaseIncrementAdapter
    extends TypeAdapter<BreathingPhaseIncrement> {
  @override
  final int typeId = 6;

  @override
  BreathingPhaseIncrement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingPhaseIncrement(
      value: fields[0] as double,
      type: fields[1] as BreathingPhaseIncrementType,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingPhaseIncrement obj) {
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
      other is BreathingPhaseIncrementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreathingPhaseIncrementTypeAdapter
    extends TypeAdapter<BreathingPhaseIncrementType> {
  @override
  final int typeId = 5;

  @override
  BreathingPhaseIncrementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BreathingPhaseIncrementType.percentage;
      case 1:
        return BreathingPhaseIncrementType.value;
      default:
        return BreathingPhaseIncrementType.percentage;
    }
  }

  @override
  void write(BinaryWriter writer, BreathingPhaseIncrementType obj) {
    switch (obj) {
      case BreathingPhaseIncrementType.percentage:
        writer.writeByte(0);
        break;
      case BreathingPhaseIncrementType.value:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingPhaseIncrementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
