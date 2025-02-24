// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PresetEntry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresetEntryAdapter extends TypeAdapter<PresetEntry> {
  @override
  final int typeId = 0;

  @override
  PresetEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresetEntry(
      title: fields[0] as String,
      description: fields[1] as String,
      breathCount: fields[2] as int,
      inhaleTime: fields[3] as int,
      exhaleTime: fields[4] as int,
      retentionTime: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PresetEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.breathCount)
      ..writeByte(3)
      ..write(obj.inhaleTime)
      ..writeByte(4)
      ..write(obj.exhaleTime)
      ..writeByte(5)
      ..write(obj.retentionTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresetEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
