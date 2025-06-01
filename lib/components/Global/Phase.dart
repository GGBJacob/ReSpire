import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Step.dart';

part 'Phase.g.dart';

@HiveType(typeId: 2)
class Phase {
  
  @HiveField(0)
  int reps;
  
  @HiveField(1)
  List<Step> steps;

  Phase({
    required this.reps,
    required this.steps
  });

  void addStep(Step step)
  {
    steps.add(step);
  }
}