import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/Circle.dart';
import 'package:respire/components/Global/Training.dart';

class BreathingPage extends StatefulWidget{
  final Training tile;
  
  const BreathingPage({super.key, required this.tile});

  @override
  State<StatefulWidget> createState() => _BreathingPageState();
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Exit"),
        content: Text(
          "Are you sure you want exit?\nIf you click \"Yes\" your session will end.",
          textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context);
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  );
}


class _BreathingPageState extends State<BreathingPage>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: () {
            _showConfirmationDialog(context);
          },
        ),
        title: Text("ReSpire"),
        backgroundColor: Colors.grey,
      ),
      body: Column (
         children: [
          //Circle(tile: widget.tile)  //TODO: Uncomment and fix
         ]
      ),
    );
  }
}