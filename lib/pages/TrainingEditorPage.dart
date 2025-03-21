import 'dart:math';

import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/Circle.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/TrainingEditorPage/AddPhaseButton.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';

class TrainingEditorPage extends StatefulWidget{
  final Training training;
  
  const TrainingEditorPage({super.key, required this.training});

  @override
  State<StatefulWidget> createState() => _TrainingEditorPageState(training: training);
}

class _TrainingEditorPageState extends State<TrainingEditorPage>
{
  final Training training;
  _TrainingEditorPageState({required this.training});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: () {
            //Navigator.pop(context); 
            Navigator.pop(context);
          },
        ),
        title: Center(child: Row(children: [
          Text(training.title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(" editing ", style: TextStyle(fontWeight: FontWeight.w400),),
        ],)),
        backgroundColor: Colors.grey,
      ),
      body: Center(child: 
        ListView.builder(
          itemCount: training.phases.length + 1,
          itemBuilder: (context, index)
          {
            return Padding(
              padding: EdgeInsets.all(5), // padding between elements / screen
              child: index < training.phases.length ?
              
              PhaseTile(
                phase: training.phases[index],
                deleteTile: (context) => {
                        training.phases.removeAt(index),
                        setState(() {
                    }),
                },
              ) :
            
              AddPhaseButton(onClick: () {
                training.phases.add(Phase(reps: 1, steps: []));
                setState(() {});
              })
            );
          }
        )
      ,)
    );
  }
}