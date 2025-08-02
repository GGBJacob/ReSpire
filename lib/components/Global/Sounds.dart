import 'package:hive_flutter/hive_flutter.dart';

part 'Sounds.g.dart';

@HiveType(typeId: 9)
class Sounds {
  
  @HiveField(0)
  String backgroundSound = 'None';
  
  @HiveField(1)
  String nextSound = 'None';
  
  @HiveField(2)
  String inhaleSound = 'None';
  
  @HiveField(3)
  String retentionSound = 'None';
  
  @HiveField(4)
  String exhaleSound = 'None';
  
  @HiveField(5)
  String recoverySound = 'None';

  @HiveField(6)
  String preparationSound = 'None';

  @HiveField(7)
  String nextInhaleSound = 'None';

  @HiveField(8)
  String nextRetentionSound = 'None';

  @HiveField(9)
  String nextExhaleSound = 'None';

  @HiveField(10)
  String nextRecoverySound = 'None';

  @HiveField(11)
  String nextGlobalSound = 'None';
}