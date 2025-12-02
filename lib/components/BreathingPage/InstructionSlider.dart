import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as breathing_phase;
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'dart:developer' as dev;

class InstructionBlock {
  final String text;
  double position;

  InstructionBlock({required this.text, required this.position});
}

class InstructionSlider extends StatefulWidget {

  double preparationTime;
  double endingTime;
  Queue<breathing_phase.BreathingPhase?> breathingPhasesQueue = Queue<breathing_phase.BreathingPhase?>();
  int change; 

  InstructionSlider({super.key,required this.preparationTime, required this.endingTime, required this.breathingPhasesQueue, required this.change});

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
        text: translationProvider.getTranslation("BreathingPage.InstructionSlider.get_ready_block_text") + "\n${widget.preparationTime} s", 
        position: 0.0)
        
    );
    _logSlider('ADD', detail: 'Przygotuj się');
    
    _controller = AnimationController(vsync: this, duration: duration);
    _animation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    addNewBreathingPhase(widget.breathingPhasesQueue.elementAt(1));
    addNewBreathingPhase(widget.breathingPhasesQueue.elementAt(2));

    _logSlider('INIT', detail: '3 bloki');

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logSlider('ANIMATION COMPLETE', detail: 'przed resetem');
        _controller.reset();
        setState(() {
          final removed = _blocks.where((b) => b.position <= -2).toList();
          if (removed.isNotEmpty) {
            _logSlider('REMOVE', detail: removed.map((b) => b.text.split('\n').first).join(', '));
          }

          _blocks.removeWhere((b) => b.position <= -2);
          _blocks.forEach(
              (b) => b.position += _animation.value); // apply final position
          _blocks.forEach((b) => b.position -= 1); 
          _logSlider('SHIFT', detail: 'przesunięto o -1');// shift left
        });
      }
    });
  }

  void _logSlider(String action, {String? detail}) {
    final blockTexts = _blocks.map((b) => 
      b.text.split('\n').first // tylko pierwsza linia (nazwa)
          .replaceAll(' s', '') // usuń " s"
          .replaceAll(RegExp(r'\d+$'), '') // usuń czas
          .trim()
    ).toList();

    final positions = _blocks.map((b) => b.position.toStringAsFixed(1)).toList();

    dev.log('[SLIDER] $action: ${detail ?? ''} | '
        'Blocks: $blockTexts | '
        'Positions: [$positions]');
  }

  @override
  void didUpdateWidget(covariant InstructionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.change != widget.change) {
      _logSlider('CHANGE DETECTED', detail: 'change: ${oldWidget.change} → ${widget.change}');
      final int phaseDuration = (widget.breathingPhasesQueue.elementAt(0)?.duration.toInt() != null)
        ? (widget.breathingPhasesQueue.elementAt(0)!.duration * 1000).toInt() - 50 // -50 to account for some delay and have room for error
        : 400;
      _logSlider('phase duration', detail: 'Duration: $phaseDuration ms');
      _controller.duration = Duration(milliseconds: min(phaseDuration,400));
      _controller.forward();
      if(!_blocks.last.text.startsWith(translationProvider.getTranslation("BreathingPage.InstructionSlider.ending_tile_text"))) {
        addNewBreathingPhase(widget.breathingPhasesQueue.elementAt(2));
      }
    }
  }

  // void next() {
  //   if (!_controller.isAnimating) {
  //     _controller.forward();
  //   }
  // }

  void addNewBreathingPhase(breathing_phase.BreathingPhase? breathingPhase) {
    final double position = _blocks.isEmpty ? 0.0 : _blocks.last.position + 1.0;
    String breathingPhaseName = breathingPhase==null ? translationProvider.getTranslation("BreathingPage.InstructionSlider.ending_tile_text") + "\n${widget.endingTime} s" : _breathingPhaseType(breathingPhase);
    _blocks.add(
      InstructionBlock(
        text: breathingPhaseName, 
        position: position)
    );
    _logSlider('ADD', detail: breathingPhaseName.split('\n').first);
  }

   String _firstToUpperCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  String _breathingPhaseType(breathing_phase.BreathingPhase? breathingPhase) {
    if (breathingPhase == null) return "";

    String str = translationProvider.getTranslation("BreathingPhaseType.${breathingPhase.breathingPhaseType.name}");

    switch (breathingPhase.breathingPhaseType) {

      case breathing_phase.BreathingPhaseType.inhale:
      case breathing_phase.BreathingPhaseType.exhale:
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
      required String text,
      required double blockSize,
      required double sliderWidth}) {

      final isCenter = (positionX / spacing).round() == 0;

    return Positioned(
      left: sliderWidth / 2 + positionX - blockSize / 2, // offset to center + half block width
      top: 20,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: blockSize,
          height: blockSize,
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
    final sliderWidth = MediaQuery.of(context).size.width;
    final blockSize = sliderWidth * 0.32;
    return Column(
      children: [
        SizedBox(
          width: sliderWidth,
          height: 190,
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
                    blockSize: blockSize,
                    sliderWidth: sliderWidth,
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
