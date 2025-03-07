import 'package:hive/hive.dart';

part 'PresetEntry.g.dart';

@HiveType(typeId: 0)
class PresetEntry extends HiveObject
{
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int breathCount;

  @HiveField(3)
  final int inhaleTime;

  @HiveField(4)
  final int exhaleTime;

  @HiveField(5)
  final int retentionTime;

  PresetEntry({
    required this.title,
    required this.description,
    required this.breathCount,
    required this.inhaleTime,
    required this.exhaleTime,
    required this.retentionTime
  });
}