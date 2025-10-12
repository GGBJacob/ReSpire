// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TrainingSounds.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingSoundsAdapter extends TypeAdapter<TrainingSounds> {
  @override
  final int typeId = 12;

  @override
  TrainingSounds read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingSounds(
      preparation: fields[0] as String?,
      ending: fields[1] as String?,
      counting: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingSounds obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.preparation)
      ..writeByte(1)
      ..write(obj.ending)
      ..writeByte(2)
      ..write(obj.counting);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingSoundsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
