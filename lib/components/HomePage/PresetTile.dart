import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/HomePage/BaseTile.dart';
import 'package:respire/theme/Colors.dart';

class PresetTile extends StatelessWidget
{

  final GestureTapCallback onClick;
  final Function(BuildContext)? deleteTile;
  final Function(BuildContext)? editTile;
  final Color color;
  final Training values;

  const PresetTile({
    super.key,
    required this.onClick,
    required this.deleteTile,
    required this.editTile,
    required this.values,
    this.color = const Color.fromARGB(255, 189, 36, 82)
    });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: 0.25, // delete button width (0< && <1)
          motion: StretchMotion(), 
          children: [
            SlidableAction(
            borderRadius: BorderRadius.circular(180),
            autoClose: true,
            onPressed: editTile,
            icon: Icons.edit,
            backgroundColor: lightblue,
            )]),
      endActionPane: ActionPane(
        extentRatio: 0.25, // delete button width (0< && <1)
          motion: StretchMotion(), 
          children: [
            SlidableAction(
            borderRadius: BorderRadius.circular(180),
            autoClose: true,
            onPressed: deleteTile,
            icon: Icons.delete,
            backgroundColor: darkerblue,
            )]
      ),
      child:  BaseTile(
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
                      color: darkblue,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 8), 
                  Text(
                    values.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 23,
                      color: darkblue,
                    ),
                  ),
                  const SizedBox(width: 8), 
                  Icon(
                    Icons.air,
                    color: darkblue,
                    size: 24.0,
                  ),
                ],
              )
              ],
            )
      )
    );
  }
  
}