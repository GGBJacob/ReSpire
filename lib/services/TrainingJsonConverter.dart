import 'dart:convert';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/TrainingStage.dart';
import 'package:respire/components/Global/BreathingPhase.dart';
import 'package:respire/components/Global/BreathingPhaseIncrement.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:uuid/uuid.dart';

class TrainingJsonConverter {

  static final Map<String, String> _stageUuidMap = {};

  static String toJson(Training training) {
    return JsonEncoder.withIndent('  ').convert(_trainingToMap(training));
  }

  static String toJsonMultiple(List<Training> trainings) {
    final payload = {
      'trainings': trainings.map(_trainingToMap).toList(),
    };

    return JsonEncoder.withIndent('  ').convert(payload);
  }

  static Training fromJson(String jsonString) {
    final trainings = fromJsonMultiple(jsonString);
    if (trainings.isEmpty) {
      throw FormatException('No training data found in JSON payload.');
    }
    return trainings.first;
  }

  static List<Training> fromJsonMultiple(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is List) {
      return decoded.map((item) => _trainingFromMap(_ensureMap(item))).toList();
    }

    if (decoded is Map) {
      final map = _ensureMap(decoded);

      if (map.containsKey('trainings') && map['trainings'] is List) {
        final List<dynamic> trainingsList = map['trainings'] as List<dynamic>;
        return trainingsList.map((item) => _trainingFromMap(_ensureMap(item))).toList();
      }

      return [_trainingFromMap(map)];
    }

