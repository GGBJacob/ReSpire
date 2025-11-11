import 'package:flutter/material.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:respire/utils/DurationFormatter.dart';

///A tile within `AudioSelectionPopup`
class AudioListTile extends StatefulWidget {
  final SoundAsset entry;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayToggle;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback onRemove;
  final bool showDuration;

  const AudioListTile({
    super.key,
    required this.entry,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayToggle,
    required this.isSelected,
    this.isRemovable = false,
    this.onRemove = _defaultOnRemove,
    this.showDuration = false,
  });

  static void _defaultOnRemove() {}

  @override
  State<AudioListTile> createState() => _AudioListTileState();
}

class _AudioListTileState extends State<AudioListTile> {
  Duration? _duration;
  bool _loadingDuration = false;
  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    if (widget.showDuration && widget.entry.type != SoundType.none && widget.entry.type != SoundType.voice) {
      _loadDuration();
    }
  }

  Future<void> _loadDuration() async {
    if (_loadingDuration) return;
    _loadingDuration = true;
    
    final soundManager = SoundManager();
    final duration = await soundManager.getSoundDuration(widget.entry.name);
    
    if (mounted) {
      setState(() {
        _duration = duration;
        _loadingDuration = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selected: widget.isSelected,
          selectedColor: Colors.black,
          textColor: Colors.black,
          titleTextStyle: widget.isSelected ? TextStyle(fontWeight: FontWeight.bold):TextStyle(fontWeight: FontWeight.normal),
          selectedTileColor: Color.fromARGB(99, 156, 156, 156),
          leading: IconButton(onPressed: widget.onPlayToggle, iconSize:35, icon: getTileIcon(widget.entry)),
          title: Row(
            children: [
              Expanded(
                child: Text(widget.entry.name, overflow: TextOverflow.clip, maxLines: 1),
              ),
              if (widget.showDuration && _duration != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    formatDuration(_duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          trailing: widget.isRemovable ? IconButton(onPressed: () => _removeUserEntry(context, widget.onRemove), icon: Icon(Icons.delete_outline, color: Colors.red.shade300)) : null,
          onTap: widget.onTap,
        ),
      )
    );
  }

  Icon getTileIcon(SoundAsset asset) {
    if (asset.type == SoundType.voice) {
      return Icon(Icons.record_voice_over, color: darkerblue, size:26);
    } else if (asset.type == SoundType.none) {
      return Icon(Icons.volume_off, color: Colors.grey, size: 26);
    } else {
      return widget.isPlaying ? Icon(Icons.pause, color: Colors.red) : Icon(Icons.play_arrow, color: Colors.green);
    }
  }

  void _removeUserEntry(BuildContext context, VoidCallback onConfirmed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("TrainingEditorPage.SoundsTab.RemovingUserSoundPopup.title")),
          content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black, 
              fontSize: 16,
            ),
            children: [ TextSpan(
                  text: "${translationProvider.getTranslation("TrainingEditorPage.SoundsTab.RemovingUserSoundPopup.content")} ",
                ),
                TextSpan(
                  text: widget.entry.name,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: mediumblue,
                  ),
                ),
                const TextSpan(text: " ?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // cancel
              child: Text(translationProvider.getTranslation("PopupButton.cancel")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                onConfirmed(); // run your actual removal logic
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(translationProvider.getTranslation("PopupButton.remove")),
            ),
          ],
        );
      },
    );
}

}