import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as respire;
import 'package:respire/components/TrainingEditorPage/StepTile.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
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
  TranslationProvider translationProvider = TranslationProvider();

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

  void removeStep(int index) async{
      bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.StepTile.remove_step_dialog_title")),
          backgroundColor: Colors.white,
          content: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.StepTile.remove_step_dialog_content")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(translationProvider.getTranslation("PopupButton.cancel"), style: TextStyle(color: darkerblue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(translationProvider.getTranslation("PopupButton.remove"), style: TextStyle(color: darkerblue)),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
      widget.phase.steps.removeAt(index);
    });
      widget.onUpdate();
    }
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
            
            // Repetitions Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translationProvider.getTranslation("TrainingEditorPage.TrainingTab.PhaseTile.reps"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkerblue,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Container(
                  width: 80,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: darkerblue, width: 1),
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            int currentValue = int.tryParse(repsController.text) ?? 1;
                            int newValue = (currentValue - 1).clamp(1, 999);
                            repsController.text = newValue.toString();
                            setState(() {
                              widget.phase.reps = newValue;
                            });
                            widget.onUpdate();
                          },
                          child: Container(
                            width: 24,
                            height: 35,
                            child: Icon(
                              Icons.remove,
                              color: darkerblue,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          key: ValueKey('reps_${widget.phase.hashCode}'),
                          controller: repsController,
                          focusNode: repsFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: darkerblue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          onChanged: (value) {
                            int? newReps = int.tryParse(value);
                            if (newReps != null && newReps > 0) {
                              setState(() {
                                widget.phase.reps = newReps;
                              });
                            }
                          },
                          onEditingComplete: () {
                            widget.onUpdate();
                          },
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                            widget.onUpdate();
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            int currentValue = int.tryParse(repsController.text) ?? 1;
                            int newValue = (currentValue + 1).clamp(1, 999);
                            repsController.text = newValue.toString();
                            setState(() {
                              widget.phase.reps = newValue;
                            });
                            widget.onUpdate();
                          },
                          child: Container(
                            width: 24,
                            height: 35,
                            child: Icon(
                              Icons.add,
                              color: darkerblue,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(width: 12),
            
            // Increment Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translationProvider.getTranslation("TrainingEditorPage.TrainingTab.PhaseTile.increment"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkerblue,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Container(
                  width: 80,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: darkerblue, width: 1),
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            int currentValue = int.tryParse(incrementController.text) ?? 0;
                            int newValue = (currentValue - 1).clamp(0, 100);
                            incrementController.text = newValue.toString();
                            setState(() {
                              widget.phase.increment = newValue;
                            });
                            widget.onUpdate();
                          },
                          child: Container(
                            width: 24,
                            height: 35,
                            child: Icon(
                              Icons.remove,
                              color: darkerblue,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          key: ValueKey('increment_${widget.phase.hashCode}'),
                          controller: incrementController,
                          focusNode: incrementFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: darkerblue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          onChanged: (value) {
                            int? newIncrement = int.tryParse(value);
                            if (newIncrement != null && newIncrement >= 0 && newIncrement <= 100) {
                              setState(() {
                                widget.phase.increment = newIncrement;
                              });
                            }
                          },
                          onEditingComplete: () {
                            widget.onUpdate();
                          },
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                            widget.onUpdate();
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            int currentValue = int.tryParse(incrementController.text) ?? 0;
                            int newValue = (currentValue + 1).clamp(0, 100);
                            incrementController.text = newValue.toString();
                            setState(() {
                              widget.phase.increment = newValue;
                            });
                            widget.onUpdate();
                          },
                          child: Container(
                            width: 24,
                            height: 35,
                            child: Icon(
                              Icons.add,
                              color: darkerblue,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              translationProvider.getTranslation("TrainingEditorPage.TrainingTab.PhaseTile.add_step_button_label"),
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
