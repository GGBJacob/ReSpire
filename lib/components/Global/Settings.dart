import 'package:hive_flutter/hive_flutter.dart';

part 'Settings.g.dart';

@HiveType(typeId: 10)
class Settings {
  
  @HiveField(0)
  int preparationDuration = 3; //in seconds
  
  @HiveField(1)
  int endingDuration = 5; //in seconds

  @HiveField(2)
  bool binauralBeatsEnabled = false;
  
  @HiveField(3)
  double binauralLeftFrequency = 200.0; // Hz
  
  @HiveField(4)
  double binauralRightFrequency = 210.0; // Hz (10 Hz beat frequency)
  
}