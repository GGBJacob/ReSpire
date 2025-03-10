import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/HomePage/BaseTile.dart';

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
    this.color = const Color.fromRGBO(0, 195, 255, 1)}
    );

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: 0.25, // delete button width (0< && <1)
          motion: StretchMotion(), 
          children: [
            SlidableAction(
            borderRadius: BorderRadius.circular(12),
            autoClose: true,
            onPressed: editTile,
            icon: Icons.edit,
            backgroundColor: const Color.fromARGB(255, 255, 208, 0),
            )]),
      endActionPane: ActionPane(
        extentRatio: 0.25, // delete button width (0< && <1)
          motion: StretchMotion(), 
          children: [
            SlidableAction(
            borderRadius: BorderRadius.circular(12),
            autoClose: true,
            onPressed: deleteTile,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            )]
      ),
      child:  BaseTile(
        onClick: onClick,
          child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  values.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
      )
    );
  }
  
}