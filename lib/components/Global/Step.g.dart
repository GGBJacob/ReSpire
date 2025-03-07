// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Step.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepAdapter extends TypeAdapter<Step> {
  @override
  final int typeId = 6;

  @override
  Step read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Step(
      duration: fields[0] as double,
      increment: fields[1] as StepIncrement?,
      stepType: fields[2] as StepType,
      breathType: fields[3] as BreathType?,
      breathDepth: fields[4] as BreathDepth?,
    );
  }

  @override
  void write(BinaryWriter writer, Step obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.increment)
      ..writeByte(2)
      ..write(obj.stepType)
      ..writeByte(3)
      ..write(obj.breathType)
      ..writeByte(4)
      ..write(obj.breathDepth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StepTypeAdapter extends TypeAdapter<StepType> {
  @override
  final int typeId = 3;

  @override
  StepType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StepType.inhale;
      case 1:
        return StepType.exhale;
      case 2:
        return StepType.retention;
      case 3:
        return StepType.recovery;
      default:
        return StepType.inhale;
    }
  }

  @override
  void write(BinaryWriter writer, StepType obj) {
    switch (obj) {
      case StepType.inhale:
        writer.writeByte(0);
        break;
      case StepType.exhale:
        writer.writeByte(1);
        break;
      case StepType.retention:
        writer.writeByte(2);
        break;
      case StepType.recovery:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepTypeAdapter &&
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
