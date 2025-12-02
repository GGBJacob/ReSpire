import 'package:hive_flutter/hive_flutter.dart';

part 'StepIncrement.g.dart';

@HiveType(typeId: 5)
enum BreathingPhaseIncrementType {
  @HiveField(0)
  percentage, 
  
  @HiveField(1)
  value
}

@HiveType(typeId: 6)
///In order to edit breathing phase incrementation, simply replace the old object with a new one
class BreathingPhaseIncrement {
  
  @HiveField(0)
  final double value;
  
  @HiveField(1)
  final BreathingPhaseIncrementType type;

  const BreathingPhaseIncrement({
    required this.value,
    required this.type
    }): assert(
      type != BreathingPhaseIncrementType.percentage || (value >= 0 && value <= 100),
      "Invalid BreathingPhaseIncrement: For percentage, value must be between 0 and 100."
      ),
      assert(
      type != BreathingPhaseIncrementType.value || value > 0,
      "Invalid BreathingPhaseIncrement: For value, it must be positive."
      );
}