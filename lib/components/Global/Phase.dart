import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Step.dart';

part 'Phase.g.dart';

@HiveType(typeId: 2)
class Phase {
  
  @HiveField(0)
  String name;

  @HiveField(1)
  int reps;

  @HiveField(2)
  int increment;
  
  @HiveField(3)
  List<Step> steps;

  @HiveField(4)
  String? phaseBackgroundSound;

  Phase({
    required this.reps,
    required this.increment, // Value in seconds 
    required this.steps,
    this.name = "Phase", //Default name
  });

  void addStep(Step step)
  {
    steps.add(step);
  }

  void propabateBackgroundSound(String? globalBackgroundSound) {
    // Replace the phase background sound with the global one if it exists
    if (globalBackgroundSound != null) {
      phaseBackgroundSound = globalBackgroundSound;
    }

    // Set the background sound for each step in the phase
    for (var step in steps) {
      step.sounds.background = phaseBackgroundSound;
    }
  }
}