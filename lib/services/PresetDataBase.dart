import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';

class PresetDataBase {

  List<Training> presetList = [];

  final _box = Hive.box('respire');

  void initialize()
  {
    if (_box.get('presets') == null) // If this is the first time launching the app
    {
      createInitialData();
    }
    else
    {
      loadData();
    }
  }

  void createInitialData()
  {
    presetList = [
      Training(
        title: "Deep Serenity",
        phases: [
          Phase(
            reps: 5,
            steps:[
              Step(duration: 5, stepType: StepType.inhale),
              Step(duration: 4, stepType: StepType.retention),
              Step(duration: 3, stepType: StepType.exhale),
              Step(duration: 1, stepType: StepType.recovery),
            ]
          )
        ]
      ),
      Training(
        title: "Vital Energy",
        phases: [
          Phase(reps: 3, 
          steps: [
            Step(duration: 2.5, stepType: StepType.inhale, increment: StepIncrement(value: 10, type: IncrementType.percentage), breathDepth: BreathDepth.shallow, breathType: BreathType.costal),
            Step(duration: 3.14, stepType: StepType.retention),
            Step(duration: 3, stepType: StepType.exhale, increment: StepIncrement(value: 50, type: IncrementType.percentage)),
            Step(duration: 3, stepType: StepType.recovery),
          ]
          )
        ]
         ),
      Training(
      title: "Breath Mastery",
      phases: [
        Phase(
          reps: 2,
          steps: [
            Step(duration: 2.5,stepType: StepType.inhale,increment: StepIncrement(value: 10, type: IncrementType.percentage),breathDepth: BreathDepth.deep, breathType: BreathType.diaphragmatic),
            Step(duration: 3.5, stepType: StepType.retention),
            Step(duration: 3, stepType: StepType.exhale, increment: StepIncrement(value: 1, type: IncrementType.value)),
            Step(duration: 3, stepType: StepType.recovery),
          ],
        ),
        Phase(
          reps: 1,
          steps: [
            Step(duration: 5.0, stepType: StepType.inhale, increment: StepIncrement(value: 15, type: IncrementType.percentage), breathDepth: BreathDepth.deep, breathType: BreathType.diaphragmatic),
            Step(duration: 4, stepType: StepType.retention),
            Step(duration: 3, stepType: StepType.exhale, increment: StepIncrement(value: 50, type: IncrementType.percentage)),
            Step(duration: 3, stepType: StepType.recovery),
          ],
        ),
      ],
    ),
    ];
  }

  void loadData()
  {
    final storedList = _box.get('presets');
    if (storedList != null) {
      presetList = (storedList as List).cast<Training>();
    }
  }

  void updateDataBase()
  {
    _box.put('presets', presetList);
  }
}