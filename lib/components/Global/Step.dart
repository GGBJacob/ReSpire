import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/PhaseSounds.dart';
import 'package:respire/components/Global/StepIncrement.dart';

part 'Step.g.dart';

@HiveType(typeId: 3)
enum BreathingPhaseType { 
  @HiveField(0)
  inhale, 
  
  @HiveField(1)
  exhale, 

  @HiveField(2)
  retention, 

  @HiveField(3)
  recovery 
}

@HiveType(typeId: 4)
class BreathingPhase {
  
  @HiveField(0)
  final double duration; // in seconds
  
  @HiveField(1)
  BreathingPhaseIncrement? increment;
  
  @HiveField(2)
  BreathingPhaseType breathingPhaseType;

  @HiveField(3)
  BreathingPhaseSounds sounds = BreathingPhaseSounds();

  BreathingPhase({
    required this.duration,
    this.increment,
    this.breathingPhaseType = BreathingPhaseType.inhale,
    BreathingPhaseSounds? sounds,
    }){
      this.sounds = sounds ?? BreathingPhaseSounds();
    }

    ///Calculate the BreathingPhase's duration in `rep` repetition. The returned value is in seconds.
    double getBreathingPhaseDuration(int rep)
    {
      if (increment == null || increment!.value == 0 || rep == 0)
      {
        return duration;
      }

      
      switch(increment!.type)
      {
        case BreathingPhaseIncrementType.percentage:
        {
           return duration * (1 + (increment!.value / 100) * rep);
        }

        case BreathingPhaseIncrementType.value:
        {
          return duration + (rep*increment!.value);
        }
      }
    }
}