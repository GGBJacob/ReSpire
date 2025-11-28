import 'package:flutter/material.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/HomePage/AddPresetTile.dart';
import 'package:respire/components/HomePage/PresetTile.dart';
import 'package:respire/pages/ProfilePage.dart';
import 'package:respire/pages/SettingsPage.dart';
import 'package:respire/pages/TrainingEditorPage.dart';
import 'package:respire/pages/TrainingPage.dart';
import 'package:respire/services/PresetDataBase.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/services/TrainingImportExportService.dart';
import 'package:respire/theme/Colors.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final titleController = TextEditingController();
  final PresetDataBase db = PresetDataBase();
  int breathCount = 10;
  int inhaleTime = 3;
  int exhaleTime = 3;
  int retentionTime = 3;

  TranslationProvider translationProvider = TranslationProvider();
  
  bool _isSelectionMode = false;
  Set<int> _selectedIndices = {};

  late final AnimationController _waveController1;
  late final AnimationController _waveController2;
  late final AnimationController _waveController3;

  @override
  void initState() {
    super.initState();
    db.initialize();

  _waveController1 = AnimationController(vsync: this, duration: Duration(seconds: 55))..forward(from: 0.0)..repeat();
  _waveController2 = AnimationController(vsync: this, duration: Duration(seconds: 62))..forward(from: 0.73)..repeat();
  _waveController3 = AnimationController(vsync: this, duration: Duration(seconds: 50))..forward(from: 0.56)..repeat();

  }

  @override
  void dispose() {
    _waveController1.dispose();
    _waveController2.dispose();
    _waveController3.dispose();
    super.dispose();
  }

  void loadValues(int index) {
    Training entry = db.presetList[index];
    titleController.text = entry.title;
  }
  
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }
  
  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }
  
  void _selectAll() {
    setState(() {
      _selectedIndices = Set.from(List.generate(db.presetList.length, (index) => index));
    });
  }
  
  void _deselectAll() {
    setState(() {
      _selectedIndices.clear();
    });
  }
  
  Future<void> _exportSelected() async {
    if (_selectedIndices.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              translationProvider.getTranslation('HomePage.no_trainings_selected'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          backgroundColor: lightblue,
        ),
      );
      return;
    }
    
    try {
      final selectedTrainings = _selectedIndices
          .map((index) => db.presetList[index])
          .toList();
      final success = await TrainingImportExportService.exportMultipleTrainings(selectedTrainings);
      
      if (!mounted) return;
      
      if (success) {
        setState(() {
          _isSelectionMode = false;
          _selectedIndices.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                translationProvider.getTranslation('HomePage.export_multiple_success'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translationProvider.getTranslation('TrainingPage.export_error')),
            content: Text('${translationProvider.getTranslation('TrainingPage.export_error_details')}:\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(translationProvider.getTranslation('PopupButton.cancel')),
              ),
            ],
          );
        },
      );
    }
  }

  // Pull-to-refresh for presets
  Future<void> _refreshPresets() async {
    db.loadData();
    setState(() {});
  }

  Future<void> importTraining() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: greenblue),),
    );

    try {
      final trainings = await TrainingImportExportService.importTrainings();
      
      if (!mounted) return;
      Navigator.pop(context);
      
      if (trainings != null && trainings.isNotEmpty) {
        setState(() {
          for (var training in trainings) {
            training.updateSounds();
            db.presetList.add(training);
          }
          db.updateDataBase();
        });
        
        final message = trainings.length == 1
            ? translationProvider.getTranslation('HomePage.import_success')
            : translationProvider.getTranslation('HomePage.import_multiple_success')
                .replaceAll('{count}', trainings.length.toString());
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                message,
                textAlign: TextAlign.center, 
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                translationProvider.getTranslation('HomePage.import_cancelled'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            backgroundColor: lightblue,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translationProvider.getTranslation('HomePage.import_error')),
            content: Text(
                '${translationProvider.getTranslation('HomePage.import_error_details')}:\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(translationProvider.getTranslation('PopupButton.cancel')),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _isSelectionMode
            ? IconButton(
                icon: Icon(Icons.close, color: darkerblue),
                onPressed: _toggleSelectionMode,
                tooltip: translationProvider.getTranslation('HomePage.cancel_selection'),
              )
            : IconButton(
                icon: Icon(Icons.checklist, color: darkerblue),
                onPressed: db.presetList.isEmpty ? null : _toggleSelectionMode,
                tooltip: translationProvider.getTranslation('HomePage.select_mode'),
              ),

        title: _isSelectionMode
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child:
                  Text(
                    _selectedIndices.isEmpty
                        ? translationProvider.getTranslation('HomePage.select_mode')
                        : translationProvider
                            .getTranslation('HomePage.export_selected_count')
                            .replaceAll('{count}', _selectedIndices.length.toString()),
                    style: TextStyle(
                      color: darkerblue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),),
                  SizedBox(width: 10),
                  FilledButton(
                    onPressed: _selectedIndices.length < db.presetList.length
                        ? _selectAll
                        : _deselectAll,
                    style: FilledButton.styleFrom(
                      backgroundColor: darkerblue.withOpacity(0.1),
                      foregroundColor: darkerblue,
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _selectedIndices.length < db.presetList.length
                            ? translationProvider.getTranslation('HomePage.select_all')
                            : translationProvider.getTranslation('HomePage.deselect_all'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            : Image.asset('assets/logo_poziom.png', height: 36),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.file_upload_outlined, color: darkerblue),
                  onPressed: _exportSelected,
                  tooltip: translationProvider.getTranslation('HomePage.export_selected'),
                )
              ]
            : [
                IconButton(
                  icon: Icon(Icons.file_download_outlined, color: darkerblue),
                  onPressed: importTraining,
                  tooltip: translationProvider.getTranslation('HomePage.import_training_tooltip'),
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: darkerblue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  tooltip: translationProvider.getTranslation('HomePage.settings_tooltip'),
                ),
              ],
      ),),
      backgroundColor: mediumblue,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: pi,
              child: Opacity(
                opacity: 0.1,
                child: Lottie.asset(
                  'assets/animations/wave.json',
                  controller: _waveController1,
                  fit: BoxFit.cover,
                  height: 670,
                  repeat: true,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: pi,
              child: Opacity(
                opacity: 0.12,
                child: Lottie.asset(
                  'assets/animations/wave.json',
                  controller: _waveController2,
                  fit: BoxFit.cover,
                  height: 550,
                  repeat: true,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: pi,
              child: Opacity(
                opacity: 0.15,
                child: Lottie.asset(
                  'assets/animations/wave.json',
                  controller: _waveController3,
                  fit: BoxFit.cover,
                  height: 450,
                  repeat: true,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: size * 0.05,    // mały margines od dołu
            width: size * 0.5,      // 50% szerokości ekranu
            left: size * 0.25,      // zaczyna się na środku = 25% + 50%
            height: size * 0.5,     // możesz zmienić (proporcje)
            child: Opacity(
              opacity: 1,
              child: Image(
                image: AssetImage('assets/group_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: _refreshPresets,
            color: Colors.white,
            backgroundColor: mediumblue,
            edgeOffset: 16,
            child: ListView.builder(
              padding: EdgeInsets.only(top: size * 0.022),
              itemCount: db.presetList.length + 1,
              itemBuilder: (context, index) {
                final isSelected = _isSelectionMode && _selectedIndices.contains(index);
                final double tileWidth = size * 0.7;
                
                return Padding(
                  padding: EdgeInsets.all(size * 0.022), // padding between elements / screen
                  child: index < db.presetList.length
                      ? Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: tileWidth,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (isSelected)
                                  Positioned(
                                    top: -6,
                                    bottom: -6,
                                    left: -6,
                                    right: -6,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: darkerblue,
                                          width: 4,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(76),
                                          bottomRight: Radius.circular(41),
                                          topLeft: Radius.circular(41),
                                          topRight: Radius.circular(76),
                                        ),
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: _isSelectionMode
                                      ? () => _toggleSelection(index)
                                      : null,
                                  child: PresetTile(
                                    value: db.presetList[index],
                                    onClick: _isSelectionMode
                                        ? () => _toggleSelection(index)
                                        : () async {
                                            final bool? updated = await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TrainingPage(index: index),
                                              ),
                                            );

                                            if (updated == true) {
                                              setState(() {});
                                            }
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _isSelectionMode
                          ? const SizedBox.shrink()
                          : Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: tileWidth,
                                child: AddPresetTile(
                                  onClick: () async {
                                    final newTraining = await Navigator.push<Training>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrainingEditorPage(
                                          training: Training(
                                            title: translationProvider.getTranslation("HomePage.default_training_title"),
                                            trainingStages: [],
                                          ),
                                        ),
                                      ),
                                    );

                                    if (newTraining != null &&
                                        newTraining.trainingStages
                                            .any((trainingStage) => trainingStage.breathingPhases.isNotEmpty)) {
                                      setState(() {
                                        db.presetList.add(newTraining);
                                        db.updateDataBase();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
