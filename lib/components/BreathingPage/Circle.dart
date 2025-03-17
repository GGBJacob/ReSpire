import 'package:flutter/material.dart';
import 'dart:async';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as training_step;
import 'package:respire/components/Global/StepIncrement.dart';


class Circle extends StatefulWidget {
  final Training training;

  const Circle({super.key, required this.training});

  @override
  State<StatefulWidget> createState() => _CircleState();
}

class _CircleState extends State<Circle> with SingleTickerProviderStateMixin {
  late double remainingTime;
  late training_step.Step currentStep;
  late Phase currentPhase;
  int stepID = -1;
  int phaseID = 0;
  late String currentInstruction;
  late int repetition;
  int breathCount = 0;
  late Timer timer;
  double circleSize = 125.0;
  late AnimationController _animationController;
  late Animation<double> _circleAnimation;
  

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3)
        );
    currentPhase = widget.training.phases[0];
    currentStep = currentPhase.steps[0];
    remainingTime = 3;
    currentInstruction = "Get ready";
    _circleAnimation = Tween<double>(begin: 125.0, end: 225.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    startTraining();
  }

  @override
  void dispose() {
    timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  //Function that set the timer and manage the animation
  void startTraining() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        //time
        if (remainingTime > 0) {
          remainingTime--;
          return;
        } 
        
        //starting step (not in training)
        if (stepID==-1) {
          stepID = 0;
          remainingTime = remainingTimeValue(currentStep.duration);
          currentInstruction = currentStep.stepType.name;
        }

        //Next step
        breathCount++;
        if (stepID == currentPhase.steps.length) {
          stepID = 0;
          currentPhase.doneRepsCounter++;
          if (currentPhase.doneRepsCounter == currentPhase.reps) 
          {
            phaseID++;
            //checking if training ends
            if (phaseID == widget.training.phases.length)
            {
              currentInstruction = "Finished";
              timer.cancel();
              return;
            }
            else
            {  
              currentPhase = widget.training.phases[phaseID];
            }
          } 
        }
      
        currentStep = currentPhase.steps[stepID];
        currentInstruction = currentStep.stepType.name;

        //Duration
        remainingTime = remainingTimeValue(currentStep.duration);
        

        //Animation
        switch (currentStep.stepType) {
          case training_step.StepType.inhale:
            _animationController.duration = Duration(seconds: remainingTime.toInt());
            _animationController.forward(from: 0.0);
            circleSize = 225.0;
            break;
          case training_step.StepType.exhale:
            _animationController.duration = Duration(seconds: remainingTime.toInt());
            _animationController.reverse(from: 1.0);
            circleSize = 125.0;
            break;
          default:
            break;
        }

        stepID++;

      });
    });
  }

  double remainingTimeValue(double duration) {
    double result = duration;
    switch (currentStep.increment?.type) {
            case IncrementType.percentage:
              result += (result * currentStep.increment!.value * currentPhase.doneRepsCounter);
              break;
            case IncrementType.value:
              result += currentStep.increment!.value * currentPhase.doneRepsCounter;
              break;
            default:
              break;
          }
    return result;
  }

  int countSteps() {
    int result = 0;
    for (int i = 0; i < widget.training.phases.length; i++) {
      result += widget.training.phases[i].steps.length;
    }
    return result;
  }

  Widget textInCircle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Instruction
          Text(
            currentInstruction,
            style: TextStyle(
              fontSize: (currentInstruction=="Finished" ? 24 : 16 ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          //Time
          Text(
            '$remainingTime',
            style: TextStyle(
              fontSize: (currentInstruction=="Finished" ? 0 : 32),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            SizedBox(
              width: 250, 
              height: 250,
              child: Stack(
                alignment: Alignment.center, 
                children: [
                  //Animated Circle
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: _circleAnimation.value,
                        height: _circleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: textInCircle(),
                      );
                    },
                  ),
                ],
              ),
            ),

            //Cycles
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${breathCount} / ${countSteps()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      )
    );
  }
}
