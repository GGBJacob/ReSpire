import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as training_step;
import 'package:respire/components/Global/Training.dart';

class TrainingParser {
  int phaseID = 0;
  int stepID = -1;
  // Counts how many repetitions have already been COMPLETED in the current phase.
  // For the first repetition this stays 0 so that no increment is applied.
  int doneReps = 0; // 0-based repetition index for current phase

  Training training;
  Phase currentPhase;
  late training_step.Step currentStep;

  TrainingParser({required this.training})
      : currentPhase = training.phases[0];

  Map<String, dynamic>? nextInstruction() {
    // Determine next step indices & handle phase transitions
    if (stepID == currentPhase.steps.length - 1) {
      // We have just finished the last step of the current repetition
      stepID = 0;
      doneReps++; // move to next repetition (second rep => doneReps == 1)

      if (doneReps == currentPhase.reps) {
        // Phase completed – advance to next phase
        phaseID++;
        if (phaseID == training.phases.length) {
          return null; // No more phases => training finished
        } else {
          currentPhase = training.phases[phaseID];
          doneReps = 0; // Reset repetition counter for the new phase
        }
      }
    } else {
      // Advance to next step inside the current repetition
      stepID++;
    }

    currentStep = currentPhase.steps[stepID];

    // Assign sound based on step type (global training sounds currently used)
    switch (currentStep.stepType) {
      case training_step.StepType.inhale:
        currentStep.sound = training.sounds.inhaleSound;
        break;
      case training_step.StepType.retention:
        currentStep.sound = training.sounds.retentionSound;
        break;
      case training_step.StepType.exhale:
        currentStep.sound = training.sounds.exhaleSound;
        break;
      case training_step.StepType.recovery:
        currentStep.sound = training.sounds.recoverySound;
        break;
    }

  // Simple phase-based progression: every repetition adds phase.increment seconds to ALL steps
  // rep index = doneReps (0 for first repetition). duration(rep) = base + doneReps * phase.increment
  double durationSeconds = currentStep.duration + (currentPhase.increment * doneReps);

    // We need AnimatedCircle to use the progressed duration. Since Step.duration is final,
    // we create a lightweight clone with the computed duration while keeping original definition
    // (including its increment) intact inside currentPhase.steps for future repetitions.
    final progressedStep = training_step.Step(
      duration: durationSeconds,
      stepType: currentStep.stepType,
      breathType: currentStep.breathType,
      breathDepth: currentStep.breathDepth,
      sound: currentStep.sound,
    );

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
