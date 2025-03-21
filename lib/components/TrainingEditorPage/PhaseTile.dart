import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/HomePage/BaseTile.dart';

class PhaseTile extends StatelessWidget
{

  final Function(BuildContext)? deleteTile;
  final Color color;
  final Phase phase;

  const PhaseTile({
    super.key,
    required this.deleteTile,
    required this.phase,
    this.color = const Color.fromRGBO(0, 195, 255, 1)}
    );

  @override
  Widget build(BuildContext context) {
    return Slidable(
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
        onClick: () => {},
          child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phase",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
      )
    );
  }
  
}