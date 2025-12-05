import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';

part 'Sounds.g.dart';

@HiveType(typeId: 9)
class Sounds {

  // === GLOBAL / TRAINING LEVEL ===

  /// Sound for counting during exercises
  @HiveField(1)
  SoundAsset countingSound = SoundManager.countingSounds["Metronome"]!;

  /// Scope of the next sound played between breathing phases.
  /// Used to determine the user's choice in the editor page.
  @HiveField(2)
  SoundScope nextSoundScope = SoundScope.global;
  /// Next sound played between breathing phases
  @HiveField(3)
  SoundAsset nextSound = SoundManager.shortSounds["Snap"]!;

  /// Preparation and ending tracks for the training session
  @HiveField(4)
  SoundAsset preparationTrack = SoundManager.longSounds["Rain"]!;
  @HiveField(5)
  SoundAsset endingTrack = SoundManager.longSounds["Ocean"]!;

  /// Scope of the background audio during the training session
  @HiveField(6)
  SoundScope backgroundSoundScope = SoundScope.global;
  /// Background audio playlist for the entire training session
  @HiveField(7)
  List<SoundAsset> trainingBackgroundPlaylist = [];

  // === STAGE LEVEL ===

  /// Stage playlists for different training stages
  /// 
  /// `key` - stage uuid, `value` - list of sound assets
  @HiveField(8)
  Map<String, List<SoundAsset>> stagePlaylists = {};

  // === BREATHING PHASE LEVEL ===

  /// Short sounds for each breathing phase type that indicate the transition
  @HiveField(9)
  Map<BreathingPhaseType, SoundAsset> breathingPhaseCues = {
    for (var type in BreathingPhaseType.values) type: SoundAsset()
  };

  
  /// Longer audio files for each breathing phase type
  @HiveField(10)
  Map<BreathingPhaseType, SoundAsset> breathingPhaseBackgrounds = {
    for (var type in BreathingPhaseType.values) type: SoundAsset()
  };

  /// Sound played between stages
  @HiveField(11)
  SoundAsset stageChangeSound = SoundManager.shortSounds["Bell"]!;

  void clearUserSound(String soundName) {
    if (countingSound.name == soundName) {
      countingSound = SoundAsset();
    }
    if (nextSound.name == soundName) {
      nextSound = SoundAsset();
    }
    if (preparationTrack.name == soundName) {
      preparationTrack = SoundAsset();
    }
    if (endingTrack.name == soundName) {
      endingTrack = SoundAsset();
    }
    trainingBackgroundPlaylist.removeWhere((sound) => sound.name == soundName);

    for (var stage in stagePlaylists.keys) {
      stagePlaylists[stage]!.removeWhere((sound) => sound.name == soundName);
    }

    breathingPhaseCues.forEach((key, value) {
      if (value.name == soundName) {
        breathingPhaseCues[key]= SoundAsset();
      }
    });

    breathingPhaseBackgrounds.forEach((key, value) {
      if (value.name == soundName) {
        breathingPhaseBackgrounds[key]= SoundAsset();
      }
    });
  }
}
