import 'package:flutter/material.dart';
import 'package:respire/components/Global/TrainingStage.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';

class StageExpansionList extends StatelessWidget {
  final List<TrainingStage> stages;
  final Widget Function(BuildContext context, TrainingStage stage, int index) itemBuilder;
  final String? Function(TrainingStage stage)? extraInfoBuilder;

  const StageExpansionList({
    super.key,
    required this.stages,
    required this.itemBuilder,
    this.extraInfoBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final translationProvider = TranslationProvider();

    return Column(
      children: stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        
        return _buildStageSection(
          context,
          stage,
          index,
          translationProvider,
        );
      }).toList(),
    );
  }

  Widget _buildStageSection(
    BuildContext context,
    TrainingStage stage,
    int index,
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
              if (extraInfoBuilder != null)
                _buildExtraInfo(stage),
            ],
          ),
          children: [
            itemBuilder(context, stage, index),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraInfo(TrainingStage stage) {
    final info = extraInfoBuilder!(stage);
    if (info == null || info.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: mediumblue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        info,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: mediumblue,
        ),
      ),
    );
  }
}
