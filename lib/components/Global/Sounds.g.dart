// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Sounds.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundsAdapter extends TypeAdapter<Sounds> {
  @override
  final int typeId = 9;

  @override
  Sounds read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sounds()
      ..backgroundSound = fields[0] as String
      ..nextSound = fields[1] as String
      ..inhaleSound = fields[2] as String
      ..retentionSound = fields[3] as String
      ..exhaleSound = fields[4] as String
      ..recoverySound = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, Sounds obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.backgroundSound)
      ..writeByte(1)
      ..write(obj.nextSound)
      ..writeByte(2)
      ..write(obj.inhaleSound)
      ..writeByte(3)
      ..write(obj.retentionSound)
      ..writeByte(4)
      ..write(obj.exhaleSound)
      ..writeByte(5)
      ..write(obj.recoverySound);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
