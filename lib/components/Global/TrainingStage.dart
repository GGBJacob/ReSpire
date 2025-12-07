import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/BreathingPhase.dart';
import 'package:uuid/uuid.dart';

part 'TrainingStage.g.dart';

@HiveType(typeId: 2)
class TrainingStage {
  
  @HiveField(0)
  String id = Uuid().v4();

  @HiveField(1)
  String name;

  @HiveField(2)
  int reps;

  @HiveField(3)
  double increment;
  
  @HiveField(4)
  List<BreathingPhase> breathingPhases;

  TrainingStage({
    required this.reps,
    required this.increment,
    required this.breathingPhases,
    this.name = '',
  });

  void addBreathingPhase(BreathingPhase breathingPhase)
  {
    breathingPhases.add(breathingPhase);
  }

  void propagateNextSound(SoundAsset nextSound) {
    // Set the next sound for each breathing phase
    for (var breathingPhase in breathingPhases) {
      breathingPhase.sounds.preBreathingPhase = nextSound;
    }
  }

  void propagateBackgroundSound(SoundAsset globalBackgroundSound) {  
    // Set the background sound for each breathing phase
    for (var breathingPhase in breathingPhases) {
      breathingPhase.sounds.background = globalBackgroundSound;
    }
  }
}