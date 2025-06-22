import 'package:flutter/material.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as respire;
import 'package:respire/components/TrainingEditorPage/StepTile.dart';
import 'package:respire/theme/Colors.dart'; 

class PhaseTile extends StatefulWidget {
  final Phase phase;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const PhaseTile({
    Key? key,
    required this.phase,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _PhaseTileState createState() => _PhaseTileState();
}

class _PhaseTileState extends State<PhaseTile> {
  late TextEditingController repsController;
  late TextEditingController incrementController;

  @override
  void initState() {
    super.initState();
    repsController = TextEditingController(text: widget.phase.reps.toString());
    incrementController = TextEditingController(text: widget.phase.increment.toString());
  }

  @override
  void dispose() {
    repsController.dispose();
    incrementController.dispose();
    super.dispose();
  }

  void addStep() {
    setState(() {
      widget.phase.steps.add(
        respire.Step(
          duration: 5.0,
          stepType: respire.StepType.inhale,
        ),
      );
    });
    widget.onUpdate();
  }

  void removeStep(int index) {
    setState(() {
      widget.phase.steps.removeAt(index);
    });
    widget.onUpdate();
  }

  void updateStep(int index, respire.Step newStep) {
    setState(() {
      widget.phase.steps[index] = newStep;
    });
    widget.onUpdate();
  }

  void reorderStep(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final step = widget.phase.steps.removeAt(oldIndex);
      widget.phase.steps.insert(newIndex, step);
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color.fromARGB(255, 255, 255, 255), 
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedIconColor: darkblue,
        iconColor: darkerblue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            ReorderableDragStartListener(
              index: 0,
              child: Icon(Icons.drag_handle, color: darkerblue),
            ),
            SizedBox(width: 8),
            Text("Reps: ", style: TextStyle(fontWeight: FontWeight.bold, color: darkerblue)),
            Container(
              width: 50,
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  int? newReps = int.tryParse(value);
                  if (newReps != null) {
                    setState(() {
                      widget.phase.reps = newReps;
                    });
                    widget.onUpdate();
                  }
                },
                style: TextStyle(color: darkerblue),
              ),
            ),
            SizedBox(width: 8),
            Text("Inc: ",  style: TextStyle(fontWeight: FontWeight.bold, color: darkerblue)),
            Container(
              width: 50,
              child: TextField(
                controller: incrementController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: '%',
                   suffixStyle: TextStyle(
                    color: darkerblue,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  int? newIncrement = int.tryParse(value);
                  if (newIncrement != null && newIncrement >= 0 && newIncrement <= 100) {
                    setState(() {
                      widget.phase.increment = newIncrement;
                    });
                    widget.onUpdate();
                  }
                },
                style: TextStyle(color: darkerblue),
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.delete, color: darkerblue),
              onPressed: widget.onDelete,
            ),
          ],
        ),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ReorderableListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              onReorder: reorderStep,
               proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Material(
                  color: Colors.transparent,  
                  child: child,
                );
              },
              children: [
                for (int index = 0; index < widget.phase.steps.length; index++)
                  StepTile(
                    key: ValueKey(widget.phase.steps[index]),
                    step: widget.phase.steps[index],
                    onStepChanged: (newStep) => updateStep(index, newStep),
                    onDelete: () => removeStep(index),
                    onUpdate: widget.onUpdate,
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: addStep,
            icon: Icon(Icons.add, color: darkerblue),
            label: Text(
              "Add step",
              style: TextStyle(
                color: darkerblue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
