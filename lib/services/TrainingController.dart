import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/Step.dart' as training_step;
import 'package:respire/services/TextToSpeechService.dart';

class TrainingController{

   Timer? _timer;
  final TrainingParser parser;
  final ValueNotifier<Queue<training_step.Step?>> stepsQueue = ValueNotifier(Queue<training_step.Step?>());
  final ValueNotifier<int> second = ValueNotifier(3);
  final ValueNotifier<bool> isPaused = ValueNotifier(false);
  final ValueNotifier<int> stepsCount = ValueNotifier(0);

  final int _updateInterval = 100; //in milliseconds
  final int _stepDelayDuration = 600; //in milliseconds
 
  int _remainingTime = 3000; //in milliseconds
  int _nextRemainingTime = 0; //in milliseconds
  int _newStepRemainingTime = 0; //in milliseconds

  int _stepDelayRemainingTime = 600;//in milliseconds

  bool _finished = false;
  bool _stepDelay = true;
  int _stopTimer = 2;


  TrainingController(this.parser) {
    _preloadSteps();
    _start();
  }

  void _preloadSteps() {
    stepsQueue.value.add(null);
    _fetchNextStep();
    _nextRemainingTime = _newStepRemainingTime;
    _fetchNextStep();
    //_fetchNextStep();
  }

  void _fetchNextStep() {
    var instructionData = parser.nextInstruction();

    //no more instructions
    if (instructionData == null) {
      _finished = true;
      stepsQueue.value.add(null);
      return;
    }

    //reading instruction
    stepsQueue.value.add(instructionData["step"]);
    _newStepRemainingTime = instructionData["remainingTime"];
  }

  void pause() {
    isPaused.value = true;
    _timer?.cancel();
  }

  void resume() {
    isPaused.value = false;
    _start();
  }

  void _start()
  {
    int previousSecond = _remainingTime~/1000;
    _timer = Timer.periodic(Duration(milliseconds: _updateInterval),
      (Timer timer) {

        //voice
        if(previousSecond > _remainingTime~/1000 && _stopTimer!=0)
        {
          previousSecond = _remainingTime~/1000;
          second.value = previousSecond+1;
          TextToSpeechService().readNumber(previousSecond+1);
        }

        //time update
         if (_remainingTime >= _updateInterval) {
          _remainingTime -= _updateInterval;
        }

        //step dalay for reading the name
        else if(_stepDelay && _stopTimer!=0) {
          stepsCount.value++;
          if (stepsQueue.value.elementAt(1)!=null) {
            second.value = 0;
            TextToSpeechService().speak(stepsQueue.value.elementAt(1)!.stepType.name);
          }
          _stepDelay = false; 

        //step delay time update
        } else if(_stepDelayRemainingTime >= _updateInterval){
          _stepDelayRemainingTime -= _updateInterval;

        //two last steps
        }else if (_finished) {
          
          //last step
          if(_stopTimer==0) {
            second.value = 0;
             _timer?.cancel();
          
          //one step before last
          } else {
            stepsQueue.value.removeFirst();
            stepsQueue.value.add(null);
            stepsQueue.value = Queue<training_step.Step?>.from(stepsQueue.value);
            _remainingTime = _nextRemainingTime;
            previousSecond = _remainingTime~/1000;
            _stopTimer--;
            _stepDelay = true;
            _stepDelayRemainingTime = _stepDelayDuration;
          }
          
        //new step updates
        } else{
          stepsQueue.value.removeFirst();
          _remainingTime = _nextRemainingTime;
          _nextRemainingTime =_newStepRemainingTime;
          previousSecond = _remainingTime~/1000;
          _fetchNextStep();
           stepsQueue.value = Queue<training_step.Step?>.from(stepsQueue.value);
          _stepDelay = true;
          _stepDelayRemainingTime = _stepDelayDuration;
        }
      }
    );
  }
  void dispose() {
    TextToSpeechService().stopSpeaking();
    _timer?.cancel();
  }
}