import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:respire/services/TranslationProvider/AppLanguage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;

  SettingsProvider._internal(){init();}

  AppLanguage currentLanguage = AppLanguage.english;

  Future<void> init() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    currentLanguage = AppLanguage.fromCode(sharedPreferences.getString('selectedLanguageCode'));
    log("Loaded voice type: ${currentLanguage.name}");
  }

  Future<void> setVoiceType(String newVoiceType) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    currentLanguage = AppLanguage.fromCode(newVoiceType);
    await sharedPreferences.setString('selectedLanguageCode', currentLanguage.code);
    notifyListeners();
  } 

  Future<void> setLanguage(AppLanguage language) async {
    if (AppLanguage.supportedLanguages.contains(language)) {
      currentLanguage = language;
      var sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('selectedLanguageCode', language.code);
      notifyListeners();
    } else {
      log("Unsupported language: ${language.code}");
    }
  }

  String getVoiceCode() {
    return currentLanguage.code;
  }
}