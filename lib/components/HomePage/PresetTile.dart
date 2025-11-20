import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/HomePage/BaseTile.dart';
import 'package:respire/theme/Colors.dart';

class PresetTile extends StatelessWidget
{

  final GestureTapCallback onClick;
  final Color color;
  final Training value;

  const PresetTile({
    super.key,
    required this.onClick,
    required this.value,
    this.color = const Color.fromARGB(255, 189, 36, 82)
    });

  @override
  Widget build(BuildContext context) {
    return BaseTile(
        onClick: onClick,
          child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scaleX: -1,  
                    child: Icon(
                      Icons.air,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 6), //span between icons and text
                  Flexible(
                    child:Text(
                      value.title,
                      textAlign: TextAlign.center,
                      //values.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Glacial',
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      )),
                  ),
                  const SizedBox(width: 6), 
                  Icon(
                    Icons.air,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    size: 22.0,
                  ),
                ],
              )
              ],
            )
      );
  }
  
}