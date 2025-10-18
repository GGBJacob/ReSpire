// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Training.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingAdapter extends TypeAdapter<Training> {
  @override
  final int typeId = 1;

  @override
  Training read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Training(
      title: fields[0] as String,
      trainingStages: (fields[2] as List).cast<TrainingStage>(),
      description: fields[1] as String,
    )
      ..sounds = fields[3] as Sounds
      ..settings = fields[4] as Settings;
  }

  @override
  void write(BinaryWriter writer, Training obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.trainingStages)
      ..writeByte(3)
      ..write(obj.sounds)
      ..writeByte(4)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
