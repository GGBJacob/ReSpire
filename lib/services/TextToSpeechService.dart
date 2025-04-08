import 'dart:developer';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  TextToSpeechService._internal();


  Future<void> init() async{
    await _flutterTts.setLanguage("en-US");
    _flutterTts.setErrorHandler((error) {
      log("TTS Error: $error");
    });
  }

  Future<void>speak(int number) async
  {
    // Cannot reproduce, but sometimes the language resets and needs to be set again even after init is called.
    // Leaving this in code in case something like this ever happens again. (Seems like the only viable solution)
    //await _flutterTts.setLanguage("en-US"); // maybe call it with a language fetched from app settings instead?
    log("Speaking... (value=$number)");
    await _flutterTts.speak(number.toString());
    log("Finished speaking.");
  }

  void stopSpeaking()
  {
    _flutterTts.stop();
  }

}