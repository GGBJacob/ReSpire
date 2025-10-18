import 'package:flutter/material.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';
import 'package:respire/components/TrainingEditorPage/SoundSelectionRow.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
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
  late List<TrainingStage> trainingStages;
  late Settings settings;
  late TextEditingController preparationController;
  late TextEditingController descriptionController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _descriptionFocusNode = FocusNode();

  int _selectedTab = 0;
  late Sounds _sounds;
  
  // Other tab state
  bool _showNextBreathingPhaseToggle = false;
  bool _showChartToggle = false;
  bool _showBreathingPhaseColorsToggle = false;

  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    trainingStages = widget.training.trainingStages;
    _sounds = widget.training.sounds;
    descriptionController = TextEditingController(text: widget.training.description);
    preparationController = TextEditingController(text: widget.training.settings.preparationDuration.toString());
  }

  void addTrainingStage() {
    setState(() {
      trainingStages.add(TrainingStage(reps: 3, breathingPhases: [], increment: 0, name: "${translationProvider.getTranslation("TrainingPage.TrainingOverview.training_stage")} ${trainingStages.length + 1}"));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      // Clear any active focus when adding new breathing phase to prevent keyboard issues
      FocusScope.of(context).unfocus();
    });
  }

  void removeTrainingStage(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.remove_training_stage_dialog_title")),
          content: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.remove_training_stage_dialog_content")),
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
        trainingStages.removeAt(index);
      });
    }
  }

  void reorderTrainingStage(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final trainingStage = trainingStages.removeAt(oldIndex);
      trainingStages.insert(newIndex, trainingStage);
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
    bool isError = false; 
    const int titleMaxLength = 20;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            translationProvider.getTranslation("TrainingEditorPage.TrainingTab.edit_title_dialog_title"),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkerblue),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft, 
                    child: Text(
                      translationProvider.getTranslation("TrainingEditorPage.TrainingTab.error"),
                      style: TextStyle(color: darkred, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              TextField(
                controller: tempController,
                autofocus: true,
                maxLength: titleMaxLength,
                decoration: InputDecoration(
                  hintText: translationProvider.getTranslation("TrainingEditorPage.TrainingTab.edit_title_dialog_hint"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: darkerblue, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: darkerblue, width: 2.0),
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                translationProvider.getTranslation("PopupButton.cancel"),
                style: TextStyle(color: darkerblue),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(
                translationProvider.getTranslation("PopupButton.save"),
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: darkerblue),
              onPressed: () {
                String text = tempController.text.trim();

                if (text.isEmpty) {
                  setStateDialog(() {
                    isError = true;
                  });
                  return;
                }

                setState(() {
                  widget.training.title = text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
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
                        onReorder: reorderTrainingStage,
                        proxyDecorator: (child, idx, anim) => Material(color: Colors.transparent, child: child), //removes shadow when dragging tile
                        padding: EdgeInsets.only(bottom: 80),
                        children: [
                          for (int index = 0; index < trainingStages.length; index++)
                            TrainingStageTile(
                              key: ValueKey('stage_$index'),
                              trainingStage: trainingStages[index],
                              trainingStageIndex: index,
                              onDelete: () => removeTrainingStage(index),
                              onUpdate: () {
                                setState(() => widget.training.trainingStages = trainingStages);
                              },
                            ),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: _selectedTab == 1 ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Column(
                                  children: [
                                    Text(
                                      translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.title"),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    SoundSelectionRow(labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold), label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.counting_sound"), selectedValue: _sounds.countingSound.path, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.countingSound.path = v; })),
                                    Row(
                                        children: [
                                          Text(
                                            translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextBreathingPhaseSounds.title"),
                                            style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton2<SoundScope>(
                                            buttonStyleData: ButtonStyleData(
                                              height: 35,
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
                                                  value: _sounds.nextSoundScope,
                                                  items: SoundScopeX.nextPhaseScopeValues.map((e) => DropdownMenuItem(child: Text(e.name), value: e)).toList(),
                                                  onChanged: (v) => setState(() => _sounds.nextSoundScope = v!))],
                                      ),
                                    
                                    if (_sounds.nextSoundScope != SoundScope.none)...[
                                      Column(
                                          children: [
                                            if(_sounds.nextSoundScope == SoundScope.global)
                                              ((){
                                                _sounds.nextSound.type = SoundType.cue;
                                                return SoundSelectionRow(label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextBreathingPhaseSounds.global"), selectedValue: _sounds.nextSound.path, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.nextSound.path = v; }));})()
                                            else if (_sounds.nextSoundScope == SoundScope.perPhase)
                                              ...buildPhaseSoundRows(SoundListType.shortSounds)
                                          ],
                                        ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Column(
                                  children: [
                                    Text(
                                      translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.title"),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    SoundSelectionRow(labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold), label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.preparation_music"), selectedValue: _sounds.preparationTrack.path, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.preparationTrack.path = v; })),
                                    SoundSelectionRow(labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold), label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.ending_music"), selectedValue: _sounds.endingTrack.path, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.endingTrack.path = v; })),
                                    Row(
                                        children: [
                                          Text(
                                            translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.title"),
                                            style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton2<SoundScope>(
                                            buttonStyleData: ButtonStyleData(
                                              height: 35,
                                              width: 200,
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
                                                  value: _sounds.backgroundSoundScope, 
                                                  items: SoundScope.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                                                  onChanged: (v) => setState(() => _sounds.backgroundSoundScope = v!))],
                                      ),
                                      if (_sounds.backgroundSoundScope != SoundScope.none)...[
                                        Column(
                                              children: [
                                                if(_sounds.backgroundSoundScope == SoundScope.global) ...[
                                                  SoundSelectionRow(label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.global"), selectedValue: _sounds.trainingBackgroundTrack.path, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.trainingBackgroundTrack.path = v; }))
                                                ] 
                                                else if(_sounds.backgroundSoundScope == SoundScope.perPhase)
                                                  ...buildPhaseSoundRows(SoundListType.longSounds)
                                                else if(_sounds.backgroundSoundScope == SoundScope.perStage)
                                                  ...buildStageSoundsRows()
                                                ,
                                          ],
                                        ),
                                    ],
                                    ],
                                  
                                ),
                              ),
                            ),
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
                                      alignment: Alignment.center,
                                      child: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.training_description_label"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkblue)),
                                    ),
                                    SizedBox(height: 5),
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
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.next_breathing_phase_label")), value: _showNextBreathingPhaseToggle, activeColor: darkerblue, inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                          return mediumblue;
                                        } return null;}), 
                                      onChanged: null),//(v) => setState(() => _showNextBreathingPhaseToggle = v)),
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.chart_label")), value: _showChartToggle, activeColor: darkerblue, inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                          return mediumblue;
                                        } return null;}),
                                      onChanged: null), //(v) => setState(() => _showChartToggle = v)),
                                    SwitchListTile(title: Text(translationProvider.getTranslation("TrainingEditorPage.OtherTab.breathing_phase_colors_label")), value: _showBreathingPhaseColorsToggle, activeColor: darkerblue,inactiveTrackColor: Colors.white, inactiveThumbColor: Colors.grey, trackOutlineColor: 
                                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
                                          return mediumblue;
                                        } return null;}),
                                      onChanged: null),//(v) => setState(() => _showBreathingPhaseColorsToggle = v)),
                                    ListTile(
                                      title: Text(
                                        translationProvider.getTranslation("TrainingEditorPage.OtherTab.preparation_duration_label")
                                      ),
                                      trailing: Container(
                                        width: 90,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: darkerblue, width: 2),
                                        ),
                                        child: Row(
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(18),
                                                onTap: () {
                                                  int currentValue = int.tryParse(preparationController.text) ?? 1;
                                                  int newValue = (currentValue - 1).clamp(1, 999);
                                                  preparationController.text = newValue.toString();
                                                  setState(() {
                                                    widget.training.settings.preparationDuration = newValue;
                                                  });
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(Icons.remove, size: 16),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  preparationController.text,
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(18),
                                                onTap: () {
                                                  int currentValue = int.tryParse(preparationController.text) ?? 1;
                                                  int newValue = (currentValue + 1).clamp(1, 999);
                                                  preparationController.text = newValue.toString();
                                                  setState(() {
                                                    widget.training.settings.preparationDuration = newValue;
                                                  });
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(Icons.add, size: 16),
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
                 onPressed: addTrainingStage,
                 backgroundColor: darkerblue,
                 label: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.add_training_stage_button_label"), style: TextStyle(color: Colors.white)),
                 icon: Icon(Icons.add, color: Colors.white),
               )
             : null,
      ),
    );
  }

  List<Widget> buildPhaseSoundRows(SoundListType type) {
    return [
      for (final phase in BreathingPhaseType.values)
        SoundSelectionRow(
          label: translationProvider.getTranslation("BreathingPhaseType.${phase.name}"),
          selectedValue: type == SoundListType.longSounds? 
            _sounds.breathingPhaseBackgrounds[phase]?.path :
            _sounds.breathingPhaseCues[phase]?.path,
          soundListType: type,
          onChanged: (v) {
            setState(() {
              type == SoundListType.longSounds ?
                _sounds.breathingPhaseBackgrounds[phase] =  SoundAsset(type: SoundType.melody, path: v) :
                _sounds.breathingPhaseCues[phase] = SoundAsset(type: SoundType.cue, path: v);
            });
          },
        ),
    ];
  }
  
  List<Widget> buildStageSoundsRows() {
    return [
      for (final stage in trainingStages)
        SoundSelectionRow(
          label: translationProvider.getTranslation(stage.name),
          selectedValue: _sounds.stageTracks[stage.id]?.path,
          soundListType: SoundListType.longSounds,
          onChanged: (v) {
            setState(() {
              _sounds.stageTracks[stage.id] = 
                SoundAsset(type: SoundType.melody, path: v);
            });
          },
        ),
    ];
  }
}