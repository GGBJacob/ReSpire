// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PhaseSounds.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingPhaseSoundsAdapter extends TypeAdapter<BreathingPhaseSounds> {
  @override
  final int typeId = 9;

  @override
  BreathingPhaseSounds read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingPhaseSounds(
      preBreathingPhase: fields[0] as SoundAsset?,
      background: fields[1] as SoundAsset?,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingPhaseSounds obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.preBreathingPhase)
      ..writeByte(1)
      ..write(obj.background);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingPhaseSoundsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
