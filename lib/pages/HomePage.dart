import 'package:flutter/material.dart';
import 'package:respire/components/AddPresetTile.dart';
import 'package:respire/components/PresetEntry.dart';
import 'package:respire/components/PresetTile.dart';

class HomePage extends StatefulWidget{
  
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();


}

class _HomePageState extends State<HomePage>
{

  final List<PresetEntry>presetList = [
    PresetEntry(title: "Breathing hard", breathCount: 30, inhaleTime: 3, exhaleTime: 3, retentionTime: 1),
    PresetEntry(title: "Not breathing", breathCount: 1, inhaleTime: 10, exhaleTime: 0, retentionTime: 9999),
    ];

  void addPreset()
  {
    
  }

  void deletePreset()
  {

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
          itemCount: presetList.length + 1,
          itemBuilder: (context, index)
          {
            return Padding(
              padding: EdgeInsets.all(15), // padding between elements / screen
              child: index < presetList.length ?
              
              PresetTile(
                values: presetList[index],
                onClick: () => (),
                deleteTile: (context) => deletePreset(),
              ) :
            
              AddPresetTile(onClick: () => ())
            );
          }
        )
      
      ),
    );
  }
  
}
