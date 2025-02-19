import 'package:flutter/material.dart';
import 'package:respire/components/BaseTile.dart';

class AddPresetTile extends StatelessWidget
{

  final GestureTapCallback onClick;
  final Color color;

  const AddPresetTile({
    super.key,
    required this.onClick,
    this.color = const Color.fromRGBO(0, 195, 255, 1)}
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