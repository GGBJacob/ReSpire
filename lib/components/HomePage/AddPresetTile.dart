import 'package:flutter/material.dart';
import 'package:respire/theme/Colors.dart';

class AddPresetTile extends StatelessWidget
{

  final GestureTapCallback onClick;
  final Color color;

  const AddPresetTile({
    super.key,
    required this.onClick,
    this.color = const Color.fromRGBO(0, 195, 255, 1)}
    );

Widget build(BuildContext context) {
  double size = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onClick,
    child: SizedBox(
      //width: 120,
      //height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          //additional semi-hidden dot
          Transform.translate(
            offset: const Offset(16, -8),
            child: Container(
              width: size * 0.125,
              height: size * 0.125,
              decoration: const BoxDecoration(
                color: lightblue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          //white circle with +
          Container(
            width: size * 0.14,
            height: size * 0.14,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: size * 0.07,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  
}