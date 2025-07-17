import 'package:flutter/material.dart';
import 'package:respire/services/SettingsProvider.dart';
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TranslationProvider/AppLanguage.dart';

String? selectedLocale;
String? selectedVoice;
List<Map<String, dynamic>> allVoices = [];
List<Map<String, dynamic>> filteredVoices = [];

class VoiceSelector extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _VoiceSelectorState();
}

class _VoiceSelectorState extends State<VoiceSelector> {
  final ttsService = TextToSpeechService();
  final settingsProvider = SettingsProvider();

  @override
  void dispose() {
    super.dispose();
  }

@override
void initState() {
  super.initState();
  loadVoices();
  selectedLocale = settingsProvider.getVoiceCode();
}

Future<void> loadVoices() async {
  List<Map<String,dynamic>> voices = await ttsService.getVoices();
  setState(() {
    allVoices = voices;
  });
}

@override
Widget build(BuildContext context) {
  final Map<String, String> languages = {
    for (var voice in allVoices) voice['locale']: voice['languageName']
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
        Text(
          "Language:",
          style: TextStyle(fontSize: 18),
        ),
        DropdownButton<String>(
          value: selectedLocale,
          hint: Text("Select language"),
          items: languages.entries.map((language) {
            return DropdownMenuItem(value: language.key, child: Text(language.value));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedLocale = value;
              filteredVoices = allVoices.where((v) => v['languageName'] == value).toList();
              selectedVoice = null;
              settingsProvider.setLanguage(AppLanguage.fromCode(value!));
            });
          },
        )
      ])
    ]
  );
}
}