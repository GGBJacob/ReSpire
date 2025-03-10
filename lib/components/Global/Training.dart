import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';

part 'Training.g.dart';

@HiveType(typeId: 1)
class Training {

  @HiveField(0)
  String title;
  
  @HiveField(1)
  List<Phase> phases;

  Training({
    required this.title,
    required this.phases
  });

  void prepareTraining()
  {
    // Reset the phases' rep count
    for(Phase phase in phases)
    {
      phase.resetProgression();
    }
  }
}