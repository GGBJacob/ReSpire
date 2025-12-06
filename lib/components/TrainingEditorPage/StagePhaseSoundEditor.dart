import 'package:flutter/material.dart';
import 'package:respire/components/Global/TrainingStage.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/BreathingPhase.dart';
import 'package:respire/components/TrainingEditorPage/SoundSelectionRow.dart';
import 'package:respire/components/TrainingEditorPage/StageExpansionList.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class StagePhaseSoundEditor extends StatelessWidget {
  final List<TrainingStage> stages;
  final Map<String, Map<BreathingPhaseType, SoundAsset>> stagePhaseSounds;
  final ValueChanged<Map<String, Map<BreathingPhaseType, SoundAsset>>> onChanged;
  final SoundListType soundListType;

  const StagePhaseSoundEditor({
    super.key,
    required this.stages,
    required this.stagePhaseSounds,
    required this.onChanged,
    required this.soundListType,
  });

  @override
  Widget build(BuildContext context) {
    final translationProvider = TranslationProvider();

    return StageExpansionList(
      stages: stages,
      itemBuilder: (context, stage, index) {
        return _buildStagePhases(stage, translationProvider);
      },
    );
  }

  Widget _buildStagePhases(TrainingStage stage, TranslationProvider translationProvider) {
    return Column(
      children: [
        for (final phase in BreathingPhaseType.values)
          SoundSelectionRow(
            includeVoiceOption: false,
            labelStyle: const TextStyle(overflow: TextOverflow.ellipsis),
            label: translationProvider.getTranslation("BreathingPhaseType.${phase.name}"),
            selectedValue: _getSoundForStageAndPhase(stage.id, phase),
            soundListType: soundListType,
            onChanged: (sound) => _updateSound(stage.id, phase, sound),
            isSoundSelection: true,
          ),
      ],
    );
  }

  SoundAsset _getSoundForStageAndPhase(String stageId, BreathingPhaseType phase) {
    if (stagePhaseSounds.containsKey(stageId)) {
      final stageMap = stagePhaseSounds[stageId]!;
      if (stageMap.containsKey(phase)) {
        return stageMap[phase]!;
      }
    }
    return SoundAsset();
  }

  void _updateSound(String stageId, BreathingPhaseType phase, SoundAsset sound) {
    final newMap = Map<String, Map<BreathingPhaseType, SoundAsset>>.from(stagePhaseSounds);
    
    if (!newMap.containsKey(stageId)) {
      newMap[stageId] = {};
    }
    
    final stageMap = Map<BreathingPhaseType, SoundAsset>.from(newMap[stageId]!);
    stageMap[phase] = sound;
    newMap[stageId] = stageMap;

    onChanged(newMap);
  }
}
