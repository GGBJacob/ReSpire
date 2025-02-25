import 'package:flutter/material.dart';
import 'package:respire/components/Circle.dart';
import 'package:respire/components/PresetEntry.dart';

class BreathingPage extends StatefulWidget{
  final PresetEntry tile;
  
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

Widget descriptionSection(PresetEntry tile) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tile.title, 
          style: TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Breaths: ${tile.breathCount}   |   Retention: ${tile.retentionTime} sec\nInhale: ${tile.inhaleTime} sec   |   Exhale: ${tile.exhaleTime} sec",
          style: TextStyle(
            fontSize: 16 
          ),
        ),
      ],
    ),
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
          descriptionSection(widget.tile),
          Circle(tile: widget.tile)
         ]
      ),
    );
  }
}