    throw FormatException('Unsupported JSON format for trainings.');
  }

  static Map<String, dynamic> _trainingToMap(Training training) {
    _stageUuidMap.clear();
    return {
      'title': training.title,
      'description': training.description,
      'trainingStages': training.trainingStages.map(_stageToJson).toList(),
      'settings': _settingsToJson(training.settings),
      'sounds': _soundsToJson(training.sounds)
    };
  }

  static Training _trainingFromMap(Map<String, dynamic> json) {
    final stages = (json['trainingStages'] as List?) ?? [];

    return Training(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      trainingStages: stages
          .map((stage) => _stageFromJson(_ensureMap(stage)))
          .toList(),
    )..settings = _settingsFromJson(json['settings'] ?? {})..sounds = _soundsFromJson(json['sounds'] ?? {});
  }

  static Map<String, dynamic> _ensureMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('Expected JSON object but found ${value.runtimeType}.');
  }

  static Map<String, dynamic> _stageToJson(TrainingStage stage) {
    final uuid = _stageUuidMap[stage.id] ??= const Uuid().v4();
    return {
      'id': uuid,
      'name': stage.name,
      'reps': stage.reps,
      'increment': stage.increment,
      'breathingPhases': stage.breathingPhases
          .map((phase) => _phaseToJson(phase))
          .toList(),
    };
  }
  
  static TrainingStage _stageFromJson(Map<String, dynamic> json) {
    final phases = (json['breathingPhases'] as List?) ?? [];
    return TrainingStage(
      reps: json['reps'] ?? 1,
      increment: json['increment'] ?? 0,
      name: json['name'] ?? '',
      breathingPhases: phases
          .map((phase) => _phaseFromJson(_ensureMap(phase)))
          .toList(),
    )..id = json['id'] ?? Uuid().v4();
  }
  
  static Map<String, dynamic> _phaseToJson(BreathingPhase phase) {
    return {
      'duration': phase.duration,
      'breathingPhaseType': phase.breathingPhaseType.name,
      'increment': phase.increment != null
          ? {
              'value': phase.increment!.value,
              'type': phase.increment!.type.name,
            }
          : null,
    };
  }
  
  static BreathingPhase _phaseFromJson(Map<String, dynamic> json) {
    return BreathingPhase(
      duration: (json['duration'] ?? 0).toDouble(),
      breathingPhaseType: _parseBreathingPhaseType(json['breathingPhaseType']),
      increment: json['increment'] != null
          ? BreathingPhaseIncrement(
              value: (json['increment']['value'] ?? 0).toDouble(),
              type: _parseIncrementType(json['increment']['type']),
            )
          : null,
    );
  }
  
  static Map<String, dynamic> _settingsToJson(Settings settings) {
    return {
      'preparationDuration': settings.preparationDuration,
      'endingDuration': settings.endingDuration,
      'binauralBeatsEnabled': settings.binauralBeatsEnabled,
      'binauralLeftFrequency': settings.binauralLeftFrequency,
      'binauralRightFrequency': settings.binauralRightFrequency,
    };
  }
  
  static Settings _settingsFromJson(Map<String, dynamic> json) {
    return Settings()
      ..preparationDuration = json['preparationDuration'] ?? 3
      ..endingDuration = json['endingDuration'] ?? false
      ..binauralBeatsEnabled = json['binauralBeatsEnabled'] ?? false
      ..binauralLeftFrequency = (json['binauralLeftFrequency'] ?? 200.0).toDouble()
      ..binauralRightFrequency = (json['binauralRightFrequency'] ?? 210.0).toDouble();
  }
    
  static BreathingPhaseType _parseBreathingPhaseType(String? value) {
    switch (value?.toLowerCase()) {
      case 'inhale':
        return BreathingPhaseType.inhale;
      case 'exhale':
        return BreathingPhaseType.exhale;
      case 'retention':
        return BreathingPhaseType.retention;
      case 'recovery':
        return BreathingPhaseType.recovery;
      default:
        return BreathingPhaseType.inhale;
    }
  }
  
  static BreathingPhaseIncrementType _parseIncrementType(String? value) {
    switch (value?.toLowerCase()) {
      case 'percentage':
        return BreathingPhaseIncrementType.percentage;
      case 'value':
        return BreathingPhaseIncrementType.value;
      default:
        return BreathingPhaseIncrementType.value;
    }
  }

  static String _changeSoundToString(SoundAsset sound) {
    if (sound.type == SoundType.voice) {
      return "voice";
    }
    return SoundManager().isUserMusic(sound.name) ? "" : sound.name;
  }

  static String _changeScopeToString(SoundScope scope) {
    switch (scope) {
      case SoundScope.none:
        return "none";
      case SoundScope.global:
        return "global";
      case SoundScope.perStage:
        return "perStage";
      case SoundScope.perPhase:
        return "perPhase";
      case SoundScope.perEveryPhaseInEveryStage:
        return "perEveryPhaseInEveryStage";
    }
  }
  
  static Map<String, dynamic> _soundsToJson(Sounds sounds) {
    return {
      'countingSound': _changeSoundToString(sounds.countingSound),
      'nextSoundScope': _changeScopeToString(sounds.nextSoundScope),
      'nextSound': _changeSoundToString(sounds.nextSound),
      'preparationTrack': _changeSoundToString(sounds.preparationTrack),
      'endingTrack': _changeSoundToString(sounds.endingTrack),
      'backgroundSoundScope': _changeScopeToString(sounds.backgroundSoundScope),
      'trainingBackgroundPlaylist': sounds.trainingBackgroundPlaylist
        .map((s) => SoundManager().isUserMusic(s.name) ? "" : s.name)
        .toList(),
      'stagePlaylists': sounds.stagePlaylists.map((stageId, list) {
        return MapEntry(
            _stageUuidMap[stageId] ?? stageId,
            list.map((s) => SoundManager().isUserMusic(s.name) ? "" : s.name).toList()
        );
      }),
      'breathingPhaseCues': sounds.breathingPhaseCues.map((type, s) {
        return MapEntry(type.name, SoundManager().isUserMusic(s.name) ? "" : s.name);
      }),

      'breathingPhaseBackgrounds': sounds.breathingPhaseBackgrounds.map((type, s) {
        return MapEntry(type.name, SoundManager().isUserMusic(s.name) ? "" : s.name);
      }),
      'perEveryPhaseBreathingPhaseBackgrounds': sounds.perEveryPhaseBreathingPhaseBackgrounds.map((stageId, phaseMap) {
        return MapEntry(
          _stageUuidMap[stageId] ?? stageId,
          phaseMap.map((type, s) {
            return MapEntry(type.name, SoundManager().isUserMusic(s.name) ? "" : s.name);
          }),
        );
      }),
      'stageChangeSound': _changeSoundToString(sounds.stageChangeSound),
      'cycleChangeSound': _changeSoundToString(sounds.cycleChangeSound)
    };
  }

  static SoundAsset _soundAssetFromString(String? value){
    if (value == "voice") {
      return SoundAsset(type: SoundType.voice);
    }
    return SoundManager().getAsset(value ?? '') ?? SoundAsset();
  }

  static Sounds _soundsFromJson(Map<String, dynamic> json) {
    return Sounds()
      ..countingSound = _soundAssetFromString(json['countingSound'])
      ..nextSoundScope = _parseSoundScopeType(json['nextSoundScope'])
      ..nextSound = _soundAssetFromString(json['nextSound'])
      ..preparationTrack = _soundAssetFromString(json['preparationTrack'])
      ..endingTrack = _soundAssetFromString(json['endingTrack'])
      ..backgroundSoundScope = _parseSoundScopeType(json['backgroundSoundScope'])
      ..trainingBackgroundPlaylist = (json['trainingBackgroundPlaylist'] as List?)
          ?.map<SoundAsset?>((name) => SoundManager().getAsset(name))
          .whereType<SoundAsset>()
          .toList() ??
          []
      ..stagePlaylists = (json['stagePlaylists'] as Map<String, dynamic>?)
        ?.map((stageId, list) {
          final soundsList = (list as List).map<SoundAsset>((name) {
            final asset = SoundManager().getAsset(name);
            return asset ?? SoundAsset(); 
          }).toList();
          return MapEntry(stageId, soundsList);
        }) ?? {}
      ..breathingPhaseCues = (json['breathingPhaseCues'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(
            BreathingPhaseType.values.firstWhere((e) => e.name == key),
            SoundManager().getAsset(value) ?? SoundAsset(),
        )) ?? {}
      ..breathingPhaseBackgrounds = (json['breathingPhaseBackgrounds'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(
            BreathingPhaseType.values.firstWhere((e) => e.name == key),
            SoundManager().getAsset(value) ?? SoundAsset(),
        )) ?? {}
      ..perEveryPhaseBreathingPhaseBackgrounds = (json['perEveryPhaseBreathingPhaseBackgrounds'] as Map<String, dynamic>?)
        ?.map((stageId, phaseMap) {
          final phases = (phaseMap as Map<String, dynamic>).map((key, value) => MapEntry(
              BreathingPhaseType.values.firstWhere((e) => e.name == key),
              SoundManager().getAsset(value) ?? SoundAsset(),
          ));
          return MapEntry(stageId, phases);
        }) ?? {}
      ..stageChangeSound = _soundAssetFromString(json['stageChangeSound'])
      ..cycleChangeSound = _soundAssetFromString(json['cycleChangeSound']);
  }

  static SoundScope _parseSoundScopeType(String? value) {
    switch (value) {
      case "none":
        return SoundScope.none;
      case "global":
        return SoundScope.global;
      case "perStage":
        return SoundScope.perStage;
      case "perPhase":
        return SoundScope.perPhase;
      case "perEveryPhaseInEveryStage":
        return SoundScope.perEveryPhaseInEveryStage;
      default:
        return SoundScope.none;
    }
  }
}
