import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Sounds.dart';

part 'Training.g.dart';

@HiveType(typeId: 1)
class Training {

  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  List<Phase> phases;

  @HiveField(3)
  Sounds sounds = Sounds();

  Training({
    required this.title,
    required this.phases
  });

}