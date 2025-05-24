import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as training_step;

class Circle extends StatefulWidget {
  final training_step.Step? step;
  final Widget? child;

  const Circle({super.key, required this.step, this.child});

  @override
  State<StatefulWidget> createState() => _CircleState();
}

class _CircleState extends State<Circle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  int duration = 0;

  @override
  void initState() {
    super.initState();

    duration = widget.step == null ? 0 : (widget.step!.duration * 1000).toInt();

    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 125.0, end: 225.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.duration = Duration(milliseconds: duration);

    _controller.forward(from: 0.0);
    
  
  }

  @override
  void didUpdateWidget(covariant Circle oldWidget) {
    super.didUpdateWidget(oldWidget);

    duration = widget.step == null ? 0 : (widget.step!.duration * 1000).toInt();
    _controller.duration = Duration(milliseconds: duration);

    if (widget.step?.stepType == training_step.StepType.inhale) {
      _controller.forward(from: 0.0);
    } else if (widget.step?.stepType == training_step.StepType.exhale) {
      _controller.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _circleAnimation,
      builder: (context, child) {
        return Container(
          width: _circleAnimation.value,
          height: _circleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: widget.child,
        );
      },
    );
  }
}
