import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:respire/components/Global/Step.dart' as respire;
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CommaToDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(',', '.');
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

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
  FocusNode? durationFocusNode;
  late double currentDuration;
  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    currentDuration = widget.step.duration;
    durationController =
        TextEditingController(text: currentDuration.toStringAsFixed(1));
    durationFocusNode = FocusNode();
    durationFocusNode!.addListener(() {
      if (!(durationFocusNode?.hasFocus ?? true)) {
        commitDurationChange();
      }
    });
  }

  @override
  void didUpdateWidget(StepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.duration != widget.step.duration &&
        !(durationFocusNode?.hasFocus ?? false)) {
      currentDuration = widget.step.duration;
      durationController.text = currentDuration.toString();
    }
  }

  @override
  void dispose() {
    durationController.dispose();
    durationFocusNode?.dispose();
    super.dispose();
  }

  void commitDurationChange() {
    double newDuration = currentDuration;

    if (newDuration > 0 && newDuration < 1) {
      currentDuration = (newDuration * 10).roundToDouble() / 10;
    } else if (newDuration >= 1) {
      currentDuration = (newDuration * 2).roundToDouble() / 2;
    }

    currentDuration = currentDuration.clamp(0.1, double.infinity);

    durationController.text = currentDuration.toStringAsFixed(1);

    respire.Step newStep = respire.Step(
      duration: currentDuration,
      increment: widget.step.increment,
      stepType: widget.step.stepType,
      breathType: widget.step.breathType,
      breathDepth: widget.step.breathDepth,
    );
    widget.onStepChanged(newStep);
    widget.onUpdate();
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
    return GestureDetector(
      onTap: () {
        // Hide keyboard when clicking outside field
        FocusScope.of(context).unfocus();
        // Save changes when clicking outside field
        commitDurationChange();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              child: Icon(Icons.drag_handle, color: darkerblue, size: 20),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translationProvider.getTranslation("TrainingEditorPage.TrainingTab.StepTile.time"),
                  style: TextStyle(
                    color: darkerblue,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 3),
                Container(
                  width: 100, // Fixed width for 4 digits
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: darkerblue),
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            double currentValue =
                                double.tryParse(durationController.text) ?? 0.1;
                            double step = currentValue <= 1 ? 0.1 : 0.5;
                            double newValue = (currentValue - step)
                                .clamp(0.1, double.infinity);
                            currentDuration = newValue;
                            commitDurationChange();
                          },
                          child: Container(
                            width: 24,
                            height: 32,
                            alignment: Alignment.center,
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
                          key: ValueKey(
                              'duration_${widget.step.stepType}_${widget.step.breathType}'),
                          controller: durationController,
                          focusNode: durationFocusNode,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            CommaToDecimalFormatter(),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: darkerblue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          onChanged: (value) {
                            currentDuration = double.tryParse(value) ?? 0.1;
                          },
                          onEditingComplete: () {
                            commitDurationChange();
                          },
                          onSubmitted: (value) {
                            commitDurationChange();
                          },
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                            commitDurationChange();
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            double currentValue =
                                double.tryParse(durationController.text) ?? 0.1;
                            double step = currentValue < 1 ? 0.1 : 0.5;
                            double newValue = (currentValue + step)
                                .clamp(0.1, double.infinity);
                            currentDuration = newValue;
                            commitDurationChange();
                          },
                          child: Container(
                            width: 24,
                            height: 32,
                            alignment: Alignment.center,
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
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translationProvider.getTranslation("TrainingEditorPage.TrainingTab.StepTile.type"),
                    style: TextStyle(
                      color: darkerblue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    height: 32, // Match the time input height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: darkerblue),
                    ),
                    child: DropdownButton2<respire.StepType>(
                      value: widget.step.stepType,
                      underline: SizedBox(),
                      isExpanded: true,
                      iconStyleData: IconStyleData(
                        icon: Icon(Icons.arrow_drop_down, color: darkerblue),
                        iconSize: 20,
                      ),
                      buttonStyleData: ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 32,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: respire.StepType.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  translationProvider.getTranslation("StepType.${e.toString().split('.').last}"),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ))
                          .toList(),
                      onChanged: (newType) {
                        updateStepType(newType);
                        widget.onUpdate();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.delete, color: darkerblue, size: 20),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
