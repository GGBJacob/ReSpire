import 'package:flutter/material.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/TrainingEditorPage/AudioSelectionDropdown.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';
import 'package:respire/services/SoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TrainingEditorPage extends StatefulWidget {
  final Training training;

  const TrainingEditorPage({
    Key? key,
    required this.training,
  }) : super(key: key);

  @override
  _TrainingEditorPageState createState() => _TrainingEditorPageState();
}

class _TrainingEditorPageState extends State<TrainingEditorPage> {
  late List<Phase> phases;
  late TextEditingController descriptionController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _descriptionFocusNode = FocusNode();

  int _selectedTab = 0;
  // Sound tab state
  final List<String> _soundOptions = SoundManager().getAvailableSounds();
  late Sounds _sounds;

  // Next step sound options (internal values kept capitalized for backward compatibility)
  final List<String> _showNextStepSoundOptions = ["None", "Global", "For each phase"];

  // Counting sounds options (internal values capitalized)
  final List<String> _countingSoundOptions = ["None", "Voice", "Tic", "Gong"];

  //To remove, when tic and gong sounds will be added
  final disabledOptions = {'Tic', 'Gong'};
  
  // Other tab state
  bool _showNextStepToggle = false;
  bool _showChartToggle = false;
  bool _showStepColorsToggle = false;
  bool _countingSounds = true;

  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    phases = widget.training.phases;
    _sounds = widget.training.sounds;
    descriptionController = TextEditingController(text: widget.training.description);
  }

  void addPhase() {
    setState(() {
      phases.add(Phase(reps: 3, steps: [], increment: 0));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      // Clear any active focus when adding new phase to prevent keyboard issues
      FocusScope.of(context).unfocus();
    });
  }

  void removePhase(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.remove_phase_dialog_title")),
          content: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.remove_phase_dialog_content")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(translationProvider.getTranslation("PopupButton.cancel")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(translationProvider.getTranslation("PopupButton.remove")),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        phases.removeAt(index);
      });
    }
  }

  void reorderPhase(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final phase = phases.removeAt(oldIndex);
      phases.insert(newIndex, phase);
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  
  void showEditTitleDialog(BuildContext context) {
    final tempController = TextEditingController(text: widget.training.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          translationProvider.getTranslation("TrainingEditorPage.TrainingTab.edit_title_dialog_title"),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkerblue),
        ),
        content: TextField(
          controller: tempController,
          autofocus: true,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: darkerblue,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: darkerblue,
                width: 2.0,
              ),
            ),
            hintText: translationProvider.getTranslation("TrainingEditorPage.TrainingTab.edit_title_dialog_hint"),
          ),
        ),
        actions: [
          TextButton(
            child: Text(translationProvider.getTranslation("PopupButton.cancel"), style: TextStyle(color: darkerblue)),
            onPressed: () => Navigator.of(context).pop(), // discard changes
          ),
          ElevatedButton(
            child: Text(translationProvider.getTranslation("PopupButton.save"), style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: darkerblue),
            onPressed: () {
              setState(() {
                widget.training.title = tempController.text.trim();
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Automatically return updated training when popping
        Navigator.pop(context, widget.training);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.training.title,
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: darkerblue),
              onPressed: () => showEditTitleDialog(context),
              splashRadius: 20,
            ),
          ],
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Container(
          color: lightblue,
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CustomSlidingSegmentedControl<int>(
                  children: {
                    0: Text(translationProvider.getTranslation("TrainingEditorPage.tab.training"), style: TextStyle(color: _selectedTab==0?darkerblue:Colors.white, fontWeight:  _selectedTab==0?FontWeight.bold:FontWeight.normal)),
                    1: Text(translationProvider.getTranslation("TrainingEditorPage.tab.sounds"), style: TextStyle(color: _selectedTab==1?darkerblue:Colors.white, fontWeight:  _selectedTab==1?FontWeight.bold:FontWeight.normal)),
                    2: Text(translationProvider.getTranslation("TrainingEditorPage.tab.other"), style: TextStyle(color: _selectedTab==2?darkerblue:Colors.white, fontWeight:  _selectedTab==2?FontWeight.bold:FontWeight.normal)),
                  },
                  initialValue: _selectedTab,
                  onValueChanged: (val) {
                    // Clear focus first so TextFields lose focus and commit
                    FocusScope.of(context).unfocus();
                    setState(() => _selectedTab = val);
                  },
                  decoration: BoxDecoration(
                    color: darkerblue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  innerPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                ),
              ),
              SizedBox(height: 2),
              Expanded(
                child: _selectedTab == 0
                    ? ReorderableListView(
                        scrollController: _scrollController,
                        onReorder: reorderPhase,
                        proxyDecorator: (child, idx, anim) => Material(color: Colors.transparent, child: child), //removes shadow when dragging tile
                        padding: EdgeInsets.only(bottom: 80),
                        children: [
                          for (int index = 0; index < phases.length; index++)
                            PhaseTile(
                              key: ValueKey('phase_$index'),
                              phase: phases[index],
                              onDelete: () => removePhase(index),
                              onUpdate: () {
                                setState(() => widget.training.phases = phases);
                              },
                            ),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: _selectedTab == 1 ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.title"),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text(translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.background_sound"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(), 
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: const Color.fromARGB(123, 26, 147, 168))),//darkerblue)),
                                            dropdownStyleData: DropdownStyleData(        
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          value: _sounds.backgroundSound, 
                                          items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: null)],//(v) => setState(() => _sounds.backgroundSound = v!))],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text(translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.preparation_sound"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(),
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: const Color.fromARGB(123, 26, 147, 168))),
                                            dropdownStyleData: DropdownStyleData(       
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ), 
                                          value: _sounds.preparationSound, 
                                          items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: null)],//(v) => setState(() => _sounds.preparationSound = v!))],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text(translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.counting_sound"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(), 
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),//darkerblue)),
                                            dropdownStyleData: DropdownStyleData(        
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          value: _sounds.countingSound, 
                                          items: _countingSoundOptions.map((s) {
                                            final isDisabled = disabledOptions.contains(s);
                                            final key = s.toLowerCase();
                                            return DropdownMenuItem(
                                              value: s,
                                              enabled: !isDisabled,
                                              child: Text(
                                                translationProvider.getTranslation("TrainingEditorPage.SoundOption.$key"),
                                                style: TextStyle(
                                                  color: isDisabled ? Colors.grey : Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (v) {
                                            if (v == null) return;
                                            if (disabledOptions.contains(v)) return; 
                                            setState(() => _sounds.countingSound = v);
                                          },
                                        )],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                translationProvider.getTranslation("TrainingEditorPage.SoundsTab.StepSounds.title"),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.inhale"), style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold)),  
                                      AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.inhaleSound, onChanged: (v) => setState(() { _sounds.inhaleSound = v!; SoundManager().stopAllSounds();})),
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.retention"), style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold)), 
                                      AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.retentionSound, onChanged: (v) => setState(() { _sounds.retentionSound = v!; SoundManager().stopAllSounds();})),
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.exhale"), style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold)), 
                                      AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.exhaleSound, onChanged: (v) => setState(() { _sounds.exhaleSound = v!; SoundManager().stopAllSounds();})),
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.recovery"), style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold)), 
                                      AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.recoverySound, onChanged: (v) => setState(() { _sounds.recoverySound = v!; SoundManager().stopAllSounds();})),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Row(
                                children: [
                                  Text(
                                    translationProvider.getTranslation("TrainingEditorPage.SoundsTab.NextStepSounds.title"),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  SizedBox(width: 8),
                                  DropdownButton2<String>(
                                    buttonStyleData: ButtonStyleData(
                                      height: 40,
                                      width: 160,
                                      elevation: 2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                          underline: SizedBox(),
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                            dropdownStyleData: DropdownStyleData(       
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ), 
                                          value: _sounds.nextSound, 
                                          items: _showNextStepSoundOptions.map((s) {
                                            String key;
                                            if (s == "For each phase") {
                                              key = "for_each_phase";
                                            } else {
                                              key = s.toLowerCase();
                                            }
                                            return DropdownMenuItem(
                                              value: s,
                                              child: Text(translationProvider.getTranslation("TrainingEditorPage.SoundsTab.NextStepSounds.$key")),
                                            );
                                          }).toList(),
                                          onChanged: (v) => setState(() => _sounds.nextSound = v!))],
                              ),
                            ),
                            if (_sounds.nextSound.toLowerCase() !="none")...[
                              SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Column(
                                  children: [
                                    if(_sounds.nextSound.toLowerCase()=="global") ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text(translationProvider.getTranslation("TrainingEditorPage.SoundsTab.NextStepSounds.next_step_sound_label"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(),
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color:Color.fromARGB(123, 26, 147, 168))),
                                            dropdownStyleData: DropdownStyleData(       
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ), 
                                          value: _sounds.nextGlobalSound, 
                                          items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: null)],//(v) => setState(() => _sounds.nextGlobalSound = v!))],
                                    ),
                                    ] 
                                    else
                                    ...[Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.inhale"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),  
                                      //AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.inhaleSound, onChanged: (v) => setState(() { _sounds.nextInhaleSound = v!; SoundManager().stopAllSounds();})),
                                      Opacity(
                                        opacity: 0.5, 
                                        child: IgnorePointer(
                                          child: AudioSelectionDropdown(
                                            items: _soundOptions,
                                            selectedValue: _sounds.inhaleSound,
                                            onChanged: (_) {}, 
                                          ),
                                        ),
                                      )
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.retention"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), 
                                      //AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.inhaleSound, onChanged: (v) => setState(() { _sounds.nextRetentionSound = v!; SoundManager().stopAllSounds();})),
                                      Opacity(
                                        opacity: 0.5, 
                                        child: IgnorePointer(
                                          child: AudioSelectionDropdown(
                                            items: _soundOptions,
                                            selectedValue: _sounds.retentionSound,
                                            onChanged: (_) {}, 
                                          ),
                                        ),
                                      )
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.exhale"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), 
                                      //AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.exhaleSound, onChanged: (v) => setState(() { _sounds.nextExhaleSound = v!; SoundManager().stopAllSounds();})),
                                      Opacity(
                                        opacity: 0.5, 
                                        child: IgnorePointer(
                                          child: AudioSelectionDropdown(
                                            items: _soundOptions,
                                            selectedValue: _sounds.exhaleSound,
                                            onChanged: (_) {}, 
                                          ),
                                        ),
                                      )
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translationProvider.getTranslation("StepType.recovery"), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), 
                                      //AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.inhaleSound, onChanged: (v) => setState(() { _sounds.nextRecoverySound = v!; SoundManager().stopAllSounds();})),
                                      Opacity(
                                        opacity: 0.5, 
                                        child: IgnorePointer(
                                          child: AudioSelectionDropdown(
                                            items: _soundOptions,
                                            selectedValue: _sounds.recoverySound,
                                            onChanged: (_) {}, 
                                          ),
                                        ),
                                      )
                                    ]),],
                                  ],
                                ),
                              ),
                            ),
                            ]
                          ],
                        ) : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Description field
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.training_description_label"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkblue)),
                                    ),
                                    TextField(
                                      controller: descriptionController,
                                      focusNode: _descriptionFocusNode,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: translationProvider.getTranslation("TrainingEditorPage.OtherTab.training_description_hint"),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8), 
                                          borderSide: BorderSide(
                                            color: darkgrey,
                                            width: 1.0, 
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8), 
                                          borderSide: BorderSide(
                                            color: darkerblue,
                                            width: 1.0, 
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        widget.training.description = value;
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.next_step_label")), value: _showNextStepToggle, activeColor: darkerblue, inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                          return mediumblue;
                                        } return null;}), 
                                      onChanged: null),//(v) => setState(() => _showNextStepToggle = v)),
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.chart_label")), value: _showChartToggle, activeColor: darkerblue, inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                          return mediumblue;
                                        } return null;}),
                                      onChanged: null), //(v) => setState(() => _showChartToggle = v)),
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.step_colors_label")), value: _showStepColorsToggle, activeColor: darkerblue,inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                          return mediumblue;
                                        } return null;}),
                                      onChanged: null),//(v) => setState(() => _showStepColorsToggle = v)),
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.counting_sound_label")), value: _countingSounds, activeColor: darkerblue,inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                    WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                      if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                        return mediumblue;
                                      } return null;}),
                                    onChanged: (v) => setState(() => _countingSounds = v)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: _selectedTab == 0
             ? FloatingActionButton.extended(
                 onPressed: addPhase,
                 backgroundColor: darkerblue,
                 label: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.add_phase_button_label"), style: TextStyle(color: Colors.white)),
                 icon: Icon(Icons.add, color: Colors.white),
               )
             : null,
      ),
    );
  }
}

