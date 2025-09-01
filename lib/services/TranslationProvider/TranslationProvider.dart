import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:respire/services/SettingsProvider.dart';
import 'package:respire/services/TranslationProvider/AppLanguage.dart';

class TranslationProvider extends ChangeNotifier {

  TranslationProvider._privateConstructor(){
    loadLanguage(SettingsProvider().currentLanguage);
  }
  // Singleton instance
  static final TranslationProvider _instance = TranslationProvider._privateConstructor();
  factory TranslationProvider() {
    return _instance;
  }

  Map<String, dynamic> _translations = {};

  List<AppLanguage> get supportedLanguages => AppLanguage.supportedLanguages;

  Future<void> loadLanguage(AppLanguage language) async{

    if (supportedLanguages.contains(language) == false) {
      throw Exception("Language not supported: ${language.code}");
    }
    try{
      String loadingFile = "${language.localeCode}.json";
      String jsonContent = await rootBundle.loadString("assets/languages/$loadingFile");
      _translations = Map<String, dynamic>.from(json.decode(jsonContent));
  print("Loading language: $language");
  notifyListeners();
    } catch (e) {
      _translations = {};
    }
  }

  String getTranslation(String key) {
    if (_translations.isEmpty) {
      return key;
    }

    List<String> parts = key.split('.');
    dynamic value = _translations;

    for(String part in parts){
      if (value is Map<String, dynamic> && value.containsKey(part)) {
        value = value[part];
      } else {
        return key;
      }
    }

    return value is String ? value : key;
  }
}