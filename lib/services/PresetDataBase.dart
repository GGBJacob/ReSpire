import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';

class PresetDataBase {

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
        description: "A calming routine to enhance relaxation and mindfulness.",
        phases: [
          Phase(
            reps: 5,
            steps:[
              Step(duration: 5, stepType: StepType.inhale),
              Step(duration: 4, stepType: StepType.retention),
              Step(duration: 3, stepType: StepType.exhale),
              Step(duration: 1, stepType: StepType.recovery),
            ],
            increment: 0,
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
          ],
          increment: 0,
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
          increment: 10,
        ),
        Phase(
          reps: 1,
          steps: [
            Step(duration: 5.0, stepType: StepType.inhale, increment: StepIncrement(value: 15, type: IncrementType.percentage), breathDepth: BreathDepth.deep, breathType: BreathType.diaphragmatic),
            Step(duration: 4, stepType: StepType.retention),
            Step(duration: 3, stepType: StepType.exhale, increment: StepIncrement(value: 50, type: IncrementType.percentage)),
            Step(duration: 3, stepType: StepType.recovery),
          ],
          increment: 0,
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
}