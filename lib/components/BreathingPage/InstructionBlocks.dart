import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as training_step;

class InstructionBlocks extends StatefulWidget {
  final List<training_step.Step?> steps ;
  final int currentIndex;

  const InstructionBlocks(
      {super.key,
      required this.steps,
      required this.currentIndex
      });

  @override
  State<StatefulWidget> createState() => InstructionBlocksState();
}

enum InstructionType {
    previous,
    current,
    next
  }

class InstructionBlocksState extends State<InstructionBlocks> with SingleTickerProviderStateMixin {

  //Animation
  late AnimationController _controller;
  late Animation<double> _animation;

  //Scales
  double scalePrev = 0.8;
  double scaleCurr = 1.0;
  double scaleNext = 0.8;

  //Default container size
  double containerSize = 140;

  final double boxWidth = 100;
  final double spacing = 140;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }


  String _breathDepth(training_step.Step? step) {
    if (step!.breathDepth == null) return "";
    return _firstToUpperCase(step.breathDepth!.name);
  }

  String _breathType(training_step.Step? step) {
    if (step!.breathType == null) return "";
    return _firstToUpperCase(step.breathType!.name);
  }

  String _stepType(training_step.Step? step) {
    if (step == null) return "";

  String str = _firstToUpperCase(step.stepType.name);
    switch (str) {

      case "Inhale":
        if (step.breathType!=null) {
          str += "\n${_breathType(step)}";
        }
        if (step.breathDepth!=null) {
          str += "\n${_breathDepth(step)}";
        }
        str += "\n${step.duration} sec";
        return str;

      case "Exhale":
        String str = "Exhale";
        if (step.breathType!=null) {
          str += "\n${_breathType(step)}";
        }
        if (step.breathDepth!=null) {
          str += "\n${_breathDepth(step)}";
        }
        str += "\n${step.duration} sec";
        return str;

      case "Recovery" || "Retention":
        return "$str\n${step.duration} sec";

      default:
        return "";
    }
  }

  String _currentInstruction() {
    if (widget.steps[1] == null && widget.steps[0] == null) {
      return "Get ready!";
    } else if (widget.steps[1] == null && widget.steps[2] == null) {
      return "The end!";
    } else if (widget.steps[1] != null) {
      return _stepType(widget.steps[1]);
    }

    return "Error";
  }

  String _previousInstruction() {
    if (widget.steps[0] == null && widget.steps[1] != null) {
      return "Get ready!";
    }

    return _stepType(widget.steps[0]);
  }

  String _nextInstruction() {
    if (widget.steps[2] == null && widget.steps[1] != null) {
      return "The end!";
    }

    return _stepType(widget.steps[2]);
  }


  String _firstToUpperCase(String str) {
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: 400,
    height: 200,
    child: AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Stack(
          children: [
            // Poprzedni krok
            _buildBlock(
              positionX: spacing * (-_animation.value), // Z centrum na lewo
              scale: 1.0 - 0.2 * _animation.value,   // Zmniejszanie
              text: _previousInstruction(),
            ),
            // Obecny krok
            _buildBlock(
              positionX: spacing * (1 - _animation.value), // Z prawej do centrum
              scale: 0.8 + 0.2 * _animation.value,         // Zwiększanie
              text: _currentInstruction(),
            ),
            // Następny krok
            _buildBlock(
              positionX: spacing * (2 - _animation.value), // Z dalszej prawej na prawo
              scale: 0.8,                                  // Stały rozmiar
              text: _nextInstruction(),
            ),
          ],
        );
      },
    ),
  );
}

Widget _buildBlock({required double positionX, required double scale, required String text}) {
  return Positioned(
    left: 200 + positionX - (boxWidth / 2), // Centrujemy względem szerokości 400
    top: 50,
    child: Transform.scale(
      scale: scale,
      child: BoxWidget(title: text),
    ),
  );
}

  void animation() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animation.removeListener(() {});
    super.dispose();
  }

}

class BoxWidget extends StatelessWidget {
  final String title;
  const BoxWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }
}