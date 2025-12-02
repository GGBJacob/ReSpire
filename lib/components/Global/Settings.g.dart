// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 10;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings()
      ..preparationDuration = fields[0] as int
      ..endingDuration = fields[1] as int
      ..binauralBeatsEnabled = fields[2] as bool
      ..binauralLeftFrequency = fields[3] as double
      ..binauralRightFrequency = fields[4] as double;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.preparationDuration)
      ..writeByte(1)
      ..write(obj.endingDuration)
      ..writeByte(2)
      ..write(obj.binauralBeatsEnabled)
      ..writeByte(3)
      ..write(obj.binauralLeftFrequency)
      ..writeByte(4)
      ..write(obj.binauralRightFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
