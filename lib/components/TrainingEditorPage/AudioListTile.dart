import 'package:flutter/material.dart';

class AudioListTile extends StatelessWidget {
  final MapEntry<String, String?> entry;
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
          leading: IconButton(onPressed: onPlayToggle, icon: entry.value == null ? Icon(Icons.volume_off, color: Colors.grey) : isPlaying ? Icon(Icons.pause, color: Colors.red) : Icon(Icons.play_arrow, color: Colors.green)),
          title: Text(entry.key, overflow: TextOverflow.clip, maxLines: 1,),
          trailing: isRemovable ? IconButton(onPressed: () => _removeUserEntry(context, onRemove), icon: Icon(Icons.delete, color: Colors.red)) : null,
          onTap: onTap,
        ),
      )
    );
  }

 void _removeUserEntry(BuildContext context, VoidCallback onConfirmed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Sound"),
          content: Text("Are you sure you want to remove '${entry.key}'?"),
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