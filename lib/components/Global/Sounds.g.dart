// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Sounds.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundsAdapter extends TypeAdapter<Sounds> {
  @override
  final int typeId = 7;

  @override
  Sounds read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sounds()
      ..countingSound = fields[1] as SoundAsset
      ..nextSoundScope = fields[2] as SoundScope
      ..nextSound = fields[3] as SoundAsset
      ..preparationTrack = fields[4] as SoundAsset
      ..endingTrack = fields[5] as SoundAsset
      ..backgroundSoundScope = fields[6] as SoundScope
      ..trainingBackgroundPlaylist = (fields[7] as List).cast<SoundAsset>()
      ..stagePlaylists = (fields[8] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<SoundAsset>()))
      ..breathingPhaseCues =
          (fields[9] as Map).cast<BreathingPhaseType, SoundAsset>()
      ..breathingPhaseBackgrounds =
          (fields[10] as Map).cast<BreathingPhaseType, SoundAsset>()
      ..perEveryPhaseBreathingPhaseBackgrounds = (fields[11] as Map).map(
          (dynamic k, dynamic v) => MapEntry(
              k as String, (v as Map).cast<BreathingPhaseType, SoundAsset>()))
      ..stageChangeSound = fields[12] as SoundAsset
      ..cycleChangeSound = fields[13] as SoundAsset;
  }

  @override
  void write(BinaryWriter writer, Sounds obj) {
    writer
      ..writeByte(13)
      ..writeByte(1)
      ..write(obj.countingSound)
      ..writeByte(2)
      ..write(obj.nextSoundScope)
      ..writeByte(3)
      ..write(obj.nextSound)
      ..writeByte(4)
      ..write(obj.preparationTrack)
      ..writeByte(5)
      ..write(obj.endingTrack)
      ..writeByte(6)
      ..write(obj.backgroundSoundScope)
      ..writeByte(7)
      ..write(obj.trainingBackgroundPlaylist)
      ..writeByte(8)
      ..write(obj.stagePlaylists)
      ..writeByte(9)
      ..write(obj.breathingPhaseCues)
      ..writeByte(10)
      ..write(obj.breathingPhaseBackgrounds)
      ..writeByte(11)
      ..write(obj.perEveryPhaseBreathingPhaseBackgrounds)
      ..writeByte(12)
      ..write(obj.stageChangeSound)
      ..writeByte(13)
      ..write(obj.cycleChangeSound);
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
