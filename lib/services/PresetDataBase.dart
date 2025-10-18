import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class PresetDataBase {

  TranslationProvider translationProvider = TranslationProvider();

  List<Training> presetList = [];

  static final PresetDataBase _instance = PresetDataBase._internal();
  PresetDataBase._internal();

  factory PresetDataBase() {
    return _instance;
  }

  final _box = Hive.box('respire');

  void initialize() {
    try {
      // Attempt to read stored presets, may throw if format mismatches
      final stored = _box.get('presets');
      if (stored == null) {
        // No presets yet: create defaults
        createInitialData();
        updateDataBase();
      } else {
        // Valid entry exists: load into list
        loadData();
      }
    } catch (e) {
      // Corrupted or incompatible data: clear and reset
      print('Error loading presets: $e – resetting to default presets.');
      _box.delete('presets');
      createInitialData();
      updateDataBase();
    }
  }

  void createInitialData()
  {
    presetList = [
      Training(
        title: "Deep Serenity",
        description: "A calming routine to enhance relaxation and\u00A0mindfulness.",
        trainingStages: [
          TrainingStage(
            reps: 5,
            breathingPhases:[
              BreathingPhase(duration: 5, breathingPhaseType: BreathingPhaseType.inhale),
              BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.retention),
              BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.exhale),
              BreathingPhase(duration: 1, breathingPhaseType: BreathingPhaseType.recovery),
            ],
            increment: 0,
            name: "${translationProvider.getTranslation("TrainingPage.TrainingOverview.stage")} 1"
          )
        ]
      ),
      Training(
        title: "Vital Energy",
        trainingStages: [
          TrainingStage(reps: 3,
          breathingPhases: [
            BreathingPhase(duration: 2.5, breathingPhaseType: BreathingPhaseType.inhale, increment: BreathingPhaseIncrement(value: 10, type: BreathingPhaseIncrementType.percentage)),
            BreathingPhase(duration: 3.14, breathingPhaseType: BreathingPhaseType.retention),
            BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.exhale, increment: BreathingPhaseIncrement(value: 50, type: BreathingPhaseIncrementType.percentage)),
            BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.recovery),
          ],
          increment: 0,
          name: "${translationProvider.getTranslation("TrainingPage.TrainingOverview.stage")} 1"
          )
        ]
         ),
      Training(
      title: "Breath Mastery",
      trainingStages: [
        TrainingStage(
          reps: 2,
          breathingPhases: [
            BreathingPhase(duration: 2.5, breathingPhaseType: BreathingPhaseType.inhale, increment: BreathingPhaseIncrement(value: 10, type: BreathingPhaseIncrementType.percentage)),
            BreathingPhase(duration: 3.5, breathingPhaseType: BreathingPhaseType.retention),
            BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.exhale, increment: BreathingPhaseIncrement(value: 1, type: BreathingPhaseIncrementType.value)),
            BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.recovery),
          ],
          increment: 10,
          name: "${translationProvider.getTranslation("TrainingPage.TrainingOverview.stage")} 1"
        ),
        TrainingStage(
          reps: 1,
          breathingPhases: [
            BreathingPhase(duration: 5.0, breathingPhaseType: BreathingPhaseType.inhale, increment: BreathingPhaseIncrement(value: 15, type: BreathingPhaseIncrementType.percentage)),
            BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.retention),
            BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.exhale, increment: BreathingPhaseIncrement(value: 50, type: BreathingPhaseIncrementType.percentage)),
            BreathingPhase(duration: 3, breathingPhaseType: BreathingPhaseType.recovery),
          ],
          increment: 0,
          name: "${translationProvider.getTranslation("TrainingPage.TrainingOverview.stage")} 2"
        ),
      ],
    ),
    ];
  }

  void deletePreset(int index) {
    presetList.removeAt(index);
    updateDataBase();
  }

  void loadData()
  {
    final storedList = _box.get('presets');
    if (storedList is List) {
      presetList = storedList.cast<Training>();
    }
  }

  void updateDataBase()
  {
    _box.put('presets', presetList);
  }

  void clearUserSound(String soundName) {
    for (var training in presetList) {
      training.sounds.clearUserSound(soundName);
    }
    updateDataBase();
  }
}