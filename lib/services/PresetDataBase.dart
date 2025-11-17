import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';

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
      final stored = _box.get('presets');
      final version = _box.get('presets_version', defaultValue: 0);
      
      if (stored == null) {
        createInitialData();
        updateDataBase();
      } else {
        loadData();
        
        if (version < 1) {
          _migrateSounds();
          _box.put('presets_version', 1);
          updateDataBase();
        }
      }
    } catch (e) {
      print('Error loading presets: $e – resetting to default presets.');
      _box.delete('presets');
      createInitialData();
      updateDataBase();
    }
  }
  
  void _migrateSounds() {
    for (var training in presetList) {
      bool hasNoSounds = training.sounds.preparationTrack.type == SoundType.none &&
                         training.sounds.trainingBackgroundPlaylist.isEmpty;
      
      if (hasNoSounds) {
        int index = presetList.indexOf(training);
        switch (index % 3) {
          case 0:
            training.sounds.trainingBackgroundPlaylist = [SoundManager.longSounds["Birds"]!];
            training.sounds.preparationTrack = SoundManager.longSounds["Ocean"]!;
            training.sounds.endingTrack = SoundManager.longSounds["Rain"]!;
            break;
          case 1:
            training.sounds.trainingBackgroundPlaylist = [SoundManager.longSounds["Rain"]!];
            training.sounds.preparationTrack = SoundManager.longSounds["Ainsa"]!;
            training.sounds.endingTrack = SoundManager.longSounds["Ocean"]!;
            break;
          case 2:
            training.sounds.trainingBackgroundPlaylist = [SoundManager.longSounds["Ainsa"]!];
            training.sounds.preparationTrack = SoundManager.longSounds["Birds"]!;
            training.sounds.endingTrack = SoundManager.longSounds["Ocean"]!;
            break;
        }
        training.sounds.backgroundSoundScope = SoundScope.global;
        training.updateSounds();
      }
    }
  }

  void createInitialData() {
  presetList = [

    Training(
      title: "Box Breathing",
      description: "Technique used by Navy SEALs to enhance focus and reduce stress",
      trainingStages: [
        TrainingStage(
          reps: 5,
          breathingPhases: [
            BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.inhale),
            BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.retention),
            BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.exhale),
            BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.recovery),
          ],
          increment: 0,
          name: "${translationProvider.getTranslation("TrainingEditorPage.TrainingTab.default_training_stage_name")} 1"
        )
      ]
    )
      ..sounds.trainingBackgroundPlaylist = [SoundManager.longSounds["Birds"]!]
      ..sounds.preparationTrack = SoundManager.longSounds["Ocean"]!
      ..sounds.endingTrack = SoundManager.longSounds["Rain"]!
      ..sounds.backgroundSoundScope = SoundScope.global
      ..updateSounds(),


    Training(
      title: "4-7-8",
      description: "Dr. Andrew Weil's technique ideal for stress reduction and falling asleep.",
      trainingStages: [
        TrainingStage(
          reps: 4,
          breathingPhases: [
            BreathingPhase(duration: 4, breathingPhaseType: BreathingPhaseType.inhale),
            BreathingPhase(duration: 7, breathingPhaseType: BreathingPhaseType.retention),
            BreathingPhase(duration: 8, breathingPhaseType: BreathingPhaseType.exhale),
            BreathingPhase(duration: 2, breathingPhaseType: BreathingPhaseType.recovery),
          ],
          increment: 0,
          name: "${translationProvider.getTranslation("TrainingEditorPage.TrainingTab.default_training_stage_name")} 1"
        )
      ]
    )
      ..sounds.trainingBackgroundPlaylist = [SoundManager.longSounds["Rain"]!]
      ..sounds.preparationTrack = SoundManager.longSounds["Ainsa"]!
      ..sounds.endingTrack = SoundManager.longSounds["Ocean"]!
      ..sounds.backgroundSoundScope = SoundScope.global
      ..updateSounds(),

    Training(
      title: "Coherent Method",
      description: "Steady 6-second inhale and exhale to balance the nervous system, reduce stress and improve heart rate variability (HRV).",
      trainingStages: [
        TrainingStage(
          reps: 10,
          breathingPhases: [
            BreathingPhase(duration: 6, breathingPhaseType: BreathingPhaseType.inhale),
            BreathingPhase(duration: 6, breathingPhaseType: BreathingPhaseType.exhale),
          ],
          increment: 0,
          name: "${translationProvider.getTranslation("TrainingEditorPage.TrainingTab.default_training_stage_name")} 1"
        )
      ]
    )
      ..sounds.trainingBackgroundPlaylist = [SoundManager.longSounds["Ainsa"]!]
      ..sounds.preparationTrack = SoundManager.longSounds["Birds"]!
      ..sounds.endingTrack = SoundManager.longSounds["Ocean"]!
      ..sounds.backgroundSoundScope = SoundScope.global
      ..updateSounds(),
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