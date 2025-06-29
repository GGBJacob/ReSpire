import 'package:flutter/material.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'dart:async';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/TrainingEditorPage/AudioSelectionDropdown.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';
import 'package:respire/components/TrainingEditorPage/SoundDropdownItem.dart';
import 'package:respire/services/SoundManager.dart';
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
  TextEditingController trainingNameController = TextEditingController();
  Timer? _debounce;

  int _selectedTab = 0;
  // Sound tab state
  final List<String> _soundOptions = SoundManager().getAvailableSounds();
  late Sounds _sounds;
  
  // Other tab state
  bool _showNextStepToggle = true;
  bool _showChartToggle = false;
  bool _showStepColorsToggle = true;

  @override
  void initState() {
    super.initState();
    phases = widget.training.phases;
    _sounds = widget.training.sounds;
    trainingNameController.text = widget.training.title;
    descriptionController = TextEditingController(text: widget.training.description);
  }

  void saveTraining() {
    // TODO: implement actual saving logic, e.g., write to local storage or call an API
    print("Training saved: ${widget.training.title}");
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
    });
    saveTraining();
  }

  void removePhase(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove phase?'),
          content: Text('Are you sure you want to remove this phase?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        phases.removeAt(index);
      });
      saveTraining();
    }
  }

  void reorderPhase(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final phase = phases.removeAt(oldIndex);
      phases.insert(newIndex, phase);
    });
    saveTraining();
  }

  @override
  void dispose() {
    trainingNameController.dispose();
    descriptionController.dispose();
    _debounce?.cancel();
    super.dispose();
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
          title: TextField(
            controller: trainingNameController,
            decoration: InputDecoration(border: InputBorder.none),
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
            onChanged: (value) {
              widget.training.title = value;
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(Duration(milliseconds: 500), () {
                saveTraining();
              });
            },
          ),
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
                    0: Text('Training', style: TextStyle(color: _selectedTab==0?darkerblue:Colors.black, fontWeight:  _selectedTab==0?FontWeight.bold:FontWeight.normal)),
                    1: Text('Sound', style: TextStyle(color: _selectedTab==1?darkerblue:Colors.black, fontWeight:  _selectedTab==1?FontWeight.bold:FontWeight.normal)),
                    2: Text('Other', style: TextStyle(color: _selectedTab==2?darkerblue:Colors.black, fontWeight:  _selectedTab==2?FontWeight.bold:FontWeight.normal)),
                  },
                  initialValue: _selectedTab,
                  onValueChanged: (val) => setState(() => _selectedTab = val),
                  decoration: BoxDecoration(
                    color: grey,
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
                            Text('Training sounds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text('Background sound'), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(), 
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                            dropdownStyleData: DropdownStyleData(
                                              //isOverButton: true,         
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          value: _sounds.backgroundSound, 
                                          items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sounds.backgroundSound = v!))],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text('Next step sound'), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(),
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                            dropdownStyleData: DropdownStyleData(
                                              //isOverButton: true,         
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ), 
                                          value: _sounds.nextSound, 
                                          items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sounds.nextSound = v!))],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text('Step type sounds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Inhale'), 
                                        DropdownButton2<String>(
                                          underline: SizedBox(), 
                                          iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                            dropdownStyleData: DropdownStyleData(
                                              //isOverButton: true,         
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          value: _sounds.inhaleSound, 
                                          items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sounds.inhaleSound = v!))]),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Retention'), 
                                    AudioSelectionDropdown(items: _soundOptions, selectedValue: _sounds.retentionSound, onChanged: (v) => setState(() => _sounds.retentionSound = v!))
                                    ]),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Exhale'), 
                                      DropdownButton2<String>(
                                        underline: SizedBox(), 
                                        iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                          dropdownStyleData: DropdownStyleData(
                                            //isOverButton: true,         
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        value: _sounds.exhaleSound, 
                                        items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sounds.exhaleSound = v!))]),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recovery'), 
                                      DropdownButton2<String>(
                                        underline: SizedBox(),
                                        iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
                                          dropdownStyleData: DropdownStyleData(
                                            //isOverButton: true,         
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ), 
                                        value: _sounds.recoverySound, 
                                        items: _soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sounds.recoverySound = v!))]),
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
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Description field
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkblue)),
                                    ),
                                    TextField(
                                      controller: descriptionController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Enter training description...',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (value) {
                                        widget.training.description = value;
                                        saveTraining();
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    SwitchListTile(title: Text('Next step'), value: _showNextStepToggle, onChanged: (v) => setState(() => _showNextStepToggle = v)),
                                    SwitchListTile(title: Text('Chart'), value: _showChartToggle, onChanged: (v) => setState(() => _showChartToggle = v)),
                                    SwitchListTile(title: Text('Step colors'), value: _showStepColorsToggle, onChanged: (v) => setState(() => _showStepColorsToggle = v)),
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
             ? FloatingActionButton(
                 onPressed: addPhase,
                 backgroundColor: darkerblue,
                 child: Icon(Icons.add, color: Colors.white),
               )
             : null,
      ),
    );
  }
}
