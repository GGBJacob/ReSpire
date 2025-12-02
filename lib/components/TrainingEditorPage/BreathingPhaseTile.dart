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

class BreathingPhaseTile extends StatefulWidget {
  final respire.BreathingPhase breathingPhase;
  final Function(respire.BreathingPhase newStep) onBreathingPhaseChanged;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const BreathingPhaseTile({
    Key? key,
    required this.breathingPhase,
    required this.onBreathingPhaseChanged,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _BreathingPhaseTileState createState() => _BreathingPhaseTileState();
}

class _BreathingPhaseTileState extends State<BreathingPhaseTile> {
  late TextEditingController durationController;
  FocusNode? durationFocusNode;
  late double currentDuration;
  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    currentDuration = widget.breathingPhase.duration;
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
  void didUpdateWidget(BreathingPhaseTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathingPhase.duration != widget.breathingPhase.duration &&
        !(durationFocusNode?.hasFocus ?? false)) {
      currentDuration = widget.breathingPhase.duration;
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

    currentDuration = currentDuration.clamp(0.3, double.infinity);

    durationController.text = currentDuration.toStringAsFixed(1);

    respire.BreathingPhase newBreathingPhase = respire.BreathingPhase(
      duration: currentDuration,
      increment: widget.breathingPhase.increment,
      breathingPhaseType: widget.breathingPhase.breathingPhaseType,
    );
    widget.onBreathingPhaseChanged(newBreathingPhase);
    widget.onUpdate();
  }

  void updateBreathingPhaseType(respire.BreathingPhaseType? newType) {
    if (newType != null) {
      respire.BreathingPhase newBreathingPhase = respire.BreathingPhase(
        duration: widget.breathingPhase.duration,
        increment: widget.breathingPhase.increment,
        breathingPhaseType: newType,
      );
      widget.onBreathingPhaseChanged(newBreathingPhase);
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
                  translationProvider.getTranslation("TrainingEditorPage.TrainingTab.BreathingPhaseTile.time"),
                  style: TextStyle(
                    color: greenblue,
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
                                double.tryParse(durationController.text) ?? 1.0;
                            if (currentValue <= 0.3) return;
                            double breathingPhase = currentValue <= 1 ? 0.1 : 0.5;
                            double newValue = (currentValue - breathingPhase)
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
                              'duration_${widget.breathingPhase.breathingPhaseType}'),
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
                            double breathingPhase = currentValue < 1 ? 0.1 : 0.5;
                            double newValue = (currentValue + breathingPhase)
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
                    translationProvider.getTranslation("TrainingEditorPage.TrainingTab.BreathingPhaseTile.type"),
                    style: TextStyle(
                      color: greenblue,
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
                    child: DropdownButton2<respire.BreathingPhaseType>(
                      value: widget.breathingPhase.breathingPhaseType,
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
                          border: Border.all(color: darkerblue),
                        ),
                      ),
                      items: respire.BreathingPhaseType.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  translationProvider.getTranslation("BreathingPhaseType.${e.toString().split('.').last}"),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ))
                          .toList(),
                      onChanged: (newType) {
                        updateBreathingPhaseType(newType);
                        widget.onUpdate();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
              icon: Icon(Icons.delete_outlined, color: darkerblue, size: 20),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
