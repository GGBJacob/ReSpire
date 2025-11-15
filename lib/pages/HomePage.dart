import 'package:flutter/material.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/HomePage/AddPresetTile.dart';
import 'package:respire/components/HomePage/DialogBox.dart';
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

  late final AnimationController _waveController1;
  late final AnimationController _waveController2;
  late final AnimationController _waveController3;

  @override
  void initState() {
    super.initState();
    db.initialize();

    _waveController1 =
        AnimationController(vsync: this, duration: Duration(seconds: 18))..repeat();
    _waveController2 =
        AnimationController(vsync: this, duration: Duration(seconds: 21))..repeat();
    _waveController3 =
        AnimationController(vsync: this, duration: Duration(seconds: 19))..repeat();
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

  void clearValues() {
    titleController.text = "";
    breathCount = 10;
    inhaleTime = 3;
    exhaleTime = 3;
    retentionTime = 3;
  }

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
      final training = await TrainingImportExportService.importTraining();
      Navigator.pop(context);

      if (training != null) {
        setState(() {
          training.updateSounds();
          db.presetList.add(training);
          db.updateDataBase();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                translationProvider.getTranslation('HomePage.import_success'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
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
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Image.asset(
          'assets/logo_poziom.png',
          height: 36,
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.file_download_outlined, color: darkerblue),
          onPressed: importTraining,
          tooltip: translationProvider.getTranslation('HomePage.import_training_tooltip'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: darkerblue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: mediumblue,
      body: Stack(
        children: [
          // 🔹 Tło z falami
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
                  height: 450,
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
                  height: 350,
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
                  controller: _waveController3,
                  fit: BoxFit.cover,
                  height: 100,
                  repeat: true,
                ),
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
                return Padding(
                  padding: EdgeInsets.all(size * 0.022),
                  child: index < db.presetList.length
                      ? PresetTile(
                          values: db.presetList[index],
                          onClick: () async {
                            final bool? updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrainingPage(index: index),
                              ),
                            );
                            if (updated == true) setState(() {});
                          },
                          deleteTile: (context) {
                            db.deletePreset(index);
                            setState(() {});
                          },
                          editTile: (context) async {
                            final updatedTraining = await Navigator.push<Training>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TrainingEditorPage(training: db.presetList[index]),
                              ),
                            );
                            if (updatedTraining != null) {
                              setState(() {
                                updatedTraining.updateSounds();
                                db.presetList[index] = updatedTraining;
                                db.updateDataBase();
                              });
                            }
                          },
                        )
                      : AddPresetTile(
                          onClick: () async {
                            final newTraining = await Navigator.push<Training>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrainingEditorPage(
                                  training: Training(
                                    title: translationProvider.getTranslation(
                                        "HomePage.default_training_title"),
                                    trainingStages: [],
                                  ),
                                ),
                              ),
                            );
                            if (newTraining != null &&
                                newTraining.trainingStages
                                    .any((stage) => stage.breathingPhases.isNotEmpty)) {
                              setState(() {
                                db.presetList.add(newTraining);
                                db.updateDataBase();
                              });
                            }
                          },
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
