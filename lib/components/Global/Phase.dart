import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Step.dart';

part 'Phase.g.dart';

@HiveType(typeId: 2)
class TrainingStage {
  
  @HiveField(0)
  String name;

  @HiveField(1)
  int reps;

  @HiveField(2)
  int increment;
  
  @HiveField(3)
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

  void propagateNextSound(String? nextSound) {
    // Set the next sound for each breathing phase
    for (var breathingPhase in breathingPhases) {
      breathingPhase.sounds.preBreathingPhase = nextSound;
    }
  }

  void propagateBackgroundSound(String? globalBackgroundSound) {  
    // Set the background sound for each breathing phase
    for (var breathingPhase in breathingPhases) {
      breathingPhase.sounds.background = globalBackgroundSound;
    }
  }
}