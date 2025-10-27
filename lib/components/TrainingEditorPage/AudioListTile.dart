import 'package:flutter/material.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/theme/Colors.dart';

///A tile within `AudioSelectionPopup`
class AudioListTile extends StatelessWidget {
  final SoundAsset entry;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayToggle;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback onRemove;

  const AudioListTile({
    super.key,
    required this.entry,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayToggle,
    required this.isSelected,
    this.isRemovable = false,
    this.onRemove = _defaultOnRemove,
  });

  static void _defaultOnRemove() {}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selected: isSelected,
          selectedColor: Colors.black,
          textColor: Colors.black,
          titleTextStyle: isSelected ? TextStyle(fontWeight: FontWeight.bold):TextStyle(fontWeight: FontWeight.normal),
          selectedTileColor: Color.fromARGB(99, 156, 156, 156),
          leading: IconButton(onPressed: onPlayToggle, iconSize:35, icon: getTileIcon(entry)),
          title: Text(entry.name, overflow: TextOverflow.clip, maxLines: 1,),
          trailing: isRemovable ? IconButton(onPressed: () => _removeUserEntry(context, onRemove), icon: Icon(Icons.delete, color: Colors.red)) : null,
          onTap: onTap,
        ),
      )
    );
  }

  Icon getTileIcon(SoundAsset asset) {
    if (asset.type == SoundType.voice) {
      return Icon(Icons.record_voice_over, color: darkerblue);
    } else if (asset.type == SoundType.none) {
      return Icon(Icons.volume_off, color: Colors.grey);
    } else {
      return isPlaying ? Icon(Icons.pause, color: Colors.red) : Icon(Icons.play_arrow, color: Colors.green);
    }
  }

  void _removeUserEntry(BuildContext context, VoidCallback onConfirmed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Sound"),
          content: Text("Are you sure you want to remove '${entry.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                onConfirmed(); // run your actual removal logic
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
}

}