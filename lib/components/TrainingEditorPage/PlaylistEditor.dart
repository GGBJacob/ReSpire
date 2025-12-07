import 'package:flutter/material.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/TrainingEditorPage/AudioSelectionPopup.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:respire/utils/DurationFormatter.dart';

class PlaylistEditor extends StatefulWidget {
  final List<SoundAsset> playlist;
  final ValueChanged<List<SoundAsset>> onChanged;
  final String? emptyMessage;

  const PlaylistEditor({
    super.key,
    required this.playlist,
    required this.onChanged,
    this.emptyMessage,
  });

  @override
  State<PlaylistEditor> createState() => _PlaylistEditorState();
}

class _PlaylistEditorState extends State<PlaylistEditor> {
  final TranslationProvider _translationProvider = TranslationProvider();
  final SoundManager _soundManager = SoundManager();
  final Map<String, Duration?> _durationCache = {};

  @override
  void initState() {
    super.initState();
    _loadDurations();
  }

  Future<void> _loadDurations() async {
    for (var sound in widget.playlist) {
      if (!_durationCache.containsKey(sound.name)) {
        final duration = await _soundManager.getSoundDuration(sound.name);
        if (mounted) {
          setState(() {
            _durationCache[sound.name] = duration;
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(PlaylistEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Load durations for any new sounds
    if (widget.playlist.length != oldWidget.playlist.length) {
      _loadDurations();
    }
  }

  Future<void> _addSound() async {
    final result = await showDialog<SoundAsset>(
      context: context,
      builder: (_) => AudioSelectionPopup(
        includeVoiceOption: false,
        includeNoneOption: false,
        listType: SoundListType.longSounds,
        selectedValue: null,
        isSoundSelection: false,
      ),
    );

    if (result != null && result.type != SoundType.none) {
      final newPlaylist = List<SoundAsset>.from(widget.playlist)..add(result);
      widget.onChanged(newPlaylist);
    }
  }

  void _removeSound(int index) {
    final newPlaylist = List<SoundAsset>.from(widget.playlist)..removeAt(index);
    widget.onChanged(newPlaylist);
  }

  void _reorderSounds(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newPlaylist = List<SoundAsset>.from(widget.playlist);
    final item = newPlaylist.removeAt(oldIndex);
    newPlaylist.insert(newIndex, item);
    widget.onChanged(newPlaylist);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.playlist.isEmpty)
          _buildEmptyState()
        else
          _buildPlaylist(),
        const SizedBox(height: 8),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.music_off,
            size: 30,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            widget.emptyMessage ?? 
            _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.PlaylistEditor.empty_playlist"),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylist() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.playlist.length,
      onReorder: _reorderSounds,
      itemBuilder: (context, index) {
        final sound = widget.playlist[index];
        return _buildSoundTile(sound, index);
      },
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Material(
                  color: Colors.transparent,  
                  child: child,
                );
              },
    );
  }

  Widget _buildSoundTile(SoundAsset sound, int index) {
    final duration = _durationCache[sound.name];
    
    return Container(
      key: ValueKey('${sound.name}_$index'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: Colors.grey.shade600,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sound.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (duration != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  formatDuration(duration),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: _soundManager.isUserMusic(sound.name)
            ? Text(
                _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.PlaylistEditor.user_music"),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outlined,
            color: darkerblue,
            size: 21,
          ),
          onPressed: () => _removeSound(index),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _addSound,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        _translationProvider.getTranslation("TrainingEditorPage.SoundsTab.PlaylistEditor.add_music"),
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: darkerblue,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
