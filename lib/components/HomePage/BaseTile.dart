import 'package:flutter/material.dart';
import 'package:respire/theme/Colors.dart';

class BaseTile extends StatelessWidget
{

  final Widget child;
  final GestureTapCallback onClick;
  final Color color;

  ///Creates a [GestureDetector] with circular border radius and specified color
  const BaseTile({
    super.key,
    required this.child,
    required this.onClick,
    this.color = const Color.fromARGB(255, 255, 255, 255)}
    );


  @override
  Widget build(BuildContext context) {

    // Core of the tile
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: double.infinity, // necessary for slidable elements to render expanded
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: color,
          //borderRadius: BorderRadius.circular(20),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70), bottomRight: Radius.circular(35), topLeft: Radius.circular(35), topRight: Radius.circular(70)),
        ),
        child: child,
      ),
    );

  }
  
}