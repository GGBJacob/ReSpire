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
          }
        }
      } else {
        stepID++;
      }

    currentStep = currentPhase.steps[stepID];

    return {
      "step": currentStep,
      "remainingTime": (currentStep.getStepDuration(doneReps) * 1000).truncate(),
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
