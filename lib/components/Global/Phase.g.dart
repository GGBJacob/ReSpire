// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Phase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhaseAdapter extends TypeAdapter<Phase> {
  @override
  final int typeId = 2;

  @override
  Phase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phase(
      reps: fields[1] as int,
      increment: fields[2] as int,
      steps: (fields[3] as List).cast<Step>(),
      name: fields[0] as String ? ?? '',
    )..phaseBackgroundSound = fields[4] as String?;
  }

  @override
  void write(BinaryWriter writer, Phase obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.increment)
      ..writeByte(3)
      ..write(obj.steps)
      ..writeByte(4)
      ..write(obj.phaseBackgroundSound);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
