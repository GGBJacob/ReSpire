import 'package:flutter/material.dart';
import 'package:respire/components/Global/Step.dart' as respire;
import 'package:respire/theme/Colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
    if (newDuration != null && newDuration >= 0.1) {
      double roundedDuration = (newDuration * 10).roundToDouble() / 10;
      respire.Step newStep = respire.Step(
        duration: roundedDuration,
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightblue, 
        borderRadius: BorderRadius.circular(30), 
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: 0,
            child: Icon(Icons.drag_handle, color: darkerblue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: durationController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Time (s)",
                labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: darkerblue),  // kolor gdy nie w focusie
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: darkerblue, width: 2),  // kolor i grubość w focusie
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                updateDuration(value);
                widget.onUpdate();
              },
            ),
          ),
          SizedBox(width: 12),
          DropdownButton2<respire.StepType>(
            value: widget.step.stepType,
            underline: SizedBox(), //removes grey underline
            iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
            dropdownStyleData: DropdownStyleData(
              //isOverButton: true,         
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: respire.StepType.values
                .map((e) => DropdownMenuItem(
                      child: Text(e.toString().split('.').last),
                      value: e,
                    ))
                .toList(),
            onChanged: (newType) {
              setState(() {
                updateStepType(newType);
              });
              widget.onUpdate();
            },
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete, color: const Color.fromARGB(255, 255, 255, 255)),
            onPressed: widget.onDelete,
          )
        ],
      ),
    );
  }
}
