import 'package:flutter/material.dart';
import 'package:respire/components/PresetEntry.dart';
import 'dart:async';

class Circle extends StatefulWidget {
  final PresetEntry tile;

  const Circle({super.key, required this.tile});

  @override
  State<StatefulWidget> createState() => _CircleState();
}

class _CircleState extends State<Circle> with SingleTickerProviderStateMixin {
  late int remainingTime;
  late int currentBreathCycle;
  late Timer timer;
  String currentInstruction = "Inhale";
  int cycle = 1;
  double circleSize = 125.0;
  late AnimationController _animationController;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.tile.inhaleTime;
    currentBreathCycle = widget.tile.breathCount;
    _animationController = AnimationController(
      vsync: this,
      duration:
          Duration(seconds: widget.tile.inhaleTime),
    );

    _circleAnimation = Tween<double>(begin: 125.0, end: 225.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
     _animationController.forward();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  //Function that set the timer and manage the animation
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          if (currentInstruction == "Inhale") {
            //Change to Retention
            currentInstruction = "Retention";
            remainingTime = widget.tile.retentionTime;

          } else if (currentInstruction == "Retention") {
            //Change to Exhale
            currentInstruction = "Exhale";
            remainingTime = widget.tile.exhaleTime;
            //Exhale animation parameters
            _animationController.duration = Duration(seconds: widget.tile.exhaleTime);
            _animationController.reverse(from: 1.0);
            circleSize = 125.0;
            
          } else if (currentInstruction == "Exhale") {
            //Check cycles
            if (cycle == widget.tile.breathCount) {
              currentInstruction = "Finished";
            }
            else {
            //Change to Inhale
            cycle++;
            currentInstruction = "Inhale";
            remainingTime = widget.tile.inhaleTime;
            //Inhale animation parameters
            _animationController.duration = Duration(seconds: widget.tile.inhaleTime);
            _animationController.forward(from: 0.0);
            circleSize = 225.0;
            }
          } else if (currentInstruction == "Finished") {
            //End of the session
            timer.cancel();
          }
        }
      });
    });
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
                '$cycle / ${widget.tile.breathCount}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      )
    );
  }
}
