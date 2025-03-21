import 'package:flutter/material.dart';
import 'package:respire/components/HomePage/BaseTile.dart';

class AddPhaseButton extends StatelessWidget
{

  final GestureTapCallback onClick;
  final Color color;

  const AddPhaseButton({
    super.key,
    required this.onClick,
    this.color = const Color.fromARGB(255, 88, 88, 88)}
    );

  @override
  Widget build(BuildContext context) {
    return BaseTile(
      onClick: onClick,
        child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.add)]
          )
    );
  }
  
}