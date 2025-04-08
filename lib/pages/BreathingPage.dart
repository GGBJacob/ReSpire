import 'dart:async';
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/Circle.dart';
import 'package:respire/components/BreathingPage/InstructionBlocks.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Step.dart' as training_step;
import 'package:respire/services/TextToSpeechService.dart';


class BreathingPage extends StatefulWidget {
  final Training training;

  const BreathingPage({super.key, required this.training});

  @override
  State<StatefulWidget> createState() => _BreathingPageState();
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Exit"),
        content: Text(
            "Are you sure you want exit?\nIf you click \"Yes\" your session will end.",
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  );
}

class _BreathingPageState extends State<BreathingPage> {
  late TrainingParser parser;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  training_step.Step? _previousStep;
  training_step.Step? _currentStep;
  training_step.Step? _nextStep;
  int _remainingTime = 3000; //in milliseconds
  int _nextStepRemainingTime = 0;
  int _stepsCount = 0;
  final int _minimumDurationTime = 100; //in milliseconds
  bool _finished = false;
  bool _pause = true;
  final int _pauseDuration = 300;  //in milliseconds
// Dodajemy GlobalKey do InstructionBlocks
  final GlobalKey<InstructionBlocksState> _instructionBlocksKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    parser = TrainingParser(training: widget.training);
    _instructionBlocksKey.currentState?.animation();
    _fetchNextStep();
    _startTraining();
  }

  void _startTraining() {
    int previousSecond = _remainingTime~/1000; // subtracting one to skip the first second and audio bugging
     _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: _minimumDurationTime),
        (Timer timer) {
      setState(() {
        // Whenever the second changes, might want to change the calculations
        // if we decide to switch to seconds instead of milliseconds!
        if(previousSecond > _remainingTime~/1000)
        {
          previousSecond = _remainingTime~/1000;
          TextToSpeechService().speak(previousSecond+1);
        }

        if (_remainingTime > 0) {
          _remainingTime -= _minimumDurationTime;
        } else if(_pause) {
            _instructionBlocksKey.currentState?.animation();
            _remainingTime = _pauseDuration;
            _pause = false; 
        } else if (_finished) {
          _previousStep = _currentStep;
          _currentStep = null;
          pauseTimer();
        } else{
          _previousStep = _currentStep;
          _currentStep = _nextStep;
          _remainingTime = _nextStepRemainingTime;
          previousSecond = _remainingTime~/1000;
          _fetchNextStep();
          _stepsCount++;
          _pause = true;
        }
      });
    });
  }

  void _fetchNextStep() {
    var instructionData = parser.nextInstruction();

    if (instructionData == null) {
      _finished = true;
      _nextStep = null;
      return;
    }

    setState(() {
      _nextStep = instructionData["step"];
      _nextStepRemainingTime = instructionData["remainingTime"];
    });
  }

    void pauseTimer() {
    _timer?.cancel();
    _stopwatch.stop();
  }

  void resumeTimer() {
    _stopwatch.start();
     _startTraining();
  }

  @override
  void dispose() {
    pauseTimer();
    TextToSpeechService().stopSpeaking();
    super.dispose();
  }

  Widget textInCircle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(_remainingTime / 1000).toDouble()}',
            style: TextStyle(
              fontSize: 32,
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _currentStep != null
                ? {_showConfirmationDialog(context)}
                : Navigator.pop(context);
          },
        ),
        title: Text("ReSpire"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          //Title
          Text(widget.training.title,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          //Instructions
         InstructionBlocks(
            key: _instructionBlocksKey,
            steps: [_previousStep, _currentStep, _nextStep],
            currentIndex: _stepsCount
          ),

          Text(
            '$_stepsCount / ${parser.countSteps()}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Expanded(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Circle(
                step: _nextStep,
                child: textInCircle(),
              ),
            ],
          ))),
        ],
      ),
    );
  }
}
