import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/AnimatedCircle.dart';
import 'package:respire/components/BreathingPage/InstructionSlider.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Step.dart' as training_step;
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TrainingController.dart';

class BreathingPage extends StatefulWidget {
  final Training training;

  const BreathingPage({super.key, required this.training});

  @override
  State<StatefulWidget> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  late TrainingParser parser;
  late TrainingController controller;
  int second = 0;
  int steps = 0;

  @override
  void initState() {
    super.initState();
    parser = TrainingParser(training: widget.training);
    controller = TrainingController(parser);
    steps = parser.countSteps();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _showConfirmationDialog() {
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
              onPressed: () {
                Navigator.pop(context);
                controller.resume();
              },
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


  Widget textInCircle() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.second,
      builder: (context, value, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ValueListenableBuilder<Queue<training_step.Step?>>(
          valueListenable: controller.stepsQueue,
          builder: (context, queue, _) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (queue.isNotEmpty && queue.first != null) {
                  controller.pause();
                  _showConfirmationDialog();
                } else {
                  Navigator.pop(context);
                }
              },
            );
          },
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: controller.isPaused,
            builder: (context, isPaused, _) {
              return IconButton(
                icon: isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
                onPressed: () {
                  isPaused ? controller.resume() : controller.pause();
                },
              );
            },
          )
        ],
        title: Text(widget.training.title),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(50, 183, 207, 1),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),

          //instructions
          ValueListenableBuilder<Queue<training_step.Step?>>(
            valueListenable: controller.stepsQueue,
            builder: (context, stepsQueue, _) {
              return ValueListenableBuilder<int>(
                valueListenable: controller.stepsCount,
                builder: (context, change, _) {
                  return InstructionSlider(
                      stepsQueue: stepsQueue, change: change);
                },
              );
            },
          ),

          //step counter
          ValueListenableBuilder<int>(
            valueListenable: controller.stepsCount,
            builder: (context, stepsDone, _) {
              return Text(
                '${stepsDone <= steps ? stepsDone : steps} / $steps',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),

          //circles
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  //background circle, max value
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(183, 244, 255, 1),
                    ),
                  ),

                  //animated circle
                  ValueListenableBuilder<Queue<training_step.Step?>>(
                      valueListenable: controller.stepsQueue,
                      builder: (context, steps, _) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: controller.isPaused,
                            builder: (context, isPaused, _) {
                              return AnimatedCircle(
                                  step: steps.first, isPaused: isPaused);
                            });
                      }),

                  //foreground circle, min value
                  Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(44, 173, 196, 1),
                    ),
                  ),

                  textInCircle()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
