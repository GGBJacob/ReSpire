import 'package:flutter/material.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/TrainingEditorPage/PlaylistEditor.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';

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

    return Column(
      children: stages.map((stage) {
        final playlist = stagePlaylists[stage.id] ?? [];
        
        return _buildStagePlaylistSection(
          context,
          stage,
          playlist,
          translationProvider,
        );
      }).toList(),
    );
  }

  Widget _buildStagePlaylistSection(
    BuildContext context,
    TrainingStage stage,
    List<SoundAsset> playlist,
    TranslationProvider translationProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: darkblue.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Row(
            children: [
              Icon(
                Icons.music_note,
                color: mediumblue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.name.isEmpty
                      ? translationProvider.getTranslation("TrainingEditorPage.TrainingTab.default_training_stage_name")
                      : stage.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (playlist.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mediumblue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${playlist.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: mediumblue,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            PlaylistEditor(
              playlist: playlist,
              onChanged: (newPlaylist) {
                final newStagePlaylists = Map<String, List<SoundAsset>>.from(stagePlaylists);
                newStagePlaylists[stage.id] = newPlaylist;
                onChanged(newStagePlaylists);
              },
              emptyMessage: translationProvider.getTranslation(
                "TrainingEditorPage.SoundsTab.PlaylistEditor.empty_stage_playlist"
              ),
            ),
          ],
        ),
      ),
    );
  }
}
