import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:respire/components/TrainingEditorPage/AudioListTile.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SingleSoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/services/UserSoundsDataBase.dart';
import 'package:respire/theme/Colors.dart';

class AudioSelectionPopup extends StatefulWidget {
  final SoundListType listType;
  final String? selectedValue;
  const AudioSelectionPopup({super.key, required this.listType, required this.selectedValue});

  @override
  State<AudioSelectionPopup> createState() => _AudioSelectionPopupState();
}

class _AudioSelectionPopupState extends State<AudioSelectionPopup>{
  
  final SingleSoundManager _soundManager = SingleSoundManager();
  final TranslationProvider _translationProvider = TranslationProvider();
  
  Future<void> _togglePlay(String soundName) async {
    if (_soundManager.currentlyPlaying.value == soundName) {
      await _soundManager.stopSound(soundName);
    } else {
      await _soundManager.playSound(soundName);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final Map<String,String> userItemsMap = 
      widget.listType == SoundListType.longSounds
          ? UserSoundsDatabase().userLongSounds
          : UserSoundsDatabase().userShortSounds;

    final itemsMap = {
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.None"): null,
      ..._soundManager.getSounds(widget.listType)
    };

    final items = itemsMap.entries.toList();
    final userItems = userItemsMap.entries.toList();
    final combinedLength = items.length + (userItems.isNotEmpty ? 1 : 0) + userItems.length;


    return AlertDialog(
      actions: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _addCustomSoundButton(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_translationProvider.getTranslation("PopupButton.cancel")),
            ),
          ],
        ),
      ],
      title: Text(_translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopup.title")),
      content: SizedBox(
        width: 300,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: RawScrollbar(
            radius: Radius.circular(10),
            thickness: 3,
            thumbVisibility: false,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: combinedLength,
              itemBuilder: (context, index) {

                //preloaded items
                if (index < items.length) {
                  final entry = items[index];
                  return _tileForPresetEntry(entry);
                }

                if (index == items.length && userItems.isNotEmpty) {
                  return _divider();
                }

                // user items
                final userIndex = index - items.length - (userItems.isNotEmpty ? 1 : 0);
                final entry = userItems[userIndex];
                return _tileForUserEntry(entry);
              },
            ),
          ) 
        ),
      ),
    );
  }

  Future<void> _addCustomSound() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio
      );

    if (result != null && result.files.single.path != null) {
      MapEntry<String, String> newSound = MapEntry(result.files.single.name, result.files.single.path!);

      widget.listType == SoundListType.longSounds
          ? UserSoundsDatabase().addLongSound(newSound)
          : UserSoundsDatabase().addShortSound(newSound);

      setState(() {}); 
    }
  }

  Widget _tileForPresetEntry(MapEntry<String, String?> entry) {
    return ValueListenableBuilder<String?>(
      valueListenable: _soundManager.currentlyPlaying,
      builder: (context, currentlyPlaying, _) {
        return AudioListTile(
          key: ValueKey(entry.key),
          entry: entry,
          isPlaying: currentlyPlaying == entry.key,
          isSelected: widget.selectedValue == entry.key || widget.selectedValue == entry.value,
          onPlayToggle: () => _togglePlay(entry.key),
          onTap: () => Navigator.of(context).pop(entry.key),
        );
      },
    );
  }

  Widget _tileForUserEntry(MapEntry<String, String?> entry) {
    return ValueListenableBuilder<String?>(
      valueListenable: _soundManager.currentlyPlaying,
      builder: (context, currentlyPlaying, _) {
        return AudioListTile(
          key: ValueKey(entry.key),
          entry: entry,
          isPlaying: currentlyPlaying == entry.key,
          isSelected: widget.selectedValue == entry.key || widget.selectedValue == entry.value,
          onPlayToggle: () => _togglePlay(entry.key),
          onTap: () => Navigator.of(context).pop(entry.key),
          isRemovable: true,
          onRemove: () {
            UserSoundsDatabase().removeSound(entry.key, SoundListType.longSounds);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _addCustomSoundButton() {
    return TextButton.icon(
      onPressed: _addCustomSound,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(_translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopup.add_custom_sound_button_label"), style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: darkerblue),
    );
  }

  Widget _divider() {
    return Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopup.user_sounds"),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Divider(thickness: 1),
            ],
          ),
        );
  }

  @override
  void dispose() {
    _soundManager.stopAllSounds();
    super.dispose();
  }
}