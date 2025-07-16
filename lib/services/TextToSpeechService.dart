import 'dart:developer';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:respire/services/SettingsProvider.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  TextToSpeechService._internal();


  Future<void> init() async{
    var settings = SettingsProvider();
    settings.addListener(() async {
      String newVoice = settings.getVoiceCode();
      await _flutterTts.setLanguage(newVoice);
      log("Voice changed to: $newVoice");
    });
    await _flutterTts.setLanguage(SettingsProvider().getVoiceCode());
    _flutterTts.setErrorHandler((error) {
      log("TTS Error: $error");
    });
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    final Map<String, String> supportedLanguages = {"en-US":"English", "pl-PL":"Polski", "de-DE":"Deustsh", "fr-FR":"Français", "es-ES":"Español", "it-IT":"Italiano", "pt-PT":"Português", "ru-RU":"Русский", "tr-TR":"Türkçe", "ja-JP":"日本語", "zh-CN":"中文"};
    final rawVoices = await _flutterTts.getVoices;

    final List<Map<String, dynamic>> voices = rawVoices
        .map<Map<String, dynamic>>((v) => Map<String, dynamic>.from(v))
        .toList();

    final List<Map<String, dynamic>> filteredVoices = voices
        .where((v) => supportedLanguages.containsKey(v['locale']))
        .map((v) {
          v['languageName'] = supportedLanguages[v['locale']];
          return v;
        })
        .toList();
    return filteredVoices;
  }

  Future<void>readNumber(int number) async
  {
    // Cannot reproduce, but sometimes the language resets and needs to be set again even after init is called.
    // Leaving this in code in case something like this ever happens again. (Seems like the only viable solution)
    //await _flutterTts.setLanguage("en-US"); // maybe call it with a language fetched from app settings instead?
    log("Speaking... (value=$number)");
    await _flutterTts.speak(number.toString());
    log("Finished speaking.");
  }

  Future<void>speak(String text) async
  {
    // Cannot reproduce, but sometimes the language resets and needs to be set again even after init is called.
    // Leaving this in code in case something like this ever happens again. (Seems like the only viable solution)
    //await _flutterTts.setLanguage("en-US"); // maybe call it with a language fetched from app settings instead?
    log("Speaking... (value=$text)");
    await _flutterTts.speak(text);
    log("Finished speaking.");
  }

  void stopSpeaking()
  {
    _flutterTts.stop();
  }

}