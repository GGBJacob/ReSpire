import 'package:hive_flutter/hive_flutter.dart';

part 'StepIncrement.g.dart';

@HiveType(typeId: 7)
enum IncrementType {
  @HiveField(0)
  percentage, 
  
  @HiveField(1)
  value
}

@HiveType(typeId: 8)
///In order to edit step incrementation, simply replace the old object with a new one
class StepIncrement {
  
  @HiveField(0)
  final double value;
  
  @HiveField(1)
  final IncrementType type;
  
  const StepIncrement({
    required this.value,
    required this.type
    }): assert(
      type != IncrementType.percentage || (value >= 0 && value <= 100),
      "Invalid StepIncrement: For percentage, value must be between 0 and 100."
      ),
      assert(
      type != IncrementType.value || value > 0,
      "Invalid StepIncrement: For value, it must be positive."
      );
}