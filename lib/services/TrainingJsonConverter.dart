import 'dart:convert';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Settings.dart';

class TrainingJsonConverter {

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
    return {
      'title': training.title,
      'description': training.description,
      'trainingStages': training.trainingStages.map(_stageToJson).toList(),
      'settings': _settingsToJson(training.settings),
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
    )..settings = _settingsFromJson(json['settings'] ?? {});
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
    return {
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
    );
    // id zostanie automatycznie wygenerowane przez konstruktor TrainingStage
  }
  
  static Map<String, dynamic> _phaseToJson(BreathingPhase phase) {
    return {
      'duration': phase.duration,
      'breathingPhaseType': phase.breathingPhaseType.name,
      'breathType': phase.breathType?.name,
      'breathDepth': phase.breathDepth?.name,
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
      breathType: json['breathType'] != null 
          ? _parseBreathType(json['breathType']) 
          : null,
      breathDepth: json['breathDepth'] != null 
          ? _parseBreathDepth(json['breathDepth']) 
          : null,
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
  
  static BreathType _parseBreathType(String? value) {
    switch (value?.toLowerCase()) {
      case 'diaphragmatic':
        return BreathType.diaphragmatic;
      case 'thoracic':
        return BreathType.thoracic;
      case 'clavicular':
        return BreathType.clavicular;
      case 'costal':
        return BreathType.costal;
      case 'paradoxical':
        return BreathType.paradoxical;
      default:
        return BreathType.diaphragmatic;
    }
  }
  
  static BreathDepth _parseBreathDepth(String? value) {
    switch (value?.toLowerCase()) {
      case 'deep':
        return BreathDepth.deep;
      case 'normal':
        return BreathDepth.normal;
      case 'shallow':
        return BreathDepth.shallow;
      default:
        return BreathDepth.normal;
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
}
