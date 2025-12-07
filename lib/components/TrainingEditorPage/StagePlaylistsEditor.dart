import 'package:flutter/material.dart';
import 'package:respire/components/Global/TrainingStage.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/TrainingEditorPage/PlaylistEditor.dart';
import 'package:respire/components/TrainingEditorPage/StageExpansionList.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class StagePlaylistsEditor extends StatelessWidget {
  final List<TrainingStage> stages;
  final Map<String, List<SoundAsset>> stagePlaylists;
  final ValueChanged<Map<String, List<SoundAsset>>> onChanged;

  const StagePlaylistsEditor({
    super.key,
    required this.stages,
    required this.stagePlaylists,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final translationProvider = TranslationProvider();

    return StageExpansionList(
      stages: stages,
      extraInfoBuilder: (stage) {
        final playlist = stagePlaylists[stage.id] ?? [];
        if (playlist.isNotEmpty) {
          return '${playlist.length}';
        }
        return null;
      },
      itemBuilder: (context, stage, index) {
        final playlist = stagePlaylists[stage.id] ?? [];
        
        return PlaylistEditor(
          playlist: playlist,
          onChanged: (newPlaylist) {
            final newStagePlaylists = Map<String, List<SoundAsset>>.from(stagePlaylists);
            newStagePlaylists[stage.id] = newPlaylist;
            onChanged(newStagePlaylists);
          },
          emptyMessage: translationProvider.getTranslation(
            "TrainingEditorPage.SoundsTab.PlaylistEditor.empty_stage_playlist"
          ),
        );
      },
    );
  }
}
