import 'dart:developer';

import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as training_step;
import 'package:respire/components/Global/Training.dart';

class TrainingParser {
  int phaseID = 0;
  int stepID = -1;
  int doneReps = 0;

  Training training;
  Phase currentPhase;
  late training_step.Step currentStep;

  TrainingParser({required this.training})
      : currentPhase = training.phases[0];

  Map<String, dynamic>? nextInstruction() {
    if (stepID == currentPhase.steps.length - 1) {
      stepID = 0;
      doneReps++;

      if (doneReps == currentPhase.reps) {
        phaseID++;
        if (phaseID == training.phases.length) {
          return null;
        } else {
          currentPhase = training.phases[phaseID];
          doneReps = 0;
        }
      }
    } else {
      stepID++;
    }

    currentStep = currentPhase.steps[stepID];


  double durationSeconds = currentStep.duration + (currentPhase.increment * doneReps);

    final progressedStep = training_step.Step(
      duration: durationSeconds,
      stepType: currentStep.stepType,
      breathType: currentStep.breathType,
      breathDepth: currentStep.breathDepth,
      sounds: currentStep.sounds,
    );
    
    log('prePhase: ${progressedStep.sounds.prePhase}, background ${progressedStep.sounds.background}');

    return {
      "step": progressedStep,
      "remainingTime": (durationSeconds * 1000).truncate(),
    };
  }


  int countSteps() {
    int result = 0;
    for (int i=0; i<training.phases.length; i++) {
      result += (training.phases[i].steps.length * training.phases[i].reps);
    }
    return result;
  }

}
