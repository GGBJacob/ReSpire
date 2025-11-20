import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart' as respire;
import 'package:respire/components/TrainingEditorPage/BreathingPhaseTile.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart'; 

class TrainingStageTile extends StatefulWidget {
  final TrainingStage trainingStage;
  final int trainingStageIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  final int trainingStageNameMaxLength = 25;

  const TrainingStageTile({
    Key? key,
    required this.trainingStage,
    required this.trainingStageIndex,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _TrainingStageTileState createState() => _TrainingStageTileState();
}

class _TrainingStageTileState extends State<TrainingStageTile> {
  late TextEditingController repsController;
  late TextEditingController incrementController;
  late TextEditingController nameController;
  late double incrementDuration;
  FocusNode? repsFocusNode;
  FocusNode? incrementFocusNode;
  FocusNode? nameFocusNode;
  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    repsController = TextEditingController(text: widget.trainingStage.reps.toString());
    incrementController = TextEditingController(text: widget.trainingStage.increment.toString());
    // Initialize with actual name or default name
    nameController = TextEditingController(text: _getInitialName());
    repsFocusNode = FocusNode();
    incrementFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    repsFocusNode!.addListener(() {
      if (!(repsFocusNode?.hasFocus ?? true)) {
        final value = int.tryParse(repsController.text);
        if (value != null && value > 0) {
          setState(() => widget.trainingStage.reps = value);
        }
        widget.onUpdate();
      }
    });
    incrementFocusNode!.addListener(() {
      if (!(incrementFocusNode?.hasFocus ?? true)) {
        final value = double.tryParse(incrementController.text) ?? 0;
        if (value >= 0 && value <= 100) {
          setState(() => widget.trainingStage.increment = value);
        }
        widget.onUpdate();
      }
    });
    nameFocusNode!.addListener(() {
      if (!(nameFocusNode?.hasFocus ?? true)) {
        setState(() => widget.trainingStage.name = nameController.text);
        widget.onUpdate();
      }
    });
    incrementDuration = widget.trainingStage.increment;
  }

  @override
  void didUpdateWidget(TrainingStageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trainingStage.reps != widget.trainingStage.reps && !repsFocusNode!.hasFocus) {
      repsController.text = widget.trainingStage.reps.toString();
    }
    if (oldWidget.trainingStage.increment != widget.trainingStage.increment && !incrementFocusNode!.hasFocus) {
      incrementController.text = widget.trainingStage.increment.toString();
    }
    if (oldWidget.trainingStage.name != widget.trainingStage.name && !nameFocusNode!.hasFocus) {
      nameController.text = _getInitialName();
    }
    // Update if training stage index changed (reordering)
    if (oldWidget.trainingStageIndex != widget.trainingStageIndex && !nameFocusNode!.hasFocus) {
      nameController.text = _getInitialName();
    }
  }

  @override
  void dispose() {
    repsController.dispose();
    incrementController.dispose();
    nameController.dispose();
    repsFocusNode?.dispose();
    incrementFocusNode?.dispose();
    nameFocusNode?.dispose();
    super.dispose();
  }

  void commitIncrementDurationChange() {
    double newDuration = incrementDuration;

    incrementDuration = (newDuration * 10).roundToDouble() / 10;

    widget.trainingStage.increment = incrementDuration;
    incrementDuration = incrementDuration.clamp(0.1, double.infinity);

    incrementController.text = incrementDuration.toStringAsFixed(1);
    
    widget.onUpdate();
  }

  void addBreathingPhase() {
    setState(() {
      widget.trainingStage.breathingPhases.add(
        respire.BreathingPhase(
          duration: 5.0,
          breathingPhaseType: respire.BreathingPhaseType.inhale,
        ),
      );
    });
    // Clear focus when adding new breathing phase to prevent keyboard conflicts
    FocusScope.of(context).unfocus();
    widget.onUpdate();
  }

