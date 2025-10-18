// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Phase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingStageAdapter extends TypeAdapter<TrainingStage> {
  @override
  final int typeId = 2;

  @override
  TrainingStage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingStage(
      reps: fields[2] as int,
      increment: fields[3] as int,
      breathingPhases: (fields[4] as List).cast<BreathingPhase>(),
      name: fields[1] as String,
    )..id = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, TrainingStage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.increment)
      ..writeByte(4)
      ..write(obj.breathingPhases);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingStageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
