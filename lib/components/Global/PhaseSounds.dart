import 'package:hive_flutter/hive_flutter.dart';

part 'PhaseSounds.g.dart';

@HiveType(typeId: 11)
class PhaseSounds {
  
  @HiveField(0)
  String? prePhase;

  @HiveField(1)
  String? background;

  PhaseSounds({
    this.prePhase,
    this.background
  });
}