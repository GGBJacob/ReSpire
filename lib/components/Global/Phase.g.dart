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
      reps: fields[0] as int,
      steps: (fields[2] as List).cast<Step>(),
    )..doneRepsCounter = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, Phase obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.reps)
      ..writeByte(1)
      ..write(obj.doneRepsCounter)
      ..writeByte(2)
      ..write(obj.steps);
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
