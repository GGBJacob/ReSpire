import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as respire;

class StepTile extends StatefulWidget {
  final respire.Step step;
  final Function(respire.Step newStep) onStepChanged;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const StepTile({
    Key? key,
    required this.step,
    required this.onStepChanged,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _StepTileState createState() => _StepTileState();
}

class _StepTileState extends State<StepTile> {
  late TextEditingController durationController;

  @override
  void initState() {
    super.initState();
    durationController =
        TextEditingController(text: widget.step.duration.toString());
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  void updateDuration(String value) {
    double? newDuration = double.tryParse(value);
    if (newDuration != null) {
      respire.Step newStep = respire.Step(
        duration: newDuration,
        increment: widget.step.increment,
        stepType: widget.step.stepType,
        breathType: widget.step.breathType,
        breathDepth: widget.step.breathDepth,
      );
      widget.onStepChanged(newStep);
    }
  }

  void updateStepType(respire.StepType? newType) {
    if (newType != null) {
      respire.Step newStep = respire.Step(
        duration: widget.step.duration,
        increment: widget.step.increment,
        stepType: newType,
        breathType: widget.step.breathType,
        breathDepth: widget.step.breathDepth,
      );
      widget.onStepChanged(newStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: widget.key,
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Time (s)",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              onSubmitted: (value) {
                updateDuration(value);
                widget.onUpdate();
              },
            ),
          ),
          SizedBox(width: 8),
          DropdownButton<respire.StepType>(
            value: widget.step.stepType,
            items: respire.StepType.values
                .map((e) => DropdownMenuItem(
                      child: Text(e.toString().split('.').last),
                      value: e,
                    ))
                .toList(),
            onChanged: (newType) {
              updateStepType(newType);
              widget.onUpdate();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: widget.onDelete,
          )
        ],
      ),
    );
  }
}
