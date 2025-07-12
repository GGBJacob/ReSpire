import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:respire/components/TrainingEditorPage/SoundDropdownItem.dart';
import 'package:respire/theme/Colors.dart';

class AudioSelectionDropdown extends StatefulWidget{
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const AudioSelectionDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<AudioSelectionDropdown> createState() => _AudioSelectionDropdownState();
}

class _AudioSelectionDropdownState extends State<AudioSelectionDropdown> {

  ValueNotifier<String> _currentlyPlaying = ValueNotifier<String>("");

  void _handlePressed(String value) {
  setState(() {
    _currentlyPlaying.value = value;
  });
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    child:
    DropdownButton2<String>(
      onChanged: widget.onChanged,
      alignment: AlignmentDirectional.center,
      underline: SizedBox(),
      iconStyleData: IconStyleData(icon: Icon(Icons.arrow_drop_down, color: darkerblue)),
        dropdownStyleData: DropdownStyleData(
          //isOverButton: true,   
          width: 150,
          direction: DropdownDirection.left,      
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      value: widget.selectedValue, 
      //items: widget.items.map((s) => DropdownMenuItem(value: s, child: SoundDropdownItem(value: s, handleValueChange: _handlePressed, currentlyPlayingNotifier: _currentlyPlaying,))).toList(),
      items: widget.items.map((s) => DropdownMenuItem(value: s, child: SoundDropdownItem(value: s))).toList(),
      selectedItemBuilder: (context) => widget.items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList())
      );
  }

  @override
  void dispose() {
    _currentlyPlaying.dispose();
    super.dispose();
  }
}