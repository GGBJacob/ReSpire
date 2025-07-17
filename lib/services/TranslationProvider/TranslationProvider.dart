import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:respire/services/SettingsProvider.dart';
import 'package:respire/services/TranslationProvider/AppLanguage.dart';

class TranslationProvider {

  TranslationProvider._privateConstructor(){init();}
  // Singleton instance
  static final TranslationProvider _instance = TranslationProvider._privateConstructor();
  factory TranslationProvider() {
    return _instance;
  }

  void init() { //TODO: Remove this line when we finally bring back the language selection
    SettingsProvider().addListener(() {
      loadLanguage(SettingsProvider().currentLanguage);
    });
    loadLanguage(SettingsProvider().currentLanguage);
  }

  Map<String, String> _translations = {};

  List<AppLanguage> get supportedLanguages => AppLanguage.supportedLanguages;

  void loadLanguage(AppLanguage language) async{

    if (supportedLanguages.contains(language) == false) {
      throw Exception("Language not supported: ${language.code}");
    }
    try{
      String loadingFile = "${language.localeCode}.json";
      String jsonContent = await rootBundle.loadString("assets/translations/$loadingFile");
      _translations = Map<String, String>.from(json.decode(jsonContent));
      print("Loading language: $language");
    } catch (e) {
      _translations = {};
    }
  }

  String getTranslation(String key) {
    var searchKey = key.toLowerCase();
    String value = _translations.containsKey(searchKey) ? _translations[searchKey]! : key;
    return value;
  }
}