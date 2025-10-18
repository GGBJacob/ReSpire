import 'package:hive/hive.dart';

part 'SoundAsset.g.dart';

@HiveType(typeId: 13)
class SoundAsset {
  @HiveField(1)
  String? path;

  @HiveField(2)
  SoundType? type;

  SoundAsset({this.path, this.type = SoundType.none});
}

@HiveType(typeId: 14)
enum SoundType {
  @HiveField(0)
  voice,

  @HiveField(1)
  melody,

  @HiveField(2)
  cue,

  @HiveField(3)
  none,
}