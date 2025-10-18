// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Step.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingPhaseAdapter extends TypeAdapter<BreathingPhase> {
  @override
  final int typeId = 6;

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
      breathType: fields[3] as BreathType?,
      breathDepth: fields[4] as BreathDepth?,
      sounds: fields[5] as BreathingPhaseSounds?,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingPhase obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.increment)
      ..writeByte(2)
      ..write(obj.breathingPhaseType)
      ..writeByte(3)
      ..write(obj.breathType)
      ..writeByte(4)
      ..write(obj.breathDepth)
      ..writeByte(5)
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

class BreathTypeAdapter extends TypeAdapter<BreathType> {
  @override
  final int typeId = 4;

  @override
  BreathType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BreathType.diaphragmatic;
      case 1:
        return BreathType.thoracic;
      case 2:
        return BreathType.clavicular;
      case 3:
        return BreathType.costal;
      case 4:
        return BreathType.paradoxical;
      default:
        return BreathType.diaphragmatic;
    }
  }

  @override
  void write(BinaryWriter writer, BreathType obj) {
    switch (obj) {
      case BreathType.diaphragmatic:
        writer.writeByte(0);
        break;
      case BreathType.thoracic:
        writer.writeByte(1);
        break;
      case BreathType.clavicular:
        writer.writeByte(2);
        break;
      case BreathType.costal:
        writer.writeByte(3);
        break;
      case BreathType.paradoxical:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreathDepthAdapter extends TypeAdapter<BreathDepth> {
  @override
  final int typeId = 5;

  @override
  BreathDepth read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BreathDepth.deep;
      case 1:
        return BreathDepth.normal;
      case 2:
        return BreathDepth.shallow;
      default:
        return BreathDepth.deep;
    }
  }

  @override
  void write(BinaryWriter writer, BreathDepth obj) {
    switch (obj) {
      case BreathDepth.deep:
        writer.writeByte(0);
        break;
      case BreathDepth.normal:
        writer.writeByte(1);
        break;
      case BreathDepth.shallow:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathDepthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
