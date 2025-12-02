// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Step.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingPhaseAdapter extends TypeAdapter<BreathingPhase> {
  @override
  final int typeId = 4;

  @override
  BreathingPhase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingPhase(
      duration: fields[0] as double,
      increment: fields[1] as BreathingPhaseIncrement?,
      breathingPhaseType: fields[2] as BreathingPhaseType,
      sounds: fields[3] as BreathingPhaseSounds?,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingPhase obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.increment)
      ..writeByte(2)
      ..write(obj.breathingPhaseType)
      ..writeByte(3)
      ..write(obj.sounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingPhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreathingPhaseTypeAdapter extends TypeAdapter<BreathingPhaseType> {
  @override
  final int typeId = 3;

  @override
  BreathingPhaseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BreathingPhaseType.inhale;
      case 1:
        return BreathingPhaseType.exhale;
      case 2:
        return BreathingPhaseType.retention;
      case 3:
        return BreathingPhaseType.recovery;
      default:
        return BreathingPhaseType.inhale;
    }
  }

  @override
  void write(BinaryWriter writer, BreathingPhaseType obj) {
    switch (obj) {
      case BreathingPhaseType.inhale:
        writer.writeByte(0);
        break;
      case BreathingPhaseType.exhale:
        writer.writeByte(1);
        break;
      case BreathingPhaseType.retention:
        writer.writeByte(2);
        break;
      case BreathingPhaseType.recovery:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingPhaseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
