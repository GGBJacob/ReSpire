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
import 'package:respire/theme/Colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final titleController = TextEditingController();
  final PresetDataBase db = PresetDataBase();
  int breathCount = 10;
  int inhaleTime = 3;
  int exhaleTime = 3;
  int retentionTime = 3;

  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    db.initialize();
    super.initState();
  }

  void loadValues(int index) {
    Training entry = db.presetList[index];

    titleController.text = entry.title;

    //TODO: Load other values
  }

  void clearValues() {
    titleController.text = "";
    breathCount = 10;
    inhaleTime = 3;
    exhaleTime = 3;
    retentionTime = 3;
  }

  void addPreset() {
    db.presetList
        .add(Training(title: titleController.text, trainingStages: List.empty()));
    setState(() {});
    clearValues();
    db.updateDataBase();
  }

  void editPreset(int index) {
    db.presetList[index] =
        Training(title: titleController.text, trainingStages: List.empty());
    setState(() {});
    clearValues();
    db.updateDataBase();
  }

  void showNewPresetDialog({required BuildContext context}) async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            titleController: titleController,
            breathCount: breathCount,
            inhaleTime: inhaleTime,
            exhaleTime: exhaleTime,
            retentionTime: retentionTime,
            onCancel: clearValues,
          );
        });

    if (result != null) {
      setState(() {
        titleController.text = result['title'];
        breathCount = result['breathCount'];
        inhaleTime = result['inhaleTime'];
        exhaleTime = result['exhaleTime'];
        retentionTime = result['retentionTime'];
      });
    }
  }

  void showEditPresetDialog(
      {required BuildContext context, required int index}) async {
    loadValues(index); // Loads values to variables before showing the dialog

    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            titleController: titleController,
            breathCount: breathCount,
            inhaleTime: inhaleTime,
            exhaleTime: exhaleTime,
            retentionTime: retentionTime,
            onCancel: clearValues,
          );
        });

    if (result != null) {
      setState(() {
        titleController.text = result['title'];
        breathCount = result['breathCount'];
        inhaleTime = result['inhaleTime'];
        exhaleTime = result['exhaleTime'];
        retentionTime = result['retentionTime'];
      });
    }
  }

  // Pull-to-refresh for presets
  Future<void> _refreshPresets() async {
    db.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/logo_poziom.png',
          height: 36,
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: Icon(Icons.person, color: darkerblue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
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
      body: RefreshIndicator(
          onRefresh: _refreshPresets,
          color: Colors.white,
          backgroundColor: mediumblue,
          edgeOffset: 16,
          child: ListView.builder(
              padding: EdgeInsets.only(top: size * 0.022),
              itemCount: db.presetList.length + 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(
                      size * 0.022), // padding between elements / screen
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

                            // If the user updated (removed) the training, refresh the state
                            if (updated == true) {
                              setState(() {});
                            }
                          },
                          deleteTile: (context) {
                            db.deletePreset(index);
                            setState(() {});
                          },
                          editTile: (context) async {
                            final updatedTraining = await Navigator.push<Training>(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TrainingEditorPage(
                                      training: db.presetList[index])),
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
                                  training:
                                      Training(title: translationProvider.getTranslation("HomePage.default_training_title"), trainingStages: []),
                                ),
                              ),
                            );

                            // Only persist if user added at least one breathing phase in any training stage
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
                );
              })),
    );
  }
}
