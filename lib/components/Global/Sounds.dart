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
}