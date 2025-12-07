import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/BreathingPhase.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/TrainingStage.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/TrainingEditorPage/TrainingStageTile.dart';
import 'package:respire/components/TrainingEditorPage/SoundSelectionRow.dart';
import 'package:respire/components/TrainingEditorPage/PlaylistEditor.dart';
import 'package:respire/components/TrainingEditorPage/StagePhaseSoundEditor.dart';
import 'package:respire/components/TrainingEditorPage/StagePlaylistsEditor.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:respire/utils/TextUtils.dart';

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
  late TextEditingController descriptionController;
  late TextEditingController preparationController;
  late TextEditingController endingController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _descriptionFocusNode = FocusNode();
  FocusNode? preparationFocusNode = FocusNode();
  FocusNode? endingFocusNode = FocusNode();

  int _selectedTab = 0;
  late Sounds _sounds;

  final int titleMaxLength = 15;

  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    trainingStages = widget.training.trainingStages;
    _sounds = widget.training.sounds;
    descriptionController =
        TextEditingController(text: widget.training.description);

    preparationController = TextEditingController(
        text: widget.training.settings.preparationDuration.toString());
    preparationFocusNode = FocusNode();
    preparationFocusNode!.addListener(() {
      if (!(preparationFocusNode?.hasFocus ?? true)) {
        final value = int.tryParse(preparationController.text);
        if (value != null && value > 0) {
          setState(() => widget.training.settings.preparationDuration = value);
        }
      }
    });

    endingController = TextEditingController(
        text: widget.training.settings.endingDuration.toString());
    endingFocusNode = FocusNode();
    endingFocusNode!.addListener(() {
      if (!(endingFocusNode?.hasFocus ?? true)) {
        final value = int.tryParse(endingController.text);
        if (value != null && value > 0) {
          setState(() => widget.training.settings.endingDuration = value);
        }
      }
    });
  }

  void addTrainingStage() {
    setState(() {
      trainingStages.add(TrainingStage(
          reps: 1,
          breathingPhases: [],
          increment: 0,
          name:
              "${translationProvider.getTranslation("TrainingPage.TrainingOverview.training_stage")} ${trainingStages.length + 1}"));
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
          title: Text(translationProvider.getTranslation(
              "TrainingEditorPage.TrainingTab.remove_training_stage_dialog_title")),
          content: Text(translationProvider.getTranslation(
              "TrainingEditorPage.TrainingTab.remove_training_stage_dialog_content")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                  translationProvider.getTranslation("PopupButton.cancel"),
                  style: TextStyle(color: darkerblue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                  translationProvider.getTranslation("PopupButton.remove"),
                  style: TextStyle(color: Colors.red)),
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
    preparationFocusNode?.dispose();
    endingFocusNode?.dispose();
    super.dispose();
  }

  void showEditTitleDialog(BuildContext context) {
    final tempController = TextEditingController(text: widget.training.title);
    bool isError = false;
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
              translationProvider.getTranslation(
                  "TrainingEditorPage.TrainingTab.edit_title_dialog_title"),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: darkerblue),
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
                        translationProvider.getTranslation(
                            "TrainingEditorPage.TrainingTab.error"),
                        style: TextStyle(
                            color: darkred,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                TextField(
                  controller: tempController,
                  autofocus: true,
                  maxLength: titleMaxLength,
                  decoration: InputDecoration(
                    hintText: translationProvider.getTranslation(
                        "TrainingEditorPage.TrainingTab.edit_title_dialog_hint"),
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
                child: Text(
                  translationProvider.getTranslation("PopupButton.save"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlert(int emptyStages) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("TrainingEditorPage.Alert.header")),
          content: widget.training.isEmpty() 
            ? Text(translationProvider.getTranslation("TrainingEditorPage.Alert.empty_training_message")) 
            : Text('${translationProvider.getTranslation("TrainingEditorPage.Alert.empty_stages_message_first_part")}$emptyStages${translationProvider.getTranslation("TrainingEditorPage.Alert.empty_stages_message_second_part")}'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                //delete empty stages
                if(emptyStages > 0) {
                  widget.training.deleteEmptyStages();
                }
                Navigator.pop(context);
                Navigator.pop(context, widget.training);
              },
              child: Text(translationProvider.getTranslation("TrainingEditorPage.Alert.finish_edition_button")),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(translationProvider.getTranslation("TrainingEditorPage.Alert.back_to_edition_button")),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Automatically return updated training when popping
        int emptyStages = widget.training.countEmptyStages();
        if(emptyStages > 0 || widget.training.trainingStages.isEmpty) {
          _showAlert(emptyStages);
        } else {
          Navigator.pop(context, widget.training);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            widget.training.title,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Glacial',),
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
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
                    0: Text(
                        translationProvider
                            .getTranslation("TrainingEditorPage.tab.training"),
                        style: TextStyle(
                            color:
                                _selectedTab == 0 ? darkerblue : Colors.white,
                            fontWeight: _selectedTab == 0
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    1: Text(
                        translationProvider
                            .getTranslation("TrainingEditorPage.tab.sounds"),
                        style: TextStyle(
                            color:
                                _selectedTab == 1 ? darkerblue : Colors.white,
                            fontWeight: _selectedTab == 1
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    2: Text(
                        translationProvider
                            .getTranslation("TrainingEditorPage.tab.other"),
                        style: TextStyle(
                            color:
                                _selectedTab == 2 ? darkerblue : Colors.white,
                            fontWeight: _selectedTab == 2
                                ? FontWeight.bold
                                : FontWeight.normal)),
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
                  innerPadding:
                      EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                ),
              ),
              SizedBox(height: 2),
              Expanded(
                child: _selectedTab == 0
                    ? ReorderableListView(
                        scrollController: _scrollController,
                        onReorder: reorderTrainingStage,
                        proxyDecorator: (child, idx, anim) => Material(
                            color: Colors.transparent,
                            child: child), // Removes shadow when dragging tile
                        padding: EdgeInsets.only(bottom: 80),
                        children: [
                          for (int index = 0;
                              index < trainingStages.length;
                              index++)
                            TrainingStageTile(
                              key: ValueKey('stage_$index'),
                              trainingStage: trainingStages[index],
                              trainingStageIndex: index,
                              onDelete: () => removeTrainingStage(index),
                              onUpdate: () {
                                setState(() => widget.training.trainingStages =
                                    trainingStages);
                              },
                            ),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: _selectedTab == 1
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.title"),
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, overflow: TextOverflow.ellipsis),
                                          ),
                                          SoundSelectionRow(
                                            labelStyle: TextStyle(
                                                color: darkerblue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14, 
                                                overflow: TextOverflow.ellipsis),
                                            label: translationProvider
                                                .getTranslation(
                                                    "TrainingEditorPage.SoundsTab.TrainingSounds.counting_sound"),
                                            selectedValue:
                                                _sounds.countingSound,
                                            soundListType:
                                                SoundListType.countingSounds,
                                            onChanged: (v) => setState(() {
                                                  _sounds.countingSound = v;
                                                }),
                                            includeVoiceOption: true,
                                            blueBorder: true,
                                            isSoundSelection: true,),
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 4),
                                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: mediumblue,
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column (
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(child:
                                                      DropdownButton2<SoundScope>(
                                                        buttonStyleData: ButtonStyleData(
                                                          height: 35,
                                                          elevation: 2,
                                                          width: MediaQuery.of(context).size.width,
                                                        ),
                                                        underline: SizedBox(),
                                                        iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                                        dropdownStyleData: DropdownStyleData(       
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(color: mediumblue),
                                                          ),
                                                        ), 
                                                        isExpanded: true,
                                                        selectedItemBuilder: (context) {
                                                          return SoundScopeX.nextPhaseScopeValues.map((e) {
                                                            return Container(
                                                              alignment: Alignment.centerLeft,
                                                              child: Text(
                                                                translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingSounds.NextBreathingPhaseSounds.title")+e.name,
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                softWrap: false,
                                                                style: TextStyle(fontSize: 14, color: darkerblue, fontWeight: FontWeight.bold),
                                                              ),
                                                            );
                                                          }).toList();
                                                        },
                                                        value: _sounds.nextSoundScope,
                                                        items: SoundScopeX.nextPhaseScopeValues.map((e) => DropdownMenuItem(value: e, child: Text(e.name, style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(),
                                                        onChanged: (v) => setState(() => _sounds.nextSoundScope = v!))),
                                                  ],
                                                ),
                                                if (_sounds.nextSoundScope != SoundScope.none)...[
                                                  Column(
                                                    children: [
                                                      if(_sounds.nextSoundScope == SoundScope.global)
                                                        ((){
                                                          return SoundSelectionRow(
                                                            labelStyle: TextStyle(
                                                                overflow: TextOverflow.ellipsis),
                                                            label: translationProvider
                                                                .getTranslation(
                                                                    "TrainingEditorPage.SoundsTab.TrainingSounds.NextBreathingPhaseSounds.global"),
                                                            selectedValue:
                                                                _sounds.nextSound,
                                                            soundListType:
                                                                SoundListType
                                                                    .shortSounds,
                                                            onChanged: (v) =>
                                                                setState(() {
                                                                  _sounds.nextSound =
                                                                      v;
                                                                }),
                                                            includeVoiceOption:
                                                                true,
                                                                isSoundSelection: true);
                                                        })()
                                                      else if (_sounds.nextSoundScope == SoundScope.perPhase)
                                                        ...buildPhaseSoundRows(SoundListType.shortSounds, true)
                                                    ],
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                        SoundSelectionRow(
                                            labelStyle: TextStyle(
                                                color: darkerblue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14, 
                                                overflow: TextOverflow.ellipsis),
                                            label: translationProvider
                                                .getTranslation(
                                                    "TrainingEditorPage.SoundsTab.TrainingSounds.stage_change_sound"),
                                            selectedValue:
                                                _sounds.stageChangeSound,
                                            soundListType:
                                                SoundListType.shortSounds,
                                            onChanged: (v) => setState(() {
                                                  _sounds.stageChangeSound = v;
                                                }),
                                            includeVoiceOption: false,
                                            blueBorder: true,
                                            isSoundSelection: true),

                                        SoundSelectionRow(
                                            labelStyle: TextStyle(
                                                color: darkerblue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14, 
                                                overflow: TextOverflow.ellipsis),
                                            label: translationProvider
                                                .getTranslation(
                                                    "TrainingEditorPage.SoundsTab.TrainingSounds.cycle_change_sound"),
                                            selectedValue:
                                                _sounds.cycleChangeSound,
                                            soundListType:
                                                SoundListType.shortSounds,
                                            onChanged: (v) => setState(() {
                                                  _sounds.cycleChangeSound = v;
                                                }),
                                            includeVoiceOption: false,
                                            blueBorder: true,
                                            isSoundSelection: true)
                                            ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
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
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, overflow: TextOverflow.ellipsis),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 4),
                                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white ,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: widget.training.settings.binauralBeatsEnabled ? mediumblue.withOpacity(0.2) : mediumblue,
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(child:
                                                    Opacity(opacity: widget.training.settings.binauralBeatsEnabled ? 0.3 : 1.0,
                                                      child:
                                                      DropdownButton2<SoundScope>(
                                                        buttonStyleData: ButtonStyleData(
                                                          height:35,
                                                          elevation: 2,
                                                          width: MediaQuery.of(context).size.width,
                                                        ),
                                                        underline: SizedBox(),
                                                        iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                                        dropdownStyleData: DropdownStyleData(       
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(16),
                                                            border: Border.all(color: mediumblue),
                                                          ),
                                                        ), 
                                                        isExpanded: true,
                                                        selectedItemBuilder: (context) {
                                                          return SoundScope.values.map((e) {
                                                            return Container(
                                                              alignment: Alignment.centerLeft,
                                                              child: Text(
                                                                translationProvider.getTranslation("TrainingEditorPage.SoundsTab.TrainingMusic.Background_music.title")+e.name,
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                softWrap: false,
                                                                style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold, fontSize: 14, overflow: TextOverflow.ellipsis),
                                                              ),
                                                            );
                                                          }).toList();
                                                        },
                                                        value: _sounds.backgroundSoundScope, 
                                                        items: SoundScope.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name, style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(),
                                                        onChanged: widget.training.settings.binauralBeatsEnabled ? null :(v) => setState(() => _sounds.backgroundSoundScope = v!))),
                                                )],
                                                ),
                                                if (_sounds.backgroundSoundScope != SoundScope.none)...[
                                                  Column(
                                                    children: [
                                                      if (_sounds.backgroundSoundScope == SoundScope.global) ...[
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                          child: PlaylistEditor(
                                                            playlist: _sounds.trainingBackgroundPlaylist,
                                                            onChanged: (newPlaylist) {
                                                              setState(() {
                                                                _sounds.trainingBackgroundPlaylist = newPlaylist;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ] else if (_sounds.backgroundSoundScope == SoundScope.perPhase)
                                                        ...buildPhaseSoundRows(SoundListType.longSounds, false)
                                                      else if (_sounds.backgroundSoundScope == SoundScope.perStage) ...[
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                          child: StagePlaylistsEditor(
                                                            stages: trainingStages,
                                                            stagePlaylists: _sounds.stagePlaylists,
                                                            onChanged: (newStagePlaylists) {
                                                              setState(() {
                                                                _sounds.stagePlaylists = newStagePlaylists;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ] else if (_sounds.backgroundSoundScope == SoundScope.perEveryPhaseInEveryStage) ...[
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                          child: StagePhaseSoundEditor(
                                                            stages: trainingStages,
                                                            perEveryPhaseBreathingPhaseBackgrounds: _sounds.perEveryPhaseBreathingPhaseBackgrounds,
                                                            onChanged: (newMap) {
                                                              setState(() {
                                                                _sounds.perEveryPhaseBreathingPhaseBackgrounds = newMap;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ]
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          SoundSelectionRow(
                                            labelStyle: TextStyle(
                                                color: darkerblue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis),
                                            label: translationProvider
                                                .getTranslation(
                                                    "TrainingEditorPage.SoundsTab.TrainingMusic.preparation_music"),
                                            selectedValue:
                                                _sounds.preparationTrack,
                                            soundListType:
                                                SoundListType.longSounds,
                                            onChanged: (v) => setState(() {
                                                  _sounds.preparationTrack =
                                                      v;
                                                },),
                                            includeVoiceOption: false,
                                            blueBorder: true,
                                            isSoundSelection: false),
                                          SoundSelectionRow(
                                            labelStyle: TextStyle(
                                                color: darkerblue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis),
                                            label: translationProvider
                                                .getTranslation(
                                                    "TrainingEditorPage.SoundsTab.TrainingMusic.ending_music"),
                                            selectedValue:
                                                _sounds.endingTrack,
                                            soundListType:
                                                SoundListType.longSounds,
                                            onChanged: (v) => setState(() {
                                                  _sounds.endingTrack = v;
                                                }),
                                            includeVoiceOption: false,
                                            blueBorder: true,
                                            isSoundSelection: false),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                    Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: [Text(
                                              translationProvider.getTranslation(
                                                  "TrainingEditorPage.SoundsTab.BinauralBeats.binaural_beats_label"),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkblue),
                                            ),
                                            if (!widget.training.settings.binauralBeatsEnabled) ...[
                                              SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 16, right: 16),
                                                child: Text(
                                                  TextUtils.addNoBreakingSpaces(translationProvider.getTranslation(
                                                    "TrainingEditorPage.SoundsTab.BinauralBeats.warning",
                                                  )),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                          ],
                                          ],
                                          ),
                                          ),
                                          SwitchListTile(
                                            title: Text(translationProvider
                                                .getTranslation(
                                                    "TrainingEditorPage.SoundsTab.BinauralBeats.binaural_beats_enabled")),
                                            value: widget.training.settings
                                                .binauralBeatsEnabled,
                                            activeColor: darkerblue,
                                            inactiveTrackColor: Colors.white,
                                            inactiveThumbColor: Colors.grey,
                                            trackOutlineColor:
                                                WidgetStateProperty.resolveWith<
                                                        Color?>(
                                                    (Set<WidgetState> states) {
                                              if (!states.contains(
                                                      WidgetState.selected) &&
                                                  !states.contains(
                                                      WidgetState.disabled)) {
                                                return mediumblue;
                                              }
                                              return null;
                                            }),
                                            onChanged: (v) => toggleBinauralBeats(v),
                                          ),
                                          if (widget.training.settings
                                              .binauralBeatsEnabled) ...[
                                            SizedBox(height: 12),
                                            ListTile(
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    translationProvider
                                                        .getTranslation(
                                                            "TrainingEditorPage.SoundsTab.BinauralBeats.left_frequency_label"),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '${widget.training.settings.binauralLeftFrequency.toStringAsFixed(1)} Hz',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Slider(
                                                value: widget.training.settings
                                                    .binauralLeftFrequency,
                                                min: 100,
                                                max: 500,
                                                divisions: 80,
                                                activeColor: darkerblue,
                                                inactiveColor: Colors.grey[300],
                                                onChanged: (v) => setState(() =>
                                                    widget.training.settings
                                                        .binauralLeftFrequency = v),
                                              ),
                                            ),
                                            ListTile(
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    translationProvider
                                                        .getTranslation(
                                                            "TrainingEditorPage.SoundsTab.BinauralBeats.right_frequency_label"),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '${widget.training.settings.binauralRightFrequency.toStringAsFixed(1)} Hz',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Slider(
                                                value: widget.training.settings
                                                    .binauralRightFrequency,
                                                min: 100,
                                                max: 500,
                                                divisions: 80,
                                                activeColor: darkerblue,
                                                inactiveColor: Colors.grey[300],
                                                onChanged: (v) => setState(() =>
                                                    widget.training.settings
                                                        .binauralRightFrequency = v),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                '${translationProvider.getTranslation("TrainingEditorPage.SoundsTab.BinauralBeats.beat_frequency_label")}: ${(widget.training.settings.binauralRightFrequency - widget.training.settings.binauralLeftFrequency).abs().toStringAsFixed(1)} Hz',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: darkerblue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Preparation
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      child: Column(
                                        children: [
                                          // Description field
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                translationProvider.getTranslation(
                                                    "TrainingEditorPage.OtherTab.training_description_label"),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          ),
                                          SizedBox(height: 5),
                                          TextField(
                                            controller: descriptionController,
                                            focusNode: _descriptionFocusNode,
                                            minLines: 3,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                              hintText: translationProvider
                                                  .getTranslation(
                                                      "TrainingEditorPage.OtherTab.training_description_hint"),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: darkgrey,
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: darkerblue,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              widget.training.description =
                                                  value;
                                            },
                                          ),
                                          SizedBox(height: 6),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                translationProvider.getTranslation(
                                                    "TrainingEditorPage.OtherTab.training_preparation_label"),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          ),
                                          ListTile(
                                            title: Row(
                                              children:[Expanded(child:Text(translationProvider
                                                              .getTranslation("TrainingEditorPage.OtherTab.preparation_duration_label"), overflow: TextOverflow.ellipsis,
                                                              )),
                                                              if (widget.training.settings.preparationDuration == 0 && _sounds.preparationTrack.type != SoundType.none)
                                                  Tooltip(
                                                    message: translationProvider.getTranslation("TrainingEditorPage.OtherTab.preparation_sound_warning"),
                                                    decoration: BoxDecoration(
                                                      color: mediumblue,
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: darkerblue, width: 2),
                                                    ),
                                                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.07, vertical: 0),
                                                    triggerMode: TooltipTriggerMode.tap,
                                                    showDuration: Duration(seconds: 10),
                                                    textStyle: const TextStyle(color: darkblue, fontWeight: FontWeight.w500),
                                                    textAlign: TextAlign.center,
                                                    child: const Icon(
                                                      Icons.warning,
                                                      color: Colors.amber,
                                                      size: 22,
                                                    ),
                                                  ),
                                                              ]),
                                            trailing: Container(
                                              width: 90,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                    color: darkerblue,
                                                    width: 2),
                                              ),
                                              child: Row(
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      onTap: () {
                                                        int currentValue =
                                                            int.tryParse(
                                                                    preparationController
                                                                        .text) ??
                                                                1;
                                                        int newValue =
                                                            (currentValue - 1)
                                                                .clamp(0, 999);
                                                        preparationController
                                                                .text =
                                                            newValue.toString();
                                                        setState(() {
                                                          widget
                                                                  .training
                                                                  .settings
                                                                  .preparationDuration =
                                                              newValue;
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Icon(
                                                            Icons.remove,
                                                            size: 16),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: TextField(
                                                        key: ValueKey('preparation_${widget.training.hashCode}'),
                                                        controller: preparationController,
                                                        focusNode: preparationFocusNode,
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.digitsOnly,
                                                        ],
                                                        onChanged: (value) {
                                                          int newValue = int.tryParse(value) ?? 0;
                                                          setState(() {
                                                            widget.training.settings.preparationDuration = newValue;
                                                          });
                                                        },
                                                        onTapOutside: (event) {
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                          if (preparationController.text.isEmpty) {
                                                            setState(() {
                                                              widget.training.settings.preparationDuration = 0;
                                                              preparationController.text = "0";
                                                            });
                                                          }
                                                        },
                                                        onEditingComplete: () => {
                                                          FocusManager.instance.primaryFocus?.unfocus(),
                                                          if (preparationController.text.isEmpty) {
                                                            setState(() {
                                                              widget.training.settings.preparationDuration = 0;
                                                              preparationController.text = "0";
                                                            })
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                          border: InputBorder.none,
                                                          contentPadding: EdgeInsets.zero,
                                                          isDense: true,
                                                        ),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ),
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      onTap: () {
                                                        int currentValue =
                                                            int.tryParse(
                                                                    preparationController
                                                                        .text) ??
                                                                1;
                                                        int newValue =
                                                            (currentValue + 1)
                                                                .clamp(1, 999);
                                                        preparationController
                                                                .text =
                                                            newValue.toString();
                                                        setState(() {
                                                          widget
                                                                  .training
                                                                  .settings
                                                                  .preparationDuration =
                                                              newValue;
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Icon(Icons.add,
                                                            size: 16),
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

                                  //Ending 
                                  SizedBox(height: 12),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                translationProvider.getTranslation(
                                                    "TrainingEditorPage.OtherTab.training_ending_label"),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          ),
                                          ListTile(
                                            title: Row(
                                              children:[Expanded(child:Text(translationProvider
                                                              .getTranslation("TrainingEditorPage.OtherTab.ending_duration_label"), overflow: TextOverflow.ellipsis,
                                                              )),
                                                              if (widget.training.settings.endingDuration == 0 && _sounds.endingTrack.type != SoundType.none)
                                                  Tooltip(
                                                    message: translationProvider.getTranslation("TrainingEditorPage.OtherTab.ending_sound_warning"),
                                                    decoration: BoxDecoration(
                                                      color: mediumblue,
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: darkerblue, width: 2),
                                                    ),
                                                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.07, vertical: 0),
                                                    triggerMode: TooltipTriggerMode.tap,
                                                    showDuration: Duration(seconds: 10),
                                                    textStyle: const TextStyle(color: darkblue, fontWeight: FontWeight.w500),
                                                    textAlign: TextAlign.center,
                                                    child: const Icon(
                                                      Icons.warning,
                                                      color: Colors.amber,
                                                      size: 22,
                                                    ),
                                                  ),
                                                              ]),
                                            trailing: Container(
                                              width: 90,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                    color: darkerblue,
                                                    width: 2),
                                              ),
                                              child: Row(
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      onTap: () {
                                                        int currentValue =
                                                            int.tryParse(
                                                                    endingController
                                                                        .text) ??
                                                                1;
                                                        int newValue =
                                                            (currentValue - 1)
                                                                .clamp(0, 999);
                                                        endingController
                                                                .text =
                                                            newValue.toString();
                                                        setState(() {
                                                          widget
                                                                  .training
                                                                  .settings
                                                                  .endingDuration =
                                                              newValue;
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Icon(
                                                            Icons.remove,
                                                            size: 16),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: TextField(
                                                        key: ValueKey('ending_${widget.training.hashCode}'),
                                                        controller: endingController,
                                                        focusNode: endingFocusNode,
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.digitsOnly,
                                                        ],
                                                        onChanged: (value) {
                                                          int newValue = int.tryParse(value) ?? 0;
                                                          setState(() {
                                                            widget.training.settings.endingDuration = newValue;
                                                          });
                                                        },
                                                        onTapOutside: (event) {
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                          if (endingController.text.isEmpty) {
                                                            setState(() {
                                                              widget.training.settings.endingDuration = 0;
                                                              endingController.text = "0";
                                                            });
                                                          }
                                                        },
                                                        onEditingComplete: () => {
                                                          FocusManager.instance.primaryFocus?.unfocus(),
                                                          if (endingController.text.isEmpty) {
                                                            setState(() {
                                                              widget.training.settings.endingDuration = 0;
                                                              endingController.text = "0";
                                                            })
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                          border: InputBorder.none,
                                                          contentPadding: EdgeInsets.zero,
                                                          isDense: true,
                                                        ),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ),
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      onTap: () {
                                                        int currentValue =
                                                            int.tryParse(
                                                                    endingController
                                                                        .text) ??
                                                                1;
                                                        int newValue =
                                                            (currentValue + 1)
                                                                .clamp(1, 999);
                                                        endingController
                                                                .text =
                                                            newValue.toString();
                                                        setState(() {
                                                          widget
                                                                  .training
                                                                  .settings
                                                                  .endingDuration =
                                                              newValue;
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Icon(Icons.add,
                                                            size: 16),
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
                label: Text(
                    translationProvider.getTranslation(
                        "TrainingEditorPage.TrainingTab.add_training_stage_button_label"),
                    style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  SoundScope _previousBackgroundScope = SoundScope.global;
  void toggleBinauralBeats(bool? value) {
    setState(() {
      if (value == true) {
        _previousBackgroundScope = _sounds.backgroundSoundScope;
        _sounds.backgroundSoundScope = SoundScope.none;
      } else {
        _sounds.backgroundSoundScope = _previousBackgroundScope;
      }
      widget.training.settings.binauralBeatsEnabled = value ?? false;
    });
  }

  List<Widget> buildPhaseSoundRows(SoundListType type, bool isSoundSelection) {
    return [
      for (final phase in BreathingPhaseType.values)
        SoundSelectionRow(
          includeVoiceOption: false,
          labelStyle: TextStyle(overflow: TextOverflow.ellipsis),
          label: translationProvider
              .getTranslation("BreathingPhaseType.${phase.name}"),
          selectedValue: type == SoundListType.longSounds
              ? _sounds.breathingPhaseBackgrounds[phase]!
              : _sounds.breathingPhaseCues[phase]!,
          soundListType: type,
          onChanged: (v) {
            setState(() {
              type == SoundListType.longSounds
                  ? _sounds.breathingPhaseBackgrounds[phase] = v
                  : _sounds.breathingPhaseCues[phase] = v;
            });
          },
          isSoundSelection: isSoundSelection ? true : false,
        ),
    ];
  }
}
