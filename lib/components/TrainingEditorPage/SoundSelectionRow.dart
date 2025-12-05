import 'package:flutter/material.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/TrainingEditorPage/AudioSelectionPopup.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/theme/Colors.dart';

///A row containing a name of a sound and the `AudioSelectionPopup`
class SoundSelectionRow extends StatelessWidget {
  final String label;
  final SoundAsset selectedValue;
  final SoundListType soundListType;
  final bool includeVoiceOption;
  final ValueChanged<SoundAsset> onChanged;
  final TextStyle? labelStyle;
  final bool blueBorder;
  final bool isSoundSelection;

  const SoundSelectionRow({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.soundListType,
    required this.includeVoiceOption,
    required this.onChanged,
    this.labelStyle,
    this.blueBorder = false,
    required this.isSoundSelection,
  });

  Future<void> _openPopup(BuildContext context) async {
    final result = await showDialog<SoundAsset>(
      context: context,
      builder: (_) => AudioSelectionPopup(
        includeVoiceOption: includeVoiceOption,
        listType: soundListType,
        selectedValue: selectedValue.name,
        isSoundSelection: isSoundSelection,
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: blueBorder ? mediumblue : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
    ), 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle ?? const TextStyle(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openPopup(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      selectedValue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.music_note, size: 20),
                ],
              ),
            ),
          ),
        ),
      ]
    ),
    );
  }
}