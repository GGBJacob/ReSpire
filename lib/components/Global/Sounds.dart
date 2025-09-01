import 'package:hive_flutter/hive_flutter.dart';

part 'Sounds.g.dart';

@HiveType(typeId: 9)
class Sounds {
  
  @HiveField(0)
  String? backgroundSound;
  
  @HiveField(1)
  String? nextSound;
  
  @HiveField(2)
  String? inhaleSound;
  
  @HiveField(3)
  String? retentionSound;
  
  @HiveField(4)
  String? exhaleSound;
  
  @HiveField(5)
  String? recoverySound;

  @HiveField(6)
  String? preparationSound;

  @HiveField(7)
  String? nextInhaleSound;

  @HiveField(8)
  String? nextRetentionSound;

  @HiveField(9)
  String? nextExhaleSound;

  @HiveField(10)
  String? nextRecoverySound;

  @HiveField(11)
  String? nextGlobalSound;

  @HiveField(12)
  String? nextVoiceover;

  @HiveField(13)
  String? countingSound;
}