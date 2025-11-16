import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as breathing_phase;
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class InstructionBlock {
  final String text;
  double position;

  InstructionBlock({required this.text, required this.position});
}

class InstructionSlider extends StatefulWidget {

  Queue<breathing_phase.BreathingPhase?> breathingPhasesQueue = Queue<breathing_phase.BreathingPhase?>();
  int change; 

  InstructionSlider({super.key, required this.breathingPhasesQueue, required this.change});

  @override
  State<InstructionSlider> createState() => InstructionSliderState();
}

class InstructionSliderState extends State<InstructionSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double spacing = 140.0;
  final Duration duration = Duration(milliseconds: 400);
  TranslationProvider translationProvider = TranslationProvider();

  List<InstructionBlock> _blocks = [];
  int i = 1;

  @override
  void initState() {
    super.initState();
   
    _blocks.add(
      InstructionBlock(
        text: translationProvider.getTranslation("BreathingPage.InstructionSlider.get_ready_block_text"), 
        position: 0.0)
    );
    
    _controller = AnimationController(vsync: this, duration: duration);
    _animation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    addNewBreathingPhase(widget.breathingPhasesQueue.elementAt(1), 1.0);
    addNewBreathingPhase(widget.breathingPhasesQueue.elementAt(2), 2.0);


    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        setState(() {
          _blocks.removeWhere((b) => b.position <= -2);
          _blocks.forEach(
              (b) => b.position += _animation.value); // apply final position
          _blocks.forEach((b) => b.position -= 1); // shift left
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant InstructionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.change != widget.change) {
      _controller.forward();
      if(_blocks.last.text!=translationProvider.getTranslation("BreathingPage.InstructionSlider.ending_tile_text")) {
        addNewBreathingPhase(widget.breathingPhasesQueue.elementAt(2), 2.0);
      }
    }
  }

  // void next() {
  //   if (!_controller.isAnimating) {
  //     _controller.forward();
  //   }
  // }

  void addNewBreathingPhase(breathing_phase.BreathingPhase? breathingPhase, double position) {
    String breathingPhaseName = breathingPhase==null ? translationProvider.getTranslation("BreathingPage.InstructionSlider.ending_tile_text") : _breathingPhaseType(breathingPhase);
    _blocks.add(
      InstructionBlock(
        text: breathingPhaseName, 
        position: position)
    );
  }

   String _firstToUpperCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

   String _breathDepth(breathing_phase.BreathingPhase? breathingPhase) {
    if (breathingPhase!.breathDepth == null) return "";
    return _firstToUpperCase(breathingPhase.breathDepth!.name);
  }

  String _breathType(breathing_phase.BreathingPhase? breathingPhase) {
    if (breathingPhase!.breathType == null) return "";
    return _firstToUpperCase(translationProvider.getTranslation("BreathingPhaseType.${breathingPhase.breathType!.name}"));
  }

  String _breathingPhaseType(breathing_phase.BreathingPhase? breathingPhase) {
    if (breathingPhase == null) return "";

    String str = translationProvider.getTranslation("BreathingPhaseType.${breathingPhase.breathingPhaseType.name}");

    switch (breathingPhase.breathingPhaseType) {

      case breathing_phase.BreathingPhaseType.inhale:
      case breathing_phase.BreathingPhaseType.exhale:
        if (breathingPhase.breathType!=null) {
          str += "\n${_breathType(breathingPhase)}";
        }
        if (breathingPhase.breathDepth!=null) {
          str += "\n${_breathDepth(breathingPhase)}";
        }
        break;

      default:
        break;  
    }

    str += "\n${breathingPhase.duration} s";
    return str;
  }

  double _calculateScale(double position) {
    final dist = (position).abs();
    return 1.0 - 0.25 * dist;
  }

  Widget _buildBlock(
      {required double positionX,
      required double scale,
      required String text}) {

      final isCenter = (positionX / spacing).round() == 0;

    return Positioned(
      left: 200 + positionX - 60, // offset to center + half block width
      top: 50,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 130,
          height: 130,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCenter 
            ? Color.fromRGBO(44, 173, 196, 1)
            : Color.fromRGBO(50, 183, 207, 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [ //shadow from https://flutter-boxshadow.vercel.app/ (modified)
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.07),
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.07),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.07),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                )
              ]
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 400,
          height: 220,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Stack(
                children: _blocks.map((block) {
                  final animatedPos = block.position + _animation.value;
                  return _buildBlock(
                    positionX: animatedPos * spacing,
                    scale: _calculateScale(animatedPos),
                    text: block.text,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
