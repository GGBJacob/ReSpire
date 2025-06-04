import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as training_step;

class AnimatedCircle extends StatefulWidget {
  final training_step.Step? step;
  final bool isPaused;

  const AnimatedCircle({super.key, required this.step, required this.isPaused});

  @override
  State<StatefulWidget> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle> with SingleTickerProviderStateMixin {
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

    _circleAnimation = Tween<double>(begin: 125.0, end: 300.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.duration = Duration(milliseconds: duration);

    _controller.value = 0.0;
    
    if (!widget.isPaused && widget.step != null) {
      if (widget.step!.stepType == training_step.StepType.inhale) {
        _controller.forward(from: 0.0);
      } else if (widget.step!.stepType == training_step.StepType.exhale) {
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.step != oldWidget.step && widget.step!=null) {
      log("${widget.step?.stepType.name}");

      duration = widget.step == null ? 0 : (widget.step!.duration * 1000).toInt();
      _controller.duration = Duration(milliseconds: duration);

      if (!widget.isPaused && widget.step != null) {
        if (widget.step!.stepType == training_step.StepType.inhale) {
          _controller.forward(from: 0.0);
        } else if (widget.step!.stepType == training_step.StepType.exhale) {
          _controller.reverse(from: 1.0);
        }
      } else {
        _controller.stop();
      }
    }

    // Reakcja na pauzę/wznowienie (jeśli step się nie zmienia)
    if (widget.isPaused && !oldWidget.isPaused) {
      _controller.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      if (widget.step != null) {
        if (widget.step!.stepType == training_step.StepType.inhale) {
          _controller.forward();
        } else if (widget.step!.stepType == training_step.StepType.exhale) {
          _controller.reverse();
        }
      }
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
            color: Color.fromRGBO(50, 183, 207, 1),
          ),
        );
      },
    );
  }
}
