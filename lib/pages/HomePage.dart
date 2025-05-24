import 'package:flutter/material.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/HomePage/AddPresetTile.dart';
import 'package:respire/components/HomePage/DialogBox.dart';
import 'package:respire/components/HomePage/PresetTile.dart';
import 'package:respire/pages/BreathingPage.dart';
import 'package:respire/pages/SettingsPage.dart';
import 'package:respire/services/PresetDataBase.dart';

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

  @override
  void initState() {
    db.initialize();
    super.initState();
  }


  void loadValues(int index)
  {
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


  void addPreset()
  {
    //TODO: Implement preset adding (dedicated page + controllers)
    db.presetList.add(Training(title: titleController.text, phases: List.empty()));
    setState(() {

    });
    clearValues();
    db.updateDataBase();
  }


  void editPreset(int index)
  {
    //TODO: Implement preset editing (dedicated page + controllers)
    db.presetList[index] = Training(title: titleController.text, phases: List.empty());
    setState(() {
      
    });
    clearValues();
    db.updateDataBase();
  }

  void deletePreset(int index) {
    db.presetList.removeAt(index);
    setState(() {});

    db.updateDataBase();
  }

  void showNewPresetDialog({required BuildContext context}) async {
    final result = await showDialog(

      context: context, 
      builder: (BuildContext context)
      {
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
      builder: (BuildContext context)
      {
        
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => {},
        ),
        title: Text("ReSpire", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.grey,
      ),
      body: Center(
          child: ListView.builder(
              itemCount: db.presetList.length + 1,
              itemBuilder: (context, index) {
                return Padding(
                    padding:
                        EdgeInsets.all(15), // padding between elements / screen
                    child: index < db.presetList.length
                        ? PresetTile(
                            values: db.presetList[index],
                            onClick: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BreathingPage(
                                      training: db.presetList[index])),
                            ),
                            deleteTile: (context) => deletePreset(index),
                            editTile: (context) => showEditPresetDialog(
                                context: context, index: index),
                          )
                        : AddPresetTile(
                            onClick: () =>
                                showNewPresetDialog(context: context)));
              })),
    );
  }
}
