import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/TrainingEditorPage/AudioListTile.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SingleSoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/services/UserSoundsDataBase.dart';
import 'package:respire/theme/Colors.dart';

class AudioSelectionPopup extends StatefulWidget {
  final SoundListType listType;
  final bool includeVoiceOption;
  final bool includeNoneOption;
  final String? selectedValue;
  final bool isSoundSelection;
  const AudioSelectionPopup({super.key, required this.listType, required this.selectedValue, required this.includeVoiceOption, this.includeNoneOption = true, required this.isSoundSelection, });

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
    
    final userItemsMap = switch (widget.listType) {
      SoundListType.longSounds => UserSoundsDatabase().userLongSounds,
      SoundListType.shortSounds => UserSoundsDatabase().userShortSounds,
      SoundListType.countingSounds => UserSoundsDatabase().userCountingSounds,
    };

    final itemsMap = {
      if (widget.includeNoneOption)
      _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.None"):SoundAsset(type: SoundType.none),
      if (widget.includeVoiceOption)
        _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.Voice"):SoundAsset(type: SoundType.voice),
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
      title: widget.isSoundSelection ? Text(_translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopupSound.title")) : Text(_translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopupMusic.title")),
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
                  final entry = items[index].value;
                  return _tileForPresetEntry(entry);
                }

                if (index == items.length && userItems.isNotEmpty) {
                  return _divider();
                }

                // user items
                final userIndex = index - items.length - (userItems.isNotEmpty ? 1 : 0);
                final entry = userItems[userIndex].value;
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
      SoundType type;
      switch (widget.listType) {
        case SoundListType.longSounds:
          type = SoundType.melody;
          break;
        case SoundListType.shortSounds:
          type = SoundType.cue;
          break;
        case SoundListType.countingSounds:
          type = SoundType.counting;
          break;
      }
      SoundAsset newSound = SoundAsset(name: result.files.single.name, path: result.files.single.path!, type: type);

      switch (widget.listType) {
        case SoundListType.longSounds:
          UserSoundsDatabase().addLongSound(newSound);
          break;
        case SoundListType.shortSounds:
          UserSoundsDatabase().addShortSound(newSound);
          break;
        case SoundListType.countingSounds:
          UserSoundsDatabase().addCountingSound(newSound);
          break;
      }

      setState(() {}); 
    }
  }

  Widget _tileForPresetEntry(SoundAsset asset) {
    return ValueListenableBuilder<String?>(
      valueListenable: _soundManager.currentlyPlaying,
      builder: (context, currentlyPlaying, _) {
        return AudioListTile(
          key: ValueKey(asset.name),
          entry: asset,
          isPlaying: currentlyPlaying == asset.name,
          isSelected: widget.selectedValue == asset.name,
          onPlayToggle: () => _togglePlay(asset.name),
          onTap: () => Navigator.of(context).pop(asset),
          showDuration: widget.listType == SoundListType.longSounds,
        );
      },
    );
  }

  Widget _tileForUserEntry(SoundAsset asset) {
    return ValueListenableBuilder<String?>(
      valueListenable: _soundManager.currentlyPlaying,
      builder: (context, currentlyPlaying, _) {
        return AudioListTile(
          key: ValueKey(asset),
          entry: asset,
          isPlaying: currentlyPlaying == asset.name,
          isSelected: widget.selectedValue == asset.name,
          onPlayToggle: () => _togglePlay(asset.name),
          onTap: () => Navigator.of(context).pop(asset),
          isRemovable: true,
          onRemove: () {
            switch(asset.type) {
              case SoundType.melody:
                UserSoundsDatabase().removeSound(asset.name, SoundListType.longSounds);
                break;
              case SoundType.cue:
                UserSoundsDatabase().removeSound(asset.name, SoundListType.shortSounds);
                break;
              case SoundType.counting:
                UserSoundsDatabase().removeSound(asset.name, SoundListType.countingSounds);
                break;
              default:
                break;
            }
            setState(() {});
          },
          showDuration: widget.listType == SoundListType.longSounds,
        );
      },
    );
  }

  Widget _addCustomSoundButton() {
    return TextButton.icon(
      onPressed: _addCustomSound,
      icon: const Icon(Icons.add, color: Colors.white),
      label: widget.isSoundSelection ? Text(_translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopupSound.add_custom_sound_button_label"), style: TextStyle(color: Colors.white)) : Text(_translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopupMusic.add_custom_music_button_label"), style: TextStyle(color: Colors.white)),
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
                widget.isSoundSelection ? _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopupSound.user_sounds") : _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.AudioSelectionPopupMusic.user_music"),
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