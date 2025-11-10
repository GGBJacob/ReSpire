import 'package:hive/hive.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

part 'SoundAsset.g.dart';

@HiveType(typeId: 13)
class SoundAsset {
  @HiveField(0)
  String _name;

  @HiveField(1)
  String path;

  @HiveField(2)
  SoundType type;

  SoundAsset({
    String name = '',
    this.path = '',
    this.type = SoundType.none,
  }) : _name = name;

  String get name {
    if (type == SoundType.none) {
      return TranslationProvider().getTranslation("TrainingEditorPage.SoundsTab.None");
    } else if (type == SoundType.voice) {
      return TranslationProvider().getTranslation("TrainingEditorPage.SoundsTab.Voice");
    }
    return _name;
  }

  set name(String value) {
    _name = value;
  }

  @override
  String toString() {
    return 'SoundAsset{name: $name, path: $path, type: $type}';
  }
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
  counting,

  @HiveField(4)
  none,
}