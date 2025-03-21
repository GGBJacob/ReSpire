import 'package:flutter/material.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as respire;
import 'package:respire/components/TrainingEditorPage/StepTile.dart';

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

  @override
  void initState() {
    super.initState();
    repsController =
        TextEditingController(text: widget.phase.reps.toString());
  }

  @override
  void dispose() {
    repsController.dispose();
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
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Text("Reps: "),
            Container(
              width: 50,
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                ),
                onSubmitted: (value) {
                  int? newReps = int.tryParse(value);
                  if (newReps != null) {
                    setState(() {
                      widget.phase.reps = newReps;
                    });
                    widget.onUpdate();
                  }
                },
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
          ],
        ),
        children: [
          ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            onReorder: reorderStep,
            children: [
              for (int index = 0;
                  index < widget.phase.steps.length;
                  index++)
                StepTile(
                  key: ValueKey('step_$index'),
                  step: widget.phase.steps[index],
                  onStepChanged: (newStep) => updateStep(index, newStep),
                  onDelete: () => removeStep(index),
                  onUpdate: widget.onUpdate,
                ),
            ],
          ),
          TextButton.icon(
            onPressed: addStep,
            icon: Icon(Icons.add),
            label: Text("Add step"),
          ),
        ],
      ),
    );
  }
}
