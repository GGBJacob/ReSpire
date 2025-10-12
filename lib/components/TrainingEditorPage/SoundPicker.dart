import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';

class SoundPicker extends StatefulWidget {

  final SoundManager soundManager = SoundManager();

  @override
  _SoundPickerState createState() => _SoundPickerState();
}

class _SoundPickerState extends State<SoundPicker>
{
  String currentSound = "";
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        DropdownButton(
          value: currentSound,
          items: 
        [
          DropdownMenuItem<String>(
            value: "",
            child: Text("NONE"),
          ),

          ...widget.soundManager.getAvailableSounds().map((sound){
            return DropdownMenuItem<String>(
              value: sound,
              child: Text(sound),
            );
          })
        ],
        
        onChanged: (String? value) {
          log("Selected sound: $value");
          if (value == null) return;
          setState(() {
            currentSound = value;
          });
        }),

        GestureDetector(
          onTap: () {
            widget.soundManager.stopAllSounds();
          },
          child: Icon(Icons.stop, size: 40, color: Colors.red),
        ),

        GestureDetector(
          onTap: () {
            //widget.soundManager.playSound(currentSound);
            widget.soundManager.playSoundFadeIn(currentSound, 1000);
          },
          child: Icon(Icons.play_arrow, size: 40, color: Colors.green),
        ),

        GestureDetector(
          onTap: () {
            //widget.soundManager.pauseSound(currentSound);
            widget.soundManager.pauseSoundFadeOut(currentSound, 1000);
          },
          child: Icon(Icons.pause, size: 40, color: Colors.yellow),
        ),
    ]);
  }
  
}

