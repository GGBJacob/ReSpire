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
}