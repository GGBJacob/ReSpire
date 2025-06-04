import 'package:flutter/material.dart';
import 'package:respire/components/HomePage/BaseTile.dart';
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
  return GestureDetector(
    onTap: onClick,
    child: SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          //additional semi-hidden dot
          Transform.translate(
            offset: const Offset(18, -10),
            child: Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                color: lightblue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          //white circle with +
          Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 36,
                color: darkblue,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  
}