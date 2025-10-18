import 'package:hive/hive.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

part 'SoundScope.g.dart';

@HiveType(typeId: 15)
enum SoundScope {
  @HiveField(0)
  none,

  @HiveField(1)
  voice,

  @HiveField(2)
  global,

  @HiveField(3)
  perStage,

  @HiveField(4)
  perPhase,
}

extension SoundScopeX on SoundScope {
  String get name {
    switch (this) {
      case SoundScope.none:
        return TranslationProvider().getTranslation("SoundScope.none");
      case SoundScope.voice:
        return TranslationProvider().getTranslation("SoundScope.voice");
      case SoundScope.global:
        return TranslationProvider().getTranslation("SoundScope.global");
      case SoundScope.perStage:
        return TranslationProvider().getTranslation("SoundScope.perStage");
      case SoundScope.perPhase:
        return TranslationProvider().getTranslation("SoundScope.perPhase");
    }
  }

  static List<SoundScope> get nextPhaseScopeValues {
    return SoundScope.values.where((scope) => scope != SoundScope.perStage).toList();
  }

  static List<SoundScope> get backgroundScopeValues {
    return SoundScope.values.where((scope) => scope != SoundScope.perPhase).toList();
  }
}