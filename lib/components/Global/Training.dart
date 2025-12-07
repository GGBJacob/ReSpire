import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/TrainingStage.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/BreathingPhase.dart';

part 'Training.g.dart';

@HiveType(typeId: 1)
class Training {

  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<TrainingStage> trainingStages;

  @HiveField(3)
  Sounds sounds = Sounds();

  @HiveField(4)
  Settings settings = Settings();

  Training({
    required this.title,
    required this.trainingStages,
    this.description = ''
  });

  int countEmptyStages() {
    int emptyStages = 0;
    for (TrainingStage stage in trainingStages) {
      if(stage.breathingPhases.isEmpty) {
        emptyStages += 1;
      }
    }
    return emptyStages;
  }

  void deleteEmptyStages() {
    trainingStages.removeWhere((stage) => stage.breathingPhases.isEmpty);
  }

  bool isEmpty() {
    if(trainingStages.isEmpty) {
      return true;
    }
    if(countEmptyStages() == trainingStages.length) {
      return true;
    }
    return false;
  }

  void updateSounds() {

    // Update next phase sounds
    switch (sounds.nextSoundScope) {
      case SoundScope.none:
      case SoundScope.perStage:
      case SoundScope.perEveryPhaseInEveryStage:
        break;

      case SoundScope.global:
        for (var stage in trainingStages) {
          stage.propagateNextSound(sounds.nextSound);
        }
        break; 

      case SoundScope.perPhase:
        for (int i=0; i<trainingStages.length; i++) {
          for (var phase in trainingStages[i].breathingPhases){
            switch(phase.breathingPhaseType) {
              case BreathingPhaseType.inhale:
                phase.sounds.preBreathingPhase = sounds.breathingPhaseCues[BreathingPhaseType.inhale]!;
                break;
              case BreathingPhaseType.retention:
                phase.sounds.preBreathingPhase = sounds.breathingPhaseCues[BreathingPhaseType.retention]!;
                break;
              case BreathingPhaseType.exhale:
                phase.sounds.preBreathingPhase = sounds.breathingPhaseCues[BreathingPhaseType.exhale]!;
                break;
              case BreathingPhaseType.recovery:
                phase.sounds.preBreathingPhase = sounds.breathingPhaseCues[BreathingPhaseType.recovery]!;
                break;
            }
          }
        }

        

        break; 

    }

    // Update background sounds
    switch (sounds.backgroundSoundScope) {
      // We handle playlists separately.
      case SoundScope.global:
      case SoundScope.perStage:
      case SoundScope.none:
        for (var stage in trainingStages) {
            stage.propagateBackgroundSound(SoundAsset(type: SoundType.none));
        }
        break;
      
      case SoundScope.perPhase:
        for (int i=0; i<trainingStages.length; i++) {
          for (var phase in trainingStages[i].breathingPhases){
            switch(phase.breathingPhaseType) {
              case BreathingPhaseType.inhale:
                phase.sounds.background = sounds.breathingPhaseBackgrounds[BreathingPhaseType.inhale]!;
                break;
              case BreathingPhaseType.retention:
                phase.sounds.background = sounds.breathingPhaseBackgrounds[BreathingPhaseType.retention]!;
                break;
              case BreathingPhaseType.exhale:
                phase.sounds.background = sounds.breathingPhaseBackgrounds[BreathingPhaseType.exhale]!;
                break;
              case BreathingPhaseType.recovery:
                phase.sounds.background = sounds.breathingPhaseBackgrounds[BreathingPhaseType.recovery]!;
                break;
            }
          }
        }
        break;
        
      case SoundScope.perEveryPhaseInEveryStage:
          for (int i=0; i<trainingStages.length; i++) {
            for (var phase in trainingStages[i].breathingPhases){
              switch(phase.breathingPhaseType) {
                case BreathingPhaseType.inhale:
                  phase.sounds.background = sounds.perEveryPhaseBreathingPhaseBackgrounds[trainingStages[i].id]?[BreathingPhaseType.inhale] ?? SoundAsset();
                  break;
                case BreathingPhaseType.retention:
                  phase.sounds.background = sounds.perEveryPhaseBreathingPhaseBackgrounds[trainingStages[i].id]?[BreathingPhaseType.retention] ?? SoundAsset();
                  break;
                case BreathingPhaseType.exhale:
                  phase.sounds.background = sounds.perEveryPhaseBreathingPhaseBackgrounds[trainingStages[i].id]?[BreathingPhaseType.exhale] ?? SoundAsset();
                  break;
                case BreathingPhaseType.recovery:
                  phase.sounds.background = sounds.perEveryPhaseBreathingPhaseBackgrounds[trainingStages[i].id]?[BreathingPhaseType.recovery] ?? SoundAsset();
                  break;
              }
            }
          }
          break;
    }
  }
}
