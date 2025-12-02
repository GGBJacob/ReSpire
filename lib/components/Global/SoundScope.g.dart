// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SoundScope.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundScopeAdapter extends TypeAdapter<SoundScope> {
  @override
  final int typeId = 12;

  @override
  SoundScope read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SoundScope.none;
      case 1:
        return SoundScope.global;
      case 2:
        return SoundScope.perStage;
      case 3:
        return SoundScope.perPhase;
      default:
        return SoundScope.none;
    }
  }

  @override
  void write(BinaryWriter writer, SoundScope obj) {
    switch (obj) {
      case SoundScope.none:
        writer.writeByte(0);
        break;
      case SoundScope.global:
        writer.writeByte(1);
        break;
      case SoundScope.perStage:
        writer.writeByte(2);
        break;
      case SoundScope.perPhase:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundScopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
