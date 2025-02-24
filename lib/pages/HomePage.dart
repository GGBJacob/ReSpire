import 'package:flutter/material.dart';
import 'package:respire/components/AddPresetTile.dart';
import 'package:respire/components/DialogBox.dart';
import 'package:respire/components/PresetEntry.dart';
import 'package:respire/components/PresetTile.dart';
import 'package:respire/services/PresetDataBase.dart';

class HomePage extends StatefulWidget{
  
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>
{
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
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
    PresetEntry entry = db.presetList[index];

    titleController.text = entry.title;
    descriptionController.text = entry.description;
    breathCount = entry.breathCount;
    inhaleTime = entry.inhaleTime;
    exhaleTime = entry.exhaleTime;
    retentionTime = entry.retentionTime;
  }

  void clearValues()
  {
    titleController.text = "";
    descriptionController.text = "";
    breathCount = 10;
    inhaleTime = 3;
    exhaleTime = 3;
    retentionTime = 3;
  }

  void addPreset()
  {
    db.presetList.add(PresetEntry(title: titleController.text, description: descriptionController.text, breathCount: breathCount, inhaleTime: inhaleTime, exhaleTime: exhaleTime, retentionTime: retentionTime));
    setState(() {

    });
    clearValues();
    db.updateDataBase();
  }

  void editPreset(int index)
  {
    db.presetList[index] = PresetEntry(title: titleController.text, description: descriptionController.text, breathCount: breathCount, inhaleTime: inhaleTime, exhaleTime: exhaleTime, retentionTime: retentionTime);
    setState(() {
      
    });
    clearValues();
    db.updateDataBase();
  }

  void deletePreset(int index)
  {
    db.presetList.removeAt(index);
    setState(() {
      
    });

    db.updateDataBase();
  }

  void showNewPresetDialog({
    required BuildContext context
    }) async
  {
    final result = await showDialog(
      context: context, 
      builder: (BuildContext context)
      {
        return DialogBox(
          titleController: titleController, 
          descriptionController: descriptionController, 
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
          descriptionController.text = result['description'];
          breathCount = result['breathCount'];
          inhaleTime = result['inhaleTime'];
          exhaleTime = result['exhaleTime'];
          retentionTime = result['retentionTime'];
        });
        addPreset();
      }
  }

  void showEditPresetDialog({
    required BuildContext context,
    required int index
    }) async
  {
    loadValues(index); // Loads values to variables before showing the dialog

    final result = await showDialog(
      context: context, 
      builder: (BuildContext context)
      {
        
        return DialogBox(
          titleController: titleController, 
          descriptionController: descriptionController, 
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
          descriptionController.text = result['description'];
          breathCount = result['breathCount'];
          inhaleTime = result['inhaleTime'];
          exhaleTime = result['exhaleTime'];
          retentionTime = result['retentionTime'];
        });
        editPreset(index);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("ReSpire"),
        backgroundColor: Colors.grey,
      ),

      body: 
      Center( 
        child:
        ListView.builder(
          itemCount: db.presetList.length + 1,
          itemBuilder: (context, index)
          {
            return Padding(
              padding: EdgeInsets.all(15), // padding between elements / screen
              child: index < db.presetList.length ?
              
              PresetTile(
                values: db.presetList[index],
                onClick: () => (),
                deleteTile: (context) => deletePreset(index),
                editTile: (context) => showEditPresetDialog(context: context, index: index),
              ) :
            
              AddPresetTile(onClick: () => showNewPresetDialog(context:context))
            );
          }
        )
      
      ),
    );
  }
  
}
