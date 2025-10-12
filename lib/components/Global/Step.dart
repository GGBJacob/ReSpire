import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/PhaseSounds.dart';
import 'package:respire/components/Global/StepIncrement.dart';

part 'Step.g.dart';

@HiveType(typeId: 3)
enum StepType { 
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
enum BreathType { 
  @HiveField(0)
  diaphragmatic, 
  
  @HiveField(1)
  thoracic, 
  
  @HiveField(2)
  clavicular, 
  
  @HiveField(3)
  costal, 
  
  @HiveField(4)
  paradoxical 
}

@HiveType(typeId: 5)
enum BreathDepth { 
  @HiveField(0)
  deep,

  @HiveField(1)
  normal,

  @HiveField(2)
  shallow 
}


@HiveType(typeId: 6)
class Step {
  
  @HiveField(0)
  final double duration; // in seconds
  
  @HiveField(1)
  StepIncrement? increment;
  
  @HiveField(2)
  StepType stepType;
  
  @HiveField(3)
  BreathType? breathType;
  
  @HiveField(4)
  BreathDepth? breathDepth;

  @HiveField(5)
  PhaseSounds sounds = PhaseSounds();

  Step({
    required this.duration,
    this.increment,
    this.stepType = StepType.inhale,
    this.breathType,
    this.breathDepth,
    PhaseSounds? sounds,
    });

    ///Calculate the Step's duration in `rep` repetition. The returned value is in seconds.
    double getStepDuration(int rep)
    {
      if (increment == null || increment!.value == 0 || rep == 0)
      {
        return duration;
      }

      
      switch(increment!.type)
      {
        case IncrementType.percentage:
        {
           return duration * (1 + (increment!.value / 100) * rep);
        }

        case IncrementType.value:
        {
          return duration + (rep*increment!.value);
        }
      }
    }
}