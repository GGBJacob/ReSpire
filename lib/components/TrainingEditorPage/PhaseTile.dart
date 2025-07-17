import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  FocusNode? repsFocusNode;
  FocusNode? incrementFocusNode;

  @override
  void initState() {
    super.initState();
    repsController = TextEditingController(text: widget.phase.reps.toString());
    incrementController = TextEditingController(text: widget.phase.increment.toString());
    repsFocusNode = FocusNode();
    incrementFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(PhaseTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase.reps != widget.phase.reps && !repsFocusNode!.hasFocus) {
      repsController.text = widget.phase.reps.toString();
    }
    if (oldWidget.phase.increment != widget.phase.increment && !incrementFocusNode!.hasFocus) {
      incrementController.text = widget.phase.increment.toString();
    }
  }

  @override
  void dispose() {
    repsController.dispose();
    incrementController.dispose();
    repsFocusNode?.dispose();
    incrementFocusNode?.dispose();
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
    // Clear focus when adding new step to prevent keyboard conflicts
    FocusScope.of(context).unfocus();
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
                key: ValueKey('reps_${widget.phase.hashCode}'),
                controller: repsController,
                focusNode: repsFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  int? newReps = int.tryParse(value);
                  if (newReps != null) {
                    widget.phase.reps = newReps;
                  }
                },
                onEditingComplete: () {
                  widget.onUpdate();
                },
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                  widget.onUpdate();
                },
                style: TextStyle(color: darkerblue),
              ),
            ),
            SizedBox(width: 8),
            Text("Inc: ",  style: TextStyle(fontWeight: FontWeight.bold, color: darkerblue)),
            Container(
              width: 50,
              child: TextField(
                key: ValueKey('increment_${widget.phase.hashCode}'),
                controller: incrementController,
                focusNode: incrementFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
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
                    widget.phase.increment = newIncrement;
                  }
                },
                onEditingComplete: () {
                  widget.onUpdate();
                },
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                  widget.onUpdate();
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
