import 'package:flutter/material.dart';
import 'package:respire/components/TrainingEditorPage/AudioSelectionPopup.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';

class SoundSelectionRow extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final SoundListType soundListType;
  final ValueChanged<String> onChanged;

  const SoundSelectionRow({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.soundListType,
    required this.onChanged,
  });

  Future<void> _openPopup(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AudioSelectionPopup(
        listType: soundListType,
        selectedValue: selectedValue,
      ),
    );

    if (result != null && result.isNotEmpty) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: darkerblue, fontWeight: FontWeight.bold)),
       ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 150), // adjust as needed
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selectedValue ??
                    TranslationProvider()
                        .getTranslation("TrainingEditorPage.SoundsTab.None"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.music_note),
              onPressed: () => _openPopup(context),
            ),
          ],
        ),
      ),]
    );
  }
}