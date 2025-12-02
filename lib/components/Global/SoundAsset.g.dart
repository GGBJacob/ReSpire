// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SoundAsset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundAssetAdapter extends TypeAdapter<SoundAsset> {
  @override
  final int typeId = 10;

  @override
  SoundAsset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoundAsset(
      path: fields[1] as String,
      type: fields[2] as SoundType,
    ).._name = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, SoundAsset obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundAssetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SoundTypeAdapter extends TypeAdapter<SoundType> {
  @override
  final int typeId = 11;

  @override
  SoundType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SoundType.voice;
      case 1:
        return SoundType.melody;
      case 2:
        return SoundType.cue;
      case 3:
        return SoundType.counting;
      case 4:
        return SoundType.none;
      default:
        return SoundType.voice;
    }
  }

  @override
  void write(BinaryWriter writer, SoundType obj) {
    switch (obj) {
      case SoundType.voice:
        writer.writeByte(0);
        break;
      case SoundType.melody:
        writer.writeByte(1);
        break;
      case SoundType.cue:
        writer.writeByte(2);
        break;
      case SoundType.counting:
        writer.writeByte(3);
        break;
      case SoundType.none:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
