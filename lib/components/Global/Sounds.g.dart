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
      ..countingSound = fields[1] as SoundAsset
      ..globalBackgroundSound = fields[2] as SoundAsset
      ..nextSoundScope = fields[3] as SoundScope
      ..nextSound = fields[4] as SoundAsset
      ..preparationTrack = fields[5] as SoundAsset
      ..endingTrack = fields[6] as SoundAsset
      ..backgroundSoundScope = fields[7] as SoundScope
      ..trainingBackgroundTrack = fields[8] as SoundAsset
      ..stageTracks = (fields[9] as Map).cast<String, SoundAsset>()
      ..breathingPhaseCues =
          (fields[10] as Map).cast<BreathingPhaseType, SoundAsset>()
      ..breathingPhaseBackgrounds =
          (fields[11] as Map).cast<BreathingPhaseType, SoundAsset>();
  }

  @override
  void write(BinaryWriter writer, Sounds obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.countingSound)
      ..writeByte(2)
      ..write(obj.globalBackgroundSound)
      ..writeByte(3)
      ..write(obj.nextSoundScope)
      ..writeByte(4)
      ..write(obj.nextSound)
      ..writeByte(5)
      ..write(obj.preparationTrack)
      ..writeByte(6)
      ..write(obj.endingTrack)
      ..writeByte(7)
      ..write(obj.backgroundSoundScope)
      ..writeByte(8)
      ..write(obj.trainingBackgroundTrack)
      ..writeByte(9)
      ..write(obj.stageTracks)
      ..writeByte(10)
      ..write(obj.breathingPhaseCues)
      ..writeByte(11)
      ..write(obj.breathingPhaseBackgrounds);
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
