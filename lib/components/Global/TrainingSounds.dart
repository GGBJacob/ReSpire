import 'package:hive_flutter/hive_flutter.dart';

part 'TrainingSounds.g.dart';

@HiveType(typeId: 12)
class TrainingSounds {
  
  @HiveField(0)
  String? preparation;

  @HiveField(1)
  String? ending;

  @HiveField(2)
  String? counting;

  TrainingSounds({
    this.preparation,
    this.ending,
    this.counting
  });
}