  void removeBreathingPhase(int index) async{
      bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.BreathingPhaseTile.remove_breathing_phase_dialog_title")),
          backgroundColor: Colors.white,
          content: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.BreathingPhaseTile.remove_breathing_phase_dialog_content")),
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
      widget.trainingStage.breathingPhases.removeAt(index);
    });
      widget.onUpdate();
    }
  }

  void updateBreathingPhase(int index, respire.BreathingPhase newBreathingPhase) {
    setState(() {
      widget.trainingStage.breathingPhases[index] = newBreathingPhase;
    });
    widget.onUpdate();
  }

  void reorderBreathingPhase(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final breathingPhase = widget.trainingStage.breathingPhases.removeAt(oldIndex);
      widget.trainingStage.breathingPhases.insert(newIndex, breathingPhase);
    });
    widget.onUpdate();
  }

  String _getInitialName() {
    final trimmed = widget.trainingStage.name.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    // Return the default generated name
    final template = translationProvider.getTranslation("TrainingEditorPage.TrainingTab.default_training_stage_name");
    if (template.contains('{number}')) {
      return template.replaceAll('{number}', (widget.trainingStageIndex + 1).toString());
    }
    return 'Stage ${widget.trainingStageIndex + 1}';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage Name Section (First Row)
            Row(
              children: [
                ReorderableDragStartListener(
                  index: 0,
                  child: Icon(Icons.drag_handle, color: darkerblue),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translationProvider.getTranslation("TrainingEditorPage.TrainingTab.TrainingStageTile.name"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkerblue,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: darkerblue, width: 1),
                        ),
                        child: TextField(
                          controller: nameController,
                          focusNode: nameFocusNode,
                          maxLength: widget.trainingStageNameMaxLength,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                            counterText: '',
                          ),
                          style: TextStyle(
                            color: darkerblue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          onChanged: (value) {
                            setState(() {
                              widget.trainingStage.name = value;
                            });
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
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          '${nameController.text.length}/${widget.trainingStageNameMaxLength} ${translationProvider.getTranslation("TrainingEditorPage.TrainingTab.TrainingStageTile.characters")}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                  icon: Icon(Icons.delete_outlined, color: darkerblue),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            SizedBox(height: 8),
            // Reps and Increment Section (Second Row)
            Row(
              children: [
                SizedBox(width: 40), // Align with content after drag handle
                // Repetitions Section
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translationProvider.getTranslation("TrainingEditorPage.TrainingTab.TrainingStageTile.reps"),
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
                              widget.trainingStage.reps = newValue;
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
                          key: ValueKey('reps_${widget.trainingStage.hashCode}'),
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
                                widget.trainingStage.reps = newReps;
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
                              widget.trainingStage.reps = newValue;
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
                  translationProvider.getTranslation("TrainingEditorPage.TrainingTab.TrainingStageTile.increment"),
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
                            double currentValue = double.tryParse(incrementController.text) ?? 0;
                            double newValue = currentValue <= 1 ?
                            (currentValue - 0.1).clamp(0, 100) : (currentValue - 1).clamp(0, 100);
                            newValue = (newValue * 10).roundToDouble() / 10;
                            incrementController.text = newValue.toString();
                            setState(() {
                              widget.trainingStage.increment = newValue;
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
                          key: ValueKey('increment_${widget.trainingStage.hashCode}'),
                          controller: incrementController,
                          focusNode: incrementFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            CommaToDecimalFormatter(),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'))
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
                            double newIncrement = double.tryParse(value) ?? 0;
                            if (newIncrement >= 0 && newIncrement <= 100) {
                              setState(() {
                                newIncrement = (newIncrement * 10).roundToDouble() / 10;
                                incrementDuration = newIncrement;
                              });
                            }
                          },
                          onEditingComplete: () {
                            commitIncrementDurationChange();
                            widget.onUpdate();
                          },
                          onTapOutside: (event) {
                            commitIncrementDurationChange();
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
                            double currentValue = double.tryParse(incrementController.text) ?? 0;
                            double newValue = currentValue >= 1 ?
                            (currentValue + 1).clamp(0, 100) : (currentValue + 0.1).clamp(0, 100);
                            newValue = (newValue * 10).roundToDouble() / 10;
                            incrementController.text = newValue.toString();
                            setState(() {
                              widget.trainingStage.increment = newValue;
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
              ],
            ),
          ],
        ),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ReorderableListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              onReorder: reorderBreathingPhase,
               proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Material(
                  color: Colors.transparent,  
                  child: child,
                );
              },
              children: [
                for (int index = 0; index < widget.trainingStage.breathingPhases.length; index++)
                  BreathingPhaseTile(
                    key: ValueKey(widget.trainingStage.breathingPhases[index]),
                    breathingPhase: widget.trainingStage.breathingPhases[index],
                    onBreathingPhaseChanged: (newBreathingPhase) => updateBreathingPhase(index, newBreathingPhase),
                    onDelete: () => removeBreathingPhase(index),
                    onUpdate: widget.onUpdate,
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: addBreathingPhase,
            icon: Icon(Icons.add, color: darkerblue),
            label: Text(
              translationProvider.getTranslation("TrainingEditorPage.TrainingTab.TrainingStageTile.add_breathing_phase_button_label"),
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
