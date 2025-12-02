import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/SoundAsset.dart';

part 'PhaseSounds.g.dart';

@HiveType(typeId: 9)
class BreathingPhaseSounds {
  @HiveField(0)
  SoundAsset preBreathingPhase;

  @HiveField(1)
  SoundAsset background;

  BreathingPhaseSounds({
    SoundAsset? preBreathingPhase,
    SoundAsset? background,
  })  : preBreathingPhase = preBreathingPhase ?? SoundAsset(),
        background = background ?? SoundAsset();
}