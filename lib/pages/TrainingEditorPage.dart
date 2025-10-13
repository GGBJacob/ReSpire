import 'package:flutter/material.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';
import 'package:respire/components/TrainingEditorPage/SoundSelectionRow.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';
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
  late List<Phase> phases;
  late Settings settings;
  late TextEditingController preparationController;
  late TextEditingController descriptionController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _descriptionFocusNode = FocusNode();
  FocusNode? _preparationFocusNode;

  int _selectedTab = 0;
  // Sound tab state
  final List<String> _soundOptions = SoundManager().getAvailableSounds();
  late Sounds _sounds;

  TranslationProvider _translationProvider = TranslationProvider();

  //Next step sound options
  late Map<String,String?> _showNextStepSoundOptions = {};

  //Background sound options
  late Map<String,String?> _showBackgroundSoundOptions = {};

  // Counting sounds options (internal values capitalized)
  late final List<String> _countingSoundOptions = ["None", "Voice", "Tic", "Gong"];

  //To remove, when tic and gong sounds will be added
  final disabledOptions = {'Tic', 'Gong'};
  
  // Other tab state
  bool _showNextStepToggle = false;
  bool _showChartToggle = false;
  bool _showStepColorsToggle = false;

  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    _initializeStepSoundOptions();
    _initializeBackgroundSoundOptions();
    phases = widget.training.phases;
    _ensurePhaseNames();
    _sounds = widget.training.sounds;
    descriptionController = TextEditingController(text: widget.training.description);
    preparationController = TextEditingController(text: widget.training.settings.preparationDuration.toString());
    _preparationFocusNode = FocusNode();
  }

  void _initializeStepSoundOptions() {
    _showNextStepSoundOptions = {
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextPhaseSounds.none"): null,
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextPhaseSounds.global"): "global",
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextPhaseSounds.for_each_phase"): "phase",
    };
  }

    void _initializeBackgroundSoundOptions() {
    _showBackgroundSoundOptions = {
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.none"): null,
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.global"): "global",
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.stages"): "stages",
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.breathing_phases"): "breathing_phases",
    };
  }

  void saveTraining() {
    // TODO: implement actual saving logic, e.g., write to local storage or call an API
    print("Training saved: ${widget.training.title}");
  }

  void addPhase() {
    setState(() {
      final newPhaseIndex = phases.length;
      phases.add(Phase(
        reps: 3,
        steps: [],
        increment: 0,
        name: _defaultStageName(newPhaseIndex),
      ));
      _ensurePhaseNames();
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
        phases.removeAt(index);
        _ensurePhaseNames();
      });
    }
  }

  void reorderPhase(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final phase = phases.removeAt(oldIndex);
      phases.insert(newIndex, phase);
      _ensurePhaseNames();
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _ensurePhaseNames() {
    for (var i = 0; i < phases.length; i++) {
      if (phases[i].name.trim().isEmpty) {
        phases[i].name = _defaultStageName(i);
      }
    }
  }

  String _defaultStageName(int index) {
    final template = translationProvider
        .getTranslation("TrainingEditorPage.TrainingTab.default_stage_name");
    if (template.contains('{number}')) {
      return template.replaceAll('{number}', (index + 1).toString());
    }
    return "Stage ${index + 1}";
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
                                _ensurePhaseNames();
                                saveTraining();
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
                                    SoundSelectionRow(labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold), label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.counting_sound"), selectedValue: _sounds.countingSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.countingSound = v; })),
                                    Row(
                                        children: [
                                          Text(
                                            translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextPhaseSounds.title"),
                                            style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton2<String>(
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
                                                  value: _sounds.nextSound, 
                                                  items: _showNextStepSoundOptions.map((key, value) {
                                                    return MapEntry(key, DropdownMenuItem(value: value, child: Text(key)));
                                                  }).values.toList(),
                                                  onChanged: (v) => setState(() => _sounds.nextSound = v))],
                                      ),
                                    
                                    if (_sounds.nextSound != null && _sounds.nextSound != "voice")...[
                                      Column(
                                          children: [
                                            if(_sounds.nextSound=="global") ...[
                                              SoundSelectionRow(label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextPhaseSounds.global"), selectedValue: _sounds.nextGlobalSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.nextGlobalSound = v; }))
                                            ] 
                                            else
                                            ...[SoundSelectionRow(label: translationProvider.getTranslation("StepType.inhale"), selectedValue: _sounds.nextInhaleSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.nextInhaleSound = v; })),
                                            SoundSelectionRow(label: translationProvider.getTranslation("StepType.retention"), selectedValue: _sounds.nextRetentionSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.nextRetentionSound = v; })),
                                            SoundSelectionRow(label: translationProvider.getTranslation("StepType.exhale"), selectedValue: _sounds.nextExhaleSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.nextExhaleSound = v; })),
                                            SoundSelectionRow(label: translationProvider.getTranslation("StepType.recovery"), selectedValue: _sounds.nextRecoverySound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.nextRecoverySound = v ; })),
                                          ],
                                          ],
                                        ),
                                    ],
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
                                    SoundSelectionRow(labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold), label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.preparation_music"), selectedValue: _sounds.preparationSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.preparationSound = v; })),
                                    SoundSelectionRow(labelStyle: TextStyle(color: darkerblue, fontWeight: FontWeight.bold), label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.ending_music"), selectedValue: _sounds.endingSound, soundListType: SoundListType.shortSounds, onChanged:(v) => setState(() { _sounds.endingSound = v; })),
                                    Row(
                                        children: [
                                          Text(
                                            translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.title"),
                                            style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton2<String>(
                                            buttonStyleData: ButtonStyleData(
                                              height: 35,
                                              width: 240,
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
                                                  value: _sounds.backgroundOptionSound, 
                                                  items: _showBackgroundSoundOptions.map((key, value) {
                                                    return MapEntry(key, DropdownMenuItem(value: value, child: Text(key)));
                                                  }).values.toList(),
                                                  onChanged: (v) => setState(() => _sounds.backgroundOptionSound = v))],
                                      ),
                                      if (_sounds.backgroundOptionSound != null)...[
                                        Column(
                                              children: [
                                                if(_sounds.backgroundOptionSound=="global") ...[
                                                  SoundSelectionRow(label: translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.global"), selectedValue: _sounds.backgroundSound, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.backgroundSound = v; }))
                                                ] 
                                                else if(_sounds.backgroundOptionSound=="breathing_phases")
                                                ...[SoundSelectionRow(label: translationProvider.getTranslation("StepType.inhale"), selectedValue: _sounds.inhaleSound, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.inhaleSound = v; })),
                                                SoundSelectionRow(label: translationProvider.getTranslation("StepType.retention"), selectedValue: _sounds.retentionSound, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.retentionSound = v; })),
                                                SoundSelectionRow(label: translationProvider.getTranslation("StepType.exhale"), selectedValue: _sounds.exhaleSound, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.exhaleSound = v; })),
                                                SoundSelectionRow(label: translationProvider.getTranslation("StepType.recovery"), selectedValue: _sounds.recoverySound, soundListType: SoundListType.longSounds, onChanged:(v) => setState(() { _sounds.recoverySound = v ; })),
                                                ]
                                                else ...[
                                                  for (int i = 0; i < phases.length; i++)
                                                    SoundSelectionRow(
                                                      label: phases[i].name, 
                                                      selectedValue: (_sounds.backgroundStagesSounds != null &&
                                                                      _sounds.backgroundStagesSounds!.length > i)
                                                                  ? _sounds.backgroundStagesSounds![i]
                                                                  : null,
                                                      soundListType: SoundListType.longSounds,
                                                      onChanged: (v) {
                                                        setState(() {
                                                          if (_sounds.backgroundStagesSounds == null) {
                                                            _sounds.backgroundStagesSounds = List<String?>.filled(phases.length, null).cast<String>();
                                                          } else if (_sounds.backgroundStagesSounds!.length < phases.length) {
                                                            _sounds.backgroundStagesSounds!.length = phases.length;
                                                          }
                                                          _sounds.backgroundStagesSounds![i] = v;
                                                        });
                                                      },
                                                    ),
                                                ],
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
                 onPressed: addPhase,
                 backgroundColor: darkerblue,
                 label: Text(translationProvider.getTranslation("TrainingEditorPage.TrainingTab.add_stage_button_label"), style: TextStyle(color: Colors.white)),
                 icon: Icon(Icons.add, color: Colors.white),
               )
             : null,
      ),
    );
  }
}

