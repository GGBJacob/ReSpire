import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Step.dart';

part 'Sounds.g.dart';

@HiveType(typeId: 9)
class Sounds {

  // === GLOBAL / TRAINING LEVEL ===

  /// Sound for counting during exercises
  @HiveField(1)
  SoundAsset countingSound = SoundAsset();

  /// Background sound for the entire training session
  @HiveField(2)
  SoundAsset globalBackgroundSound = SoundAsset(type: SoundType.melody);


  /// Scope of the next sound played between breathing phases.
  /// Used to determine the user's choice in the editor page.
  @HiveField(3)
  SoundScope nextSoundScope = SoundScope.global;
  /// Next sound played between breathing phases
  @HiveField(4)
  SoundAsset nextSound = SoundAsset();

  /// Preparation and ending tracks for the training session
  @HiveField(5)
  SoundAsset preparationTrack = SoundAsset(type: SoundType.melody);
  @HiveField(6)
  SoundAsset endingTrack = SoundAsset(type: SoundType.melody);

  /// Scope of the background audio during the training session
  @HiveField(7)
  SoundScope backgroundSoundScope = SoundScope.global;
  /// Background audio for the entire training session
  @HiveField(8)
  SoundAsset trainingBackgroundTrack = SoundAsset(type: SoundType.melody);

  // === STAGE LEVEL ===

  /// Stage tracks for different training stages
  /// 
  /// `key` - stage uuid, `value` - sound name
  @HiveField(9)
  Map<String, SoundAsset> stageTracks = {};

  // === BREATHING PHASE LEVEL ===

  /// Short sounds for each breathing phase type that indicate the transition
  @HiveField(10)
  Map<BreathingPhaseType, SoundAsset> breathingPhaseCues = {
    for (var type in BreathingPhaseType.values) type: SoundAsset(type: SoundType.cue)
  };

  
  /// Longer audio files for each breathing phase type
  @HiveField(11)
  Map<BreathingPhaseType, SoundAsset> breathingPhaseBackgrounds = {
    for (var type in BreathingPhaseType.values) type: SoundAsset(type: SoundType.melody)
  };


  void clearUserSound(String soundName) {
    if (countingSound.path == soundName) {
      countingSound.path = null;
    }
    if (globalBackgroundSound.path == soundName) {
      globalBackgroundSound.path = null;
    }
    if (nextSound.path == soundName) {
      nextSound.path = null;
    }
    if (preparationTrack.path == soundName) {
      preparationTrack.path = null;
    }
    if (endingTrack.path == soundName) {
      endingTrack.path = null;
    }
    if (trainingBackgroundTrack.path == soundName) {
      trainingBackgroundTrack.path = null;
    }

    for (var stage in stageTracks.keys) {
      if (stageTracks[stage]!.path == soundName) {
        stageTracks[stage]!.path = null;
      }
    }

    breathingPhaseCues.forEach((key, value) {
      if (value.path == soundName) {
        breathingPhaseCues[key]!.path = null;
      }
    });

    breathingPhaseBackgrounds.forEach((key, value) {
      if (value.path == soundName) {
        breathingPhaseBackgrounds[key]!.path = null;
      }
    });
  }
